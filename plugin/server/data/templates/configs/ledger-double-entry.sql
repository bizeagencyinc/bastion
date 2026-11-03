-- =====================================================================
-- BASTION TEMPLATE | Double-entry ledger (PostgreSQL)
-- Rules: FIN-10, FIN-12, FIN-13, FIN-14, FIN-21, PAY-18, PAY-19
--
-- Principles:
--   * Amounts are BIGINT in minor units (cents, paisa). No floats.
--   * Entries are append-only. Corrections are new reversing entries.
--   * Every journal must balance to zero per currency.
--   * Balances are derived from entries (cached balance updated in the same transaction).
-- =====================================================================

create table accounts (
  id            uuid primary key default gen_random_uuid(),
  owner_id      uuid not null,
  currency      char(3) not null,                 -- ISO 4217
  kind          text not null check (kind in ('customer','fee','suspense','settlement','reserve')),
  status        text not null default 'active' check (status in ('active','frozen','closed')),
  balance_minor bigint not null default 0,        -- cached, updated only by post_journal()
  allow_negative boolean not null default false,
  version       bigint not null default 0,
  created_at    timestamptz not null default now()
);

create table journals (
  id              uuid primary key default gen_random_uuid(),
  idempotency_key text not null unique,           -- FIN-13
  kind            text not null,                  -- transfer, fee, reversal, adjustment
  status          text not null default 'posted' check (status in ('posted','reversed')),
  reverses_id     uuid references journals (id),
  created_by      uuid not null,
  approved_by     uuid,                           -- maker-checker for manual adjustments (FIN-49)
  created_at      timestamptz not null default now(),
  check (approved_by is null or approved_by <> created_by)
);

create table entries (
  id           bigserial primary key,
  journal_id   uuid not null references journals (id),
  account_id   uuid not null references accounts (id),
  currency     char(3) not null,
  amount_minor bigint not null check (amount_minor <> 0),  -- positive credit, negative debit
  created_at   timestamptz not null default now()
);
create index entries_account_idx on entries (account_id, created_at);

-- Append-only: block UPDATE and DELETE on entries and journals' money fields.
create or replace function forbid_mutation() returns trigger language plpgsql as $$
begin
  raise exception 'Ledger rows are immutable. Post a reversing journal instead.';
end $$;

create trigger entries_immutable before update or delete on entries
  for each row execute function forbid_mutation();

-- Post a balanced journal atomically.
-- p_lines: jsonb array of {"account_id": "...", "amount_minor": 1234}
create or replace function post_journal(
  p_idempotency_key text,
  p_kind text,
  p_created_by uuid,
  p_lines jsonb
) returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_journal uuid;
  v_line jsonb;
  v_acc accounts%rowtype;
  v_sum bigint := 0;
  v_currency char(3);
begin
  -- Idempotency: return existing journal if the key was already used.
  select id into v_journal from journals where idempotency_key = p_idempotency_key;
  if found then return v_journal; end if;

  insert into journals (idempotency_key, kind, created_by)
  values (p_idempotency_key, p_kind, p_created_by)
  returning id into v_journal;

  -- Lock accounts in a stable order to avoid deadlocks (FIN-14).
  for v_line in
    select value from jsonb_array_elements(p_lines) order by value->>'account_id'
  loop
    select * into v_acc from accounts
      where id = (v_line->>'account_id')::uuid
      for update;

    if not found then raise exception 'Unknown account'; end if;
    if v_acc.status <> 'active' then raise exception 'Account not active'; end if;
    if v_currency is null then v_currency := v_acc.currency;
    elsif v_currency <> v_acc.currency then raise exception 'Mixed currencies in one journal'; end if;

    if not v_acc.allow_negative
       and v_acc.balance_minor + (v_line->>'amount_minor')::bigint < 0 then
      raise exception 'Insufficient funds';
    end if;

    insert into entries (journal_id, account_id, currency, amount_minor)
    values (v_journal, v_acc.id, v_acc.currency, (v_line->>'amount_minor')::bigint);

    update accounts
      set balance_minor = balance_minor + (v_line->>'amount_minor')::bigint,
          version = version + 1
      where id = v_acc.id;

    v_sum := v_sum + (v_line->>'amount_minor')::bigint;
  end loop;

  if v_sum <> 0 then
    raise exception 'Journal does not balance (sum = %)', v_sum;
  end if;

  return v_journal;
end $$;

revoke all on function post_journal(text, text, uuid, jsonb) from public;
-- grant execute only to the backend service role, never to client roles.

-- Daily reconciliation check (FIN-20): cached balances must equal the sum of entries.
create view ledger_drift as
select a.id, a.balance_minor, coalesce(sum(e.amount_minor), 0) as entries_sum
from accounts a
left join entries e on e.account_id = a.id
group by a.id, a.balance_minor
having a.balance_minor <> coalesce(sum(e.amount_minor), 0);
