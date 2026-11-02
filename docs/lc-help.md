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
| `lc-help tmux` / `nvim` / `cmd` / `env` / `tool` | Yalniz o turun girdileri; arkasina kelime ekleyebilirsin (`lc-help tmux clipboard`) |
| `lc-help -k [kelime]` | Yalniz tus kisayollari (tmux + Neovim) |
| `lc-help -l` | Turler ve girdi sayilari |
| `lc-help --rebuild` | Indeksi simdi yeniden uret |

Terminalde degilsen (boruya yonlendirme, betik) duz liste basar. Eslesme yoksa mesaj verir ve 1 ile cikar.

## Her yerden acma

| Nerede | Tus |
|---|---|
| Kabuk | `Ctrl-x h` |
| tmux | `Prefix` + `F1` (popup; bir tusa basinca kapanir) |
| Neovim | `<F1>` (kisayol arama; Neovim'in kendi kisayollari icin) |

## Veri nereden gelir

Hicbir sey iki kez yazilmaz; indeks su kaynaklardan uretilir ve kaynak degisince kendiliginden yenilenir
(onbellek: `~/.cache/lc-help/index.tsv`):

| Tur | Kaynak |
|---|---|
| `cmd`, `env` | `bash/.bashrc` icindeki `# help: kullanim -- aciklama` ve `# help-env: DEGISKEN -- aciklama` satirlari |
| `tmux` | `tmux/.tmux.conf` icindeki her `bind-key -N "aciklama"` notu (tmux'un varsayilan notlari da dahil) |
| `nvim` | Her Neovim kisayolunun `desc` alani |
| `tool` | `help/tools.tsv` |

## Yeni girdi ekleme

- Yeni kabuk fonksiyonu: tanimin ustune `# help: ad [arguman] -- Ingilizce aciklama` satiri ekle.
- Yeni tmux kisayolu: `bind-key -N "Ingilizce aciklama" tus komut` (notsuz `bind` testi kirmizi yapar).
- Yeni Neovim kisayolu: `{ desc = "English description" }` ver (zaten zorunlu).
- Yeni arac: hem `tools/install-tools.sh` hem `help/tools.tsv` (ad, aciklama, istege bagli ornek).

Aciklamalar Ingilizce olmali; test, indekste ASCII disi karakter ve bilinen Turkce kelimeleri yakalar.

## Testler

`tests/lc_help_test.sh`: indeks kaynaklarla uyumlu mu (her fonksiyon, her `bind`, her arac), arama ve filtreler,
bayat indeksin yenilenmesi ve gercek bir pty icinde `fzf` yolu. Bkz. [guvenlik-ve-testler.md](guvenlik-ve-testler.md).
