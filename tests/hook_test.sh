#!/usr/bin/env bash
# .githooks/pre-commit testi: gecici git deposunda gercek `git commit` ile.
# Sahte sirlar calisma zamaninda parcalardan birlestirilir; bu dosyada tam bicimleriyle yer almaz.
set -Eeuo pipefail

REPO="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
tmp="$(mktemp -d)"
trap 'rm -rf -- "${tmp:?}" 2>/dev/null || true' EXIT

failed=0
ok() { local msg="$1"; shift; if "$@"; then echo "PASS $msg"; else echo "FAIL $msg"; failed=$((failed + 1)); fi; }
not() { ! "$@"; }

work="$tmp/r"
git init -q "$work"
mkdir -p "$work/.githooks"
cp "$REPO/.githooks/pre-commit" "$work/.githooks/pre-commit"
chmod +x "$work/.githooks/pre-commit"
git -C "$work" config user.name t
git -C "$work" config user.email t@t
git -C "$work" config core.hooksPath .githooks
export LC_DENY_FILE="$tmp/deny"
printf '%s\n' '# yorum satiri' '' 'zzgizlizz' > "$LC_DENY_FILE"

commit() { # commit <dosya-icerigi> [git commit bayraklari...] ; dosya: f.txt
    local content="$1"; shift
    printf '%s\n' "$content" > "$work/f.txt"
    git -C "$work" add f.txt
    git -C "$work" commit -q -m x "$@" 2>"$tmp/err"
}

ok "temiz icerik commit edilir" commit "merhaba dunya"

key="-----BEGIN RSA PRIV""ATE KEY-----"
ok "ozel anahtar basligi engellenir" not commit "$key"
ok "uyari dosya adini soyler" grep -q "f.txt" "$tmp/err"
ok "uyari degerin kendisini basmaz" not grep -q "BEGIN RSA" "$tmp/err"
git -C "$work" reset -q --hard

aws="AK""IA""ABCDEFGHIJKLMNOP"
ok "AWS erisim anahtari engellenir" not commit "$aws"
git -C "$work" reset -q --hard

q="'"
ok "atanmis sir degeri engellenir" not commit "api_key = ${q}abcdefghijklmnopqrstuvwxyz${q}"
git -C "$work" reset -q --hard

ok "yerel desen dosyasindaki desen engellenir" not commit "bu satirda zzgizlizz var"
git -C "$work" reset -q --hard

ok "yorum ve bos satirlar desen sayilmaz (her sey eslesmez)" commit "tamamen zararsiz bir satir"

ok "--no-verify ile atlanabilir" commit "zzgizlizz" --no-verify
ok "sirri silen commit engellenmez (yalniz eklenenler taranir)" commit "temizlendi"

echo
if [ "$failed" -eq 0 ]; then echo "TUMU GECTI"; else echo "$failed KONTROL BASARISIZ"; exit 1; fi
