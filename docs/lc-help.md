# lc-help

Bu sayfa: `lc-help` komutu: bu repodaki kabuk komutlarini, tmux ve Neovim kisayollarini ve araclari tek yerde
arayan Ingilizce hizli yardim. Kimin icin: "su komut neydi, tmux'ta su tus ne yapiyor" diye hizlica bakmak isteyen.
Uzun anlatim icin `yardim` (Turkce docs) kalir; `lc-help` aramadir.

Icindekiler: kullanim, her yerden acma, veri nereden gelir, yeni girdi ekleme, testler.

## Kullanim

| Komut | Ne yapar |
|---|---|
| `lc-help` | Her sey uzerinde bulanik arama (`fzf`; sagda secilen satirin ayrintisi) |
| `lc-help reload` | "reload" gecen girdiler (birden cok kelimede hepsi eslesmeli, buyuk/kucuk harf farketmez) |
| `lc-help tmux` / `nvim` / `cmd` / `env` / `git` / `local` / `tool` | Yalniz o turun girdileri; arkasina kelime ekleyebilirsin (`lc-help tmux clipboard`) |
| `lc-help -k [kelime]` | Yalniz tus kisayollari (tmux + Neovim) |
| `lc-help -l` | Turler ve girdi sayilari |
| `lc-help --pick [kelime]` | `fzf` ile sec, yazilacak metni (ornek ya da komut) stdout'a bas; tus kisayolunda metin yerine ayrinti gosterir |
| `lc-help --tsv [kelime]` | Ham indeks satirlari (tur, anahtar, aciklama, kaynak, ornek); betik ve Neovim icin |
| `lc-help --rebuild` | Indeksi simdi yeniden uret |

`lc-help <Tab>` turleri ve secenekleri tamamlar.

Terminalde degilsen (boruya yonlendirme, betik) duz liste basar. Eslesme yoksa mesaj verir ve 1 ile cikar.

## Her yerden acma

| Nerede | Tus |
|---|---|
| Kabuk | `Ctrl-x h`: sec, metin komut satirina (imlecin yerine) yazilir, calistirilmaz |
| tmux | `Prefix` + `F1` (popup; bir tusa basinca kapanir) |
| Neovim | `<F1>` (Neovim kisayollari); `<leader>fl` (tum `lc-help` indeksi; Enter metni panoya kopyalar) |

## Veri nereden gelir

Hicbir sey iki kez yazilmaz; indeks su kaynaklardan uretilir ve kaynak degisince kendiliginden yenilenir
(onbellek: `~/.cache/lc-help/index.tsv`):

| Tur | Kaynak |
|---|---|
| `cmd`, `env` | `bash/.bashrc` icindeki `# help: kullanim -- aciklama` ve `# help-env: DEGISKEN -- aciklama` satirlari |
| `tmux` | `tmux/.tmux.conf` icindeki her `bind-key -N "aciklama"` notu (tmux'un varsayilan notlari da dahil) |
| `nvim` | Her Neovim kisayolunun `desc` alani |
| `tool` | `help/tools.tsv`: arac satirlari (apt paketi ya da 4. sutunu `extra` olan apt-disi arac) ve `usage` satirlari (komut basina hazir ornek: `lc-help tool rg type`, `lc-help tool atuin`) |

| `git` | `git/.gitconfig` `[alias]` bolumu; alias'in ustundeki `# help: aciklama` satiri aciklama olur, yoksa acilimi gosterilir |
| `local` | Bu makineye ozel (repoya girmez): `~/.bashrc.local` icindeki `# help:` satirlari ve `~/.config/lc-help/extra.tsv` (`anahtar<TAB>aciklama<TAB>ornek`). Dosya eklenince/silinince indeks kendiliginden yenilenir |

## Yeni girdi ekleme

- Yeni kabuk fonksiyonu: tanimin ustune `# help: ad [arguman] -- Ingilizce aciklama` satiri ekle.
- Yeni tmux kisayolu: `bind-key -N "Ingilizce aciklama" tus komut` (notsuz `bind` testi kirmizi yapar).
- Yeni Neovim kisayolu: `{ desc = "English description" }` ver (zaten zorunlu).
- Yeni git alias'i: `git/.gitconfig`'te alias'in ustune `# help: English description`.
- Kendi notun (yalniz bu makine): `~/.config/lc-help/extra.tsv`'e `anahtar<TAB>aciklama<TAB>ornek` satiri.
- Yeni arac: hem `tools/install-tools.sh` hem `help/tools.tsv` (ad, aciklama, istege bagli ornek).

Aciklamalar Ingilizce olmali; test, indekste ASCII disi karakter ve bilinen Turkce kelimeleri yakalar.

## Testler

`tests/lc_help_test.sh`: indeks kaynaklarla uyumlu mu (her fonksiyon, her `bind`, her arac), arama ve filtreler,
bayat indeksin yenilenmesi ve gercek bir pty icinde `fzf` yolu. Bkz. [guvenlik-ve-testler.md](guvenlik-ve-testler.md).
