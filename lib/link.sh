#!/usr/bin/env bash
# Ortak kurulum yardimcilari. install.sh ve nvim/install.sh tarafindan `source` edilir.

# link_file <kaynak> <hedef>: hedefi kaynaga sembolik baglar.
#  - zaten dogru bagliysa dokunmaz (tekrar calistirmak guvenli)
#  - hedefte baska bir dosya/bag varsa silmez, <hedef>.bak.<tarih> adiyla yana tasir
link_file() {
    local src="$1" dst="$2" stamp
    stamp="$(date +%Y%m%d-%H%M%S)"
    mkdir -p -- "$(dirname -- "$dst")"
    if [ -L "$dst" ] && [ "$(readlink -f -- "$dst")" = "$(readlink -f -- "$src")" ]; then
        echo "    bagli: $dst"
        return 0
    fi
    if [ -e "$dst" ] || [ -L "$dst" ]; then
        mv -- "$dst" "$dst.bak.$stamp"
        echo "    yedek: $dst.bak.$stamp"
    fi
    ln -s -- "$src" "$dst"
    echo "    baglandi: $dst -> $src"
}

# clone_pinned <url> <hedef-dizin> <commit>: depoyu klonlar ve belirtilen commit'e sabitler.
# Zaten varsa ve commit ayniysa dokunmaz. Sabitleme, calistirilan kodun incelenen surum olmasini saglar.
clone_pinned() {
    local url="$1" dir="$2" sha="$3"
    if [ -d "$dir/.git" ]; then
        if [ "$(git -C "$dir" rev-parse HEAD)" = "$sha" ]; then
            echo "    mevcut: $dir"
            return 0
        fi
    else
        git clone --quiet -- "$url" "$dir"
    fi
    git -C "$dir" checkout --quiet "$sha"
    echo "    kuruldu: $dir @ ${sha:0:7}"
}
