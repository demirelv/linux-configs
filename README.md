# linux-configs

Kisisel Linux ortami: dotfile'lar (kabuk, tmux, Neovim, git), gelistirici araclari ve kurulum betikleri
(Ubuntu / GNOME). Repo **public**; makineye ozel degerler repo'ya girmez (bkz. [docs/guvenlik-ve-testler.md](docs/guvenlik-ve-testler.md)).

## Hizli baslangic

```bash
./install.sh                # nvim, dotfile'lar, tmux eklentileri, gelistirici araclari (core + git)
./install.sh --with-tools   # tum araclari kur  |  --no-tools: araclari atla
lc-help                     # komut/kisayol/arac ara (Ctrl-x h; tmux: Prefix F1)  |  lc-help -k: yalniz tuslar
yardim                      # Turkce dokumanlar: ozet kart  |  yardim -l: konular  |  yardim ara <kelime>
```

Dotfile'lar `$HOME` altina **sembolik bagla** kurulur (`~/.bashrc`, `~/.tmux.conf`, `~/.config/nvim/init.lua` ve `lua/`):
repo'daki dosyayi duzenlemek canli ayari da degistirir. Var olan dosya silinmez, `.bak.<tarih>` olarak yana tasinir.
`~/.gitconfig` **kopyalanir** (icindeki kimlik makineye gore degisebilir). Makineye ozel ayarlar `~/.bashrc.local`'a.

## Icindekiler

| Yol | Icerik |
|---|---|
| `bash/.bashrc` | Kabuk: `tm`, `tp`, `tmw`, `tmj`, bilet yardimcilari, tamamlamalar, `yardim`, arac entegrasyonlari |
| `tmux/.tmux.conf` | Prefix `Ctrl-a`, oturum kalicligi (resurrect + continuum), nvim ile pane gezintisi |
| `nvim/` | Neovim: arama, kisayol bulma, LSP, derleme, debug (`init.lua` + `lua/cfg/`) |
| `git/` | `.gitconfig` (alias'lar) ve `delta.gitconfig` (delta kuruluysa) |
| `bin/lc-help`, `help/` | `lc-help`: komut, kisayol ve arac arama (Ingilizce) |
| `tools/install-tools.sh` | Gelistirici araclarini gruplar halinde kurar |
| `.githooks/pre-commit` | Commit oncesi gizli bilgi taramasi |
| `lib/link.sh` | Kurulum yardimcilari |
| `vim/` | Eski vim ortami; ana kurulum cagirmaz |
| `docs/` | Dokumanlar ([INDEX](docs/INDEX.md)) |
| `check.sh`, `tests/`, `nvim/tests/` | Tek komutlu kontrol ve testler |

## Dokumanlar

| Konu | Sayfa |
|---|---|
| Tek sayfalik ozet kart | [docs/ozet.md](docs/ozet.md) |
| Komut/kisayol arama (`lc-help`) | [docs/lc-help.md](docs/lc-help.md) |
| Kabuk komutlari ve ortam degiskenleri | [docs/kabuk.md](docs/kabuk.md) |
| tmux | [docs/tmux.md](docs/tmux.md) |
| Neovim | [docs/nvim.md](docs/nvim.md) |
| Gelistirici araclari | [docs/araclar.md](docs/araclar.md) |
| Guvenlik ve testler | [docs/guvenlik-ve-testler.md](docs/guvenlik-ve-testler.md) |

Tum kontrolleri calistirmak icin `./check.sh` (`--fast`: ag gerektirenleri atla).

Claude Code ayarlari bu repoda tutulmuyor; ayri repoda.
