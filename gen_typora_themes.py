#!/usr/bin/env python3
"""从 Typora 原始主题 CSS 提取配色参数，生成 md-to-pdf 用的主题样式表。"""
import re, os, sys

THEMES_DIR = os.path.expanduser("~/Library/Application Support/abnerworks.Typora/themes")
OUT_DIR = os.path.expanduser("~/bin/typora-themes")

def read(theme):
    p = os.path.join(THEMES_DIR, theme + ".css")
    if not os.path.exists(p):
        return None
    return open(p, encoding="utf-8", errors="replace").read()

def first(css, pattern, default=None):
    m = re.search(pattern, css)
    return m.group(1) if m else default

def cssvar(css, name):
    # 找 --name: value; 支持链式 var() 解一层
    m = re.search(r"--%s:\s*([^;]+);" % re.escape(name), css)
    if not m:
        return None
    v = m.group(1).strip()
    vm = re.match(r"var\((--[\w-]+)\)", v)
    if vm:
        return cssvar(css, vm.group(1)[2:])
    return v

def gen(theme, spec):
    """spec: dict with bg, text, heading, border, code_bg, code_color, blockquote_border,
    blockquote_bg, blockquote_text, table_border, table_header_bg, table_stripe, link,
    font_body, font_heading, font_code, hljs(dict)"""
    s = spec
    hljs = s.get("hljs", {})
    css = f"""/* BG: {s['bg']} */
/* Typora 「{theme}」主题复刻 — 由 gen_typora_themes.py 生成，供 md-to-pdf 使用 */

body {{
    font-family: {s.get('font_body', '"LXGW WenKai", serif')};
    color: {s.get('text', '#333')};
    background-color: {s['bg']};
    line-height: 1.7;
    margin: 0;
    padding: 0 18mm;
    box-sizing: border-box;
    word-wrap: break-word;
    print-color-adjust: exact;
    -webkit-print-color-adjust: exact;
}}

h1, h2, h3, h4, h5, h6 {{
    font-family: {s.get('font_heading', 'inherit')};
    font-weight: bold;
    line-height: 1.3;
    color: {s.get('heading', s.get('text', '#111'))};
    margin: 1.8em 0 1em;
    padding: 0;
    page-break-after: avoid;
}}
h1 {{ font-size: 2.1em; border-bottom: 1px solid {s.get('border', '#ddd')}; padding-bottom: .3em; margin-top: 1em; }}
h2 {{ font-size: 1.65em; border-bottom: 1px solid {s.get('border', '#ddd')}; padding-bottom: .3em; }}
h3 {{ font-size: 1.4em; }}
h4 {{ font-size: 1.2em; }}
h5 {{ font-size: 1.05em; }}
h6 {{ font-size: 1em; color: {s.get('heading_muted', s.get('text', '#777'))}; }}

body > h1:first-child, body > h2:first-child {{ margin-top: 0; }}

p {{ margin: 1em 0; }}
ul, ol {{ padding-left: 24px; margin: 1em 0; }}
li {{ margin-bottom: .4em; }}
li > ul, li > ol {{ margin: 0; }}

b, strong {{ font-weight: bold; color: {s.get('strong', s.get('heading', 'inherit'))}; }}
a {{ color: {s.get('link', '#268bd2')}; text-decoration: none; }}
del {{ color: {s.get('muted', '#999')}; }}

hr {{ border: 0; border-bottom: 1px solid {s.get('border', '#ddd')}; margin: 24px 0; }}

blockquote {{
    border-left: 4px solid {s.get('blockquote_border', '#b58900')};
    background: {s.get('blockquote_bg', 'transparent')};
    color: {s.get('blockquote_text', s.get('text', '#555'))};
    padding: 10px 16px;
    margin: 1.2em 0;
    font-style: italic;
}}

pre, code, kbd, tt, var {{
    font-family: {s.get('font_code', 'Consolas, "JetBrains Mono", monospace')};
    font-size: 0.88em;
}}
code, tt, var {{
    background: {s.get('code_bg', 'rgba(128,128,128,.12)')};
    color: {s.get('code_color', s.get('text', '#c7254e'))};
    border-radius: 3px;
    padding: 2px 5px;
}}
h1 code, h2 code, h3 code, h4 code, h5 code, h6 code {{ background: none; padding: 0; color: inherit; }}

pre {{
    background: {s.get('pre_bg', s.get('code_bg', '#f5f5f5'))};
    border: 1px solid {s.get('border', '#ddd')};
    border-radius: 4px;
    padding: 12px 16px;
    overflow-x: auto;
    line-height: 1.5;
    page-break-inside: avoid;
    white-space: pre-wrap;
    word-wrap: break-word;
}}
pre code {{ background: none; border: none; padding: 0; color: inherit; font-size: 1em; }}

table {{
    border-collapse: collapse;
    width: 100%;
    max-width: 100%;
    margin: 1.2em 0;
    page-break-inside: avoid;
    font-size: 0.95em;
}}
table th, table td {{
    border: 1px solid {s.get('table_border', s.get('border', '#ccc'))};
    padding: 6px 13px;
    text-align: left;
    vertical-align: top;
}}
table th {{
    background: {s.get('table_header_bg', s.get('code_bg', '#eee'))};
    font-weight: bold;
    color: {s.get('heading', 'inherit')};
}}
table tr:nth-child(2n) {{ background: {s.get('table_stripe', 'transparent')}; }}

li.task-list-item {{ list-style: none; }}
li.task-list-item input[type=checkbox] {{ margin-right: .4em; }}

img {{ max-width: 100%; page-break-inside: avoid; }}
"""
    if hljs:
        css += "\n/* highlight.js 配色 */\n"
        for sel, col in hljs.items():
            css += f".hljs-{sel} {{ color: {col}; }}\n"
    return css

SPECS = {
    # 浅色系
    "catppuccin-latte": dict(
        bg="#eff1f5", text="#4c4f69", heading="#179299", border="#bcc0cc",
        code_bg="#e6e9ef", code_color="#8839ef", blockquote_border="#df8e1d",
        blockquote_bg="#e6e9ef", link="#1e66f5", strong="#d20f39",
        table_header_bg="#e6e9ef", table_stripe="#e6e9ef",
        hljs=dict(comment="#9ca0b0", keyword="#8839ef", string="#40a02b",
                  number="#fe640b", title="#1e66f5", attr="#df8e1d", built_in="#d20f39")),
    "github": dict(
        bg="#ffffff", text="#24292f", heading="#0550ae", border="#d0d7de",
        code_bg="rgba(175,184,193,.2)", code_color="#0550ae", blockquote_border="#d0d7de",
        blockquote_bg="rgba(175,184,193,.1)", link="#0969da", strong="#24292f",
        table_header_bg="#f6f8fa", table_stripe="#f6f8fa",
        hljs=dict(comment="#6a737d", keyword="#cf222e", string="#0a3069",
                  number="#0550ae", title="#8250df", attr="#953800", built_in="#e16f24")),
    "gothic": dict(
        bg="#fcfcfc", text="#3f3f3f", heading="#000000", border="#c7c7c7",
        code_bg="#f3f3f3", blockquote_border="#3f3f3f", link="#767676",
        table_header_bg="#f3f3f3"),
    "newsprint": dict(
        bg="#f3f2ee", text="#373737", heading="#232323", border="#c9c5bd",
        code_bg="#e8e6e0", blockquote_border="#a9a493", blockquote_bg="#eae9e3",
        blockquote_text="#6b6b6b", link="#4a90a4", table_header_bg="#e8e6e0"),
    "notion-style-light": dict(
        bg="#ffffff", text="#37352f", heading="#37352f", border="#e9e9e7",
        code_bg="#f7f6f3", blockquote_border="#37352f", blockquote_bg="#f7f6f3",
        link="#37352f", table_header_bg="#f7f6f3", table_stripe="#fafaf9"),
    "pixyll": dict(
        bg="#ededed", text="#454545", heading="#38b7ea", border="#d0d0d0",
        code_bg="#f7f7f7", blockquote_border="#38b7ea", link="#38b7ea",
        table_header_bg="#f7f7f7"),
    "whitey": dict(
        bg="#fefefe", text="#4c4c4c", heading="#000000", border="#efefef",
        code_bg="#f8f8f8", blockquote_border="#dbdbdb", link="#8c8c8c",
        table_header_bg="#f8f8f8"),
    "solarized-dark": dict(
        bg="#002b36", text="#93a1a1", heading="#93a1a1", heading_muted="#657b83",
        border="#073642", code_bg="#073642", code_color="#268bd2",
        blockquote_border="#b58900", blockquote_bg="rgba(7,54,66,.6)",
        blockquote_text="#839496", link="#268bd2", strong="#eee8d5",
        table_border="#073642", table_header_bg="#073642", table_stripe="#073642",
        font_code='"JetBrainsLxgwNerdMono", Consolas, monospace',
        hljs=dict(comment="#586e75", keyword="#859900", string="#2aa198",
                  number="#d33682", title="#268bd2", attr="#b58900", built_in="#6c71c4")),
    # 深色系
    "catppuccin-frappe": dict(
        bg="#303446", text="#c6d0f5", heading="#caaaee", border="#414559",
        code_bg="#292c3c", code_color="#f4b8e4", blockquote_border="#ef9f76",
        blockquote_bg="#292c3c", link="#8caaee", strong="#e78284",
        table_border="#414559", table_header_bg="#292c3c", table_stripe="#292c3c",
        hljs=dict(comment="#949cbb", keyword="#caaaee", string="#a6d189",
                  number="#ef9f76", title="#8caaee", attr="#e5c890", built_in="#e78284")),
    "catppuccin-macchiato": dict(
        bg="#24273a", text="#cad3f5", heading="#c6a0f6", border="#363a4f",
        code_bg="#1e2030", code_color="#f5bde6", blockquote_border="#f5a97f",
        blockquote_bg="#1e2030", link="#8aadf4", strong="#ed8796",
        table_border="#363a4f", table_header_bg="#1e2030", table_stripe="#1e2030",
        hljs=dict(comment="#939ab7", keyword="#c6a0f6", string="#a6da95",
                  number="#f5a97f", title="#8aadf4", attr="#eed49f", built_in="#ed8796")),
    "catppuccin-mocha": dict(
        bg="#1e1e2e", text="#cdd6f4", heading="#cba6f7", border="#313244",
        code_bg="#181825", code_color="#f5c2e7", blockquote_border="#fab387",
        blockquote_bg="#181825", link="#89b4fa", strong="#f38ba8",
        table_border="#313244", table_header_bg="#181825", table_stripe="#181825",
        hljs=dict(comment="#9399b2", keyword="#cba6f7", string="#a6e3a1",
                  number="#fab387", title="#89b4fa", attr="#f9e2af", built_in="#f38ba8")),
    "d42ker-github": dict(
        bg="#191919", text="#d2d2d2", heading="#e0e0e0", border="#3c3c3c",
        code_bg="#252525", blockquote_border="#4a4a4a", blockquote_bg="#232323",
        link="#7aa2f7", table_border="#3c3c3c", table_header_bg="#252525"),
    "github-dark-default": dict(
        bg="#0d1117", text="#e6edf3", heading="#f0f6fc", border="#30363d",
        code_bg="#161b22", code_color="#ff7b72", blockquote_border="#3d444d",
        blockquote_bg="#151b23", link="#4493f8", strong="#e6edf3",
        table_border="#30363d", table_header_bg="#161b22", table_stripe="#161b22",
        hljs=dict(comment="#8b949e", keyword="#ff7b72", string="#a5d6ff",
                  number="#79c0ff", title="#d2a8ff", attr="#ffa657", built_in="#ffa657")),
    "github-dark-dimmed": dict(
        bg="#22272e", text="#adbac7", heading="#c3dff5", border="#373e47",
        code_bg="#2d333b", code_color="#f47067", blockquote_border="#444c56",
        blockquote_bg="#2d333b", link="#539bf5",
        table_border="#373e47", table_header_bg="#2d333b", table_stripe="#2d333b"),
    "github-dark-high-contrast": dict(
        bg="#090c10", text="#f0f3f6", heading="#f0f3f6", border="#3fb950",
        border2="#262c36", code_bg="#121821", code_color="#ff9492",
        blockquote_border="#3d444d", blockquote_bg="#10161f", link="#71b7ff",
        table_border="#262c36", table_header_bg="#121821", table_stripe="#121821"),
    "ladder": dict(
        bg="#ffffff", text="#3f3f3f", heading="#1f2937", border="#e5e7eb",
        code_bg="#f3f4f6", code_color="#dc2626", blockquote_border="#6b7280",
        blockquote_bg="#f9fafb", link="#2563eb",
        table_border="#e5e7eb", table_header_bg="#f3f4f6",
        font_code='"JetBrainsLxgwNerdMono", Consolas, monospace'),
    "ladder-dark": dict(
        bg="#1e293b", text="#cbd5e1", heading="#f1f5f9", border="#334155",
        code_bg="#0f172a", code_color="#f87171", blockquote_border="#64748b",
        blockquote_bg="rgba(15,23,42,.6)", link="#60a5fa",
        table_border="#334155", table_header_bg="#0f172a", table_stripe="#0f172a",
        font_code='"JetBrainsLxgwNerdMono", Consolas, monospace'),
    "night": dict(
        bg="#363b40", text="#b8bfc6", heading="#d5d9dd", border="#5a6064",
        code_bg="#30343a", code_color="#a5c261", blockquote_border="#6a737d",
        blockquote_bg="rgba(48,52,58,.8)", link="#6699bf",
        table_border="#5a6064", table_header_bg="#30343a", table_stripe="#30343a"),
    "notion-style-dark": dict(
        bg="#191919", text="#d4d4d4", heading="#e6e6e6", border="#2f2f2f",
        code_bg="#252525", blockquote_border="#4a4a4a", blockquote_bg="#202020",
        link="#6294d0", table_border="#2f2f2f", table_header_bg="#252525",
        table_stripe="#1f1f1f"),
}

for name, spec in SPECS.items():
    out = os.path.join(OUT_DIR, f"typora-{name}.css")
    with open(out, "w") as f:
        f.write(gen(name, spec))
    print("生成", out)
