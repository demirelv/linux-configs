#!/bin/bash
# Claude Code ayarlarini ~/.claude altina kurar.
# - CLAUDE.md, RTK.md, statusline.sh kopyalanir (varsa yedeklenir)
# - settings.json birlestirilir: mevcut permissions/allow ve kisisel alanlar korunur
set -euo pipefail

SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DST_DIR="$HOME/.claude"
stamp="$(date +%Y%m%d-%H%M%S)"

mkdir -p "$DST_DIR"

for f in CLAUDE.md RTK.md statusline.sh; do
    src="$SRC_DIR/$f"; dst="$DST_DIR/$f"
    if [ -e "$dst" ] && ! cmp -s "$src" "$dst"; then
        cp -a "$dst" "$dst.bak.$stamp"
        echo "    yedek: $dst.bak.$stamp"
    fi
    cp "$src" "$dst"
    echo "    kuruldu: $dst"
done
chmod +x "$DST_DIR/statusline.sh"

if [ -f "$DST_DIR/settings.json" ]; then
    cp -a "$DST_DIR/settings.json" "$DST_DIR/settings.json.bak.$stamp"
    echo "    yedek: $DST_DIR/settings.json.bak.$stamp"
fi

SRC_DIR="$SRC_DIR" DST_DIR="$DST_DIR" python3 - <<'PY'
import json, os

src_path = os.path.join(os.environ["SRC_DIR"], "settings.json")
dst_path = os.path.join(os.environ["DST_DIR"], "settings.json")

new = json.load(open(src_path))
cur = {}
if os.path.exists(dst_path):
    try:
        cur = json.load(open(dst_path))
    except json.JSONDecodeError:
        cur = {}

# statusline yolunu mutlak yap
new["statusLine"]["command"] = os.path.join(os.environ["DST_DIR"], "statusline.sh")

# kisisel izinler korunur, repo sadece defaultMode verir
merged = dict(cur)
for k, v in new.items():
    if k == "permissions":
        p = dict(cur.get("permissions", {}))
        p.setdefault("allow", [])
        p["defaultMode"] = v.get("defaultMode", p.get("defaultMode", "auto"))
        merged["permissions"] = p
    elif k in ("enabledPlugins", "extraKnownMarketplaces") and isinstance(cur.get(k), dict):
        m = dict(cur[k]); m.update(v); merged[k] = m
    else:
        merged[k] = v

json.dump(merged, open(dst_path, "w"), indent=2, ensure_ascii=False)
open(dst_path, "a").write("\n")
print("    kuruldu: " + dst_path)
PY

echo "Claude Code ayarlari kuruldu. Calisan oturumu yeniden baslat."
