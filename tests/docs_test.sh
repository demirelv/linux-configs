#!/usr/bin/env bash
# Dokuman tutarliligi: baglantilar, INDEX tamligi, ilk satirlar ve dokumanin koddan sapmasi.
# Dokuman eskirse (kisayol silindi, arac listeden cikti) bu test kirmizi olur.
set -Eeuo pipefail

REPO="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
failed=0
ok() { local msg="$1"; shift; if "$@"; then echo "PASS $msg"; else echo "FAIL $msg"; failed=$((failed + 1)); fi; }

cd "$REPO"

# 1) INDEX.md her sayfayi listeler
missing=""
for f in docs/*.md; do
    name="${f#docs/}"; [ "$name" = INDEX.md ] && continue
    grep -qF "($name)" docs/INDEX.md || missing="$missing $name"
done
ok "INDEX.md tum sayfalari listeler${missing:+ (eksik:$missing)}" test -z "$missing"

# 2) her sayfa baslikla baslar ve ilk 6 satirda amacini soyler
bad=""
for f in docs/*.md; do
    head -n1 "$f" | grep -q '^# ' || bad="$bad $f(baslik)"
    head -n6 "$f" | grep -q 'Bu sayfa:' || bad="$bad $f(Bu sayfa:)"
done
ok "her sayfa baslikla baslar ve 'Bu sayfa:' satiri var${bad:+ (sorun:$bad)}" test -z "$bad"

# 3) goreli baglantilar ve #capalar gercek dosya/baslik
broken="$(python3 -I - "$REPO" <<'PY'
import os, re, sys
root = sys.argv[1]
def slug(h):
    h = h.strip().lower()
    h = re.sub(r"[^\w\- ]", "", h)          # noktalama gider
    return h.replace(" ", "-")
files = [os.path.join(root, "README.md")] + [os.path.join(root, "docs", f) for f in sorted(os.listdir(os.path.join(root, "docs"))) if f.endswith(".md")]
bad = []
for f in files:
    text = open(f, encoding="utf-8").read()
    for target in re.findall(r"\]\(([^)]+)\)", text):
        if re.match(r"^(https?:|mailto:)", target):
            continue
        path, _, anchor = target.partition("#")
        dest = os.path.normpath(os.path.join(os.path.dirname(f), path)) if path else f
        if not os.path.exists(dest):
            bad.append(f"{os.path.relpath(f, root)} -> {target} (dosya yok)"); continue
        if anchor and dest.endswith(".md"):
            heads = [slug(m) for m in re.findall(r"^#{1,6} (.+)$", open(dest, encoding="utf-8").read(), flags=re.M)]
            if anchor not in heads:
                bad.append(f"{os.path.relpath(f, root)} -> {target} (baslik yok)")
print("; ".join(bad))
PY
)"
ok "README/docs baglantilari ve capalari gecerli${broken:+ ($broken)}" test -z "$broken"

# 4) tools/install-tools.sh'deki her paket docs/araclar.md'de anlatilmis
pk="$(grep -E '^\s+\[[a-z0-9-]+\]="' tools/install-tools.sh | sed -E 's/^[^"]*"//; s/".*$//' | tr ' ' '\n' | sort -u)"
undoc=""
for p in $pk; do grep -qF "\`$p\`" docs/araclar.md || undoc="$undoc $p"; done
ok "betikteki tum paketler araclar.md'de var${undoc:+ (eksik:$undoc)}" test -z "$undoc"

# 4b) tools.tsv'deki apt-disi (extra) araclar araclar.md'de kurulum satiriyla var
noextra=""
for p in $(awk -F'\t' '!/^#/ && $4 == "extra" { print $1 }' help/tools.tsv); do
    grep -qE "^\| \`$p\` .*(cargo install|pipx install)" docs/araclar.md || noextra="$noextra $p"
done
ok "apt-disi araclarin kurulum satiri araclar.md'de var${noextra:+ (eksik:$noextra)}" test -z "$noextra"

# 5) dokumanda gecen `<leader>xx` kisayollari gercekten tanimli (docs/nvim.md, docs/ozet.md)
lost=""
for key in $(grep -ohE '`<leader>[A-Za-z?]+`' docs/nvim.md docs/ozet.md | tr -d '`' | sort -u); do
    grep -rqF "\"$key\"" nvim/init.lua nvim/lua || lost="$lost $key"
done
ok "dokumandaki <leader> kisayollari kodda tanimli${lost:+ (tanimsiz:$lost)}" test -z "$lost"

# 6) yardim konulari = docs sayfalari (INDEX haric) ve README hepsine baglanir
nolink=""
for f in docs/*.md; do
    name="${f#docs/}"; [ "$name" = INDEX.md ] && continue
    grep -qF "docs/$name" README.md || nolink="$nolink $name"
done
ok "README her sayfaya baglanir${nolink:+ (eksik:$nolink)}" test -z "$nolink"

echo
if [ "$failed" -eq 0 ]; then echo "TUMU GECTI"; else echo "$failed KONTROL BASARISIZ"; exit 1; fi
