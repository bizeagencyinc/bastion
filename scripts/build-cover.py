# BASTION cover generator: writes assets/cover.svg. Render to PNG with the command in CLAUDE.md.
# Edit the category lists below to change the cover.
import html
W,H=1280,640
cats=[
 ("LANGUAGES","#22D3EE","#0F2A3D","#E0F2FE",["TypeScript","JavaScript","Python","PHP","Kotlin","Java","Swift","Dart","C#","C++","SQL"]),
 ("FRAMEWORKS","#818CF8","#1E1B4B","#E0E7FF",["Next.js","React","Vue","Svelte","Laravel","Django","FastAPI","NestJS","Express","Flutter","React Native","Electron","Tauri","WordPress","Angular","SwiftUI","Jetpack Compose","Node.js"]),
 ("DATABASES","#34D399","#062F27","#D1FAE5",["PostgreSQL","MySQL","SQL Server","Oracle","MongoDB","Redis","Supabase","Firebase","DynamoDB","Elasticsearch","Pinecone","Snowflake","SQLite","MariaDB","Cassandra","Neo4j","ClickHouse","Qdrant"]),
 ("PLATFORMS","#F59E0B","#3B2A0A","#FDE68A",["Android","iOS","macOS","Windows","Web","Cloud","AI Agents","Payments","Banking"]),
]
def tw(t,size=13.5):
    # approximate Inter semibold width
    w=0
    for c in t:
        if c in "il.|' ": w+=0.30
        elif c in "fjtrI": w+=0.40
        elif c in "mwMW": w+=0.88
        elif c.isupper(): w+=0.68
        elif c.isdigit(): w+=0.60
        elif c in "#+": w+=0.62
        else: w+=0.57
    return w*size
X0=372; XMAX=1240; y=272; out=[]
for label,stroke,fill,txt,items in cats:
    out.append(f'<text x="{X0}" y="{y-8}" font-size="11.5" font-weight="700" letter-spacing="2.5" fill="{stroke}">{label}</text>')
    x=X0; y+=0
    for it in items:
        w=round(tw(it)+24)
        if x+w>XMAX: x=X0; y+=31
        out.append(f'<rect x="{x}" y="{y}" width="{w}" height="25" rx="12.5" fill="{fill}" stroke="{stroke}" stroke-opacity="0.6"/>')
        out.append(f'<text x="{x+w/2:.1f}" y="{y+17}" text-anchor="middle" font-size="13.5" font-weight="600" fill="{txt}">{html.escape(it)}</text>')
        x+=w+7
    y+=31+24
chips="\n    ".join(out)
svg=f'''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {W} {H}" width="{W}" height="{H}" role="img" aria-label="Bastion: Security Rules for AI Coding Agents">
  <defs>
    <linearGradient id="bg" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stop-color="#060A14"/><stop offset="1" stop-color="#101A33"/></linearGradient>
    <radialGradient id="glowL" cx="0.17" cy="0.5" r="0.42"><stop offset="0" stop-color="#22D3EE" stop-opacity="0.22"/><stop offset="1" stop-color="#22D3EE" stop-opacity="0"/></radialGradient>
    <radialGradient id="glowR" cx="0.9" cy="0.1" r="0.5"><stop offset="0" stop-color="#6366F1" stop-opacity="0.25"/><stop offset="1" stop-color="#6366F1" stop-opacity="0"/></radialGradient>
    <linearGradient id="accent" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stop-color="#22D3EE"/><stop offset="1" stop-color="#6366F1"/></linearGradient>
    <linearGradient id="tower" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#67E8F9"/><stop offset="1" stop-color="#818CF8"/></linearGradient>
    <linearGradient id="title" x1="0" y1="0" x2="1" y2="0"><stop offset="0" stop-color="#FFFFFF"/><stop offset="1" stop-color="#C7D2FE"/></linearGradient>
    <pattern id="grid" width="40" height="40" patternUnits="userSpaceOnUse"><path d="M40 0 H0 V40" fill="none" stroke="#1E293B" stroke-width="1"/></pattern>
  </defs>
  <rect width="{W}" height="{H}" fill="url(#bg)"/>
  <rect width="{W}" height="{H}" fill="url(#grid)" opacity="0.55"/>
  <rect width="{W}" height="{H}" fill="url(#glowL)"/>
  <rect width="{W}" height="{H}" fill="url(#glowR)"/>
  <g transform="translate(12 150) scale(2.45)">
    <path d="M64 6 L114 24 V62 C114 92 92 113 64 122 C36 113 14 92 14 62 V24 Z" fill="#0B1220" stroke="url(#accent)" stroke-width="4.5" stroke-linejoin="round"/>
    <path d="M40 94 V42 H50 V51 H59 V42 H69 V51 H78 V42 H88 V94 Z" fill="url(#tower)"/>
    <circle cx="64" cy="68" r="6.5" fill="#0B1220"/>
    <path d="M60.5 72 L58 87 H70 L67.5 72 Z" fill="#0B1220"/>
  </g>
  <g font-family="Inter, 'Segoe UI', Helvetica, Arial, sans-serif">
    <text x="{X0}" y="64" font-size="14" font-weight="700" letter-spacing="3.5" fill="#67E8F9">OPEN SECURITY RULESET  |  v2.3.0  |  2027 READY</text>
    <text x="{X0-4}" y="146" font-size="92" font-weight="800" letter-spacing="8" fill="url(#title)">BASTION</text>
    <text x="{X0}" y="186" font-size="26" font-weight="600" fill="#E2E8F0">Security Rules for AI Coding Agents</text>
    <text x="{X0}" y="216" font-size="16" fill="#94A3B8">680+ rules  ·  21 platforms  ·  40+ databases  ·  MCP server  ·  Claude Code plugin</text>
    {chips}
    <rect x="0" y="584" width="{W}" height="56" fill="#060A14" opacity="0.8"/>
    <rect x="0" y="584" width="{W}" height="2" fill="url(#accent)"/>
    <text x="46" y="618" font-size="16" fill="#94A3B8">Works with</text>
    <text x="142" y="618" font-size="16" font-weight="600" fill="#E2E8F0">Claude Code  ·  VS Code  ·  Cursor  ·  GitHub Copilot  ·  Windsurf  ·  Cline  ·  Codex  ·  Gemini CLI</text>
    <text x="1236" y="618" font-size="14" text-anchor="end" fill="#64748B">MIT License</text>
  </g>
</svg>
'''
open(__import__('os').path.join(__import__('os').path.dirname(__file__),'..','assets','cover.svg'),'w').write(svg)
print("last y", y)
