# linux-configs

Kisisel Linux ortami: dotfile'lar (kabuk, tmux, Neovim, git), gelistirici araclari ve kurulum betikleri
(Ubuntu / GNOME). Repo **public**; makineye ozel degerler repo'ya girmez (bkz. [docs/guvenlik-ve-testler.md](docs/guvenlik-ve-testler.md)).

## Icindekiler

1. [Hizli baslangic](#hizli-baslangic)
2. [Komut basvurusu](#komut-basvurusu) (her komutun secenekleri)
   - [install.sh](#installsh) · [tools/install-tools.sh](#toolsinstall-toolssh) · [lc-doctor](#lc-doctor) ·
     [lc-help](#lc-help) · [lc-issue-hook](#lc-issue-hook) · [check.sh](#checksh)
   - [Kabuk komutlari](#kabuk-komutlari) (`tm` `tp` `tmw` `tmj` `tmuxt` `cdt` `vimt` `vimj` `yardim`)
   - [git alias'lari](#git-aliaslari)
3. [Kisayollar](#kisayollar): [tmux](#tmux) · [Neovim](#neovim)
4. [Ortam degiskenleri](#ortam-degiskenleri)
5. [Repo icerigi](#repo-icerigi) · [Dokumanlar](#dokumanlar)

## Hizli baslangic

```bash
./install.sh --with-tools   # her seyi kur (apt + cargo/pipx araclari)
lc-doctor                   # bu makine repoyla uyumlu mu, eksik ne var
lc-help                     # komut / kisayol / arac ara
yardim                      # Turkce dokumanlar
```

Dotfile'lar `$HOME` altina **sembolik bagla** kurulur (`~/.bashrc`, `~/.tmux.conf`, `~/.config/nvim/init.lua` ve `lua/`):
repo'daki dosyayi duzenlemek canli ayari da degistirir. Var olan dosya silinmez, `.bak.<tarih>` olarak yana tasinir.
`~/.gitconfig` **kopyalanir** (icindeki kimlik makineye gore degisebilir). Makineye ozel ayarlar `~/.bashrc.local`'a.

## Komut basvurusu

### `install.sh`

Her seyi kurar: nvim, dotfile'lar, tmux eklentileri (sabit commit), git ayari, `~/.local/bin` baglari.
`sudo` gerekir. Tekrar calistirmak guvenli: kurulu olani atlar, var olan dosyayi yedekler.

| Secenek | Ne yapar |
|---|---|
| *(yok)* | nvim + dotfile'lar + gelistirici araclarindan `core` ve `git` gruplari |
| `--with-tools` | **tum** araclari kur: apt gruplari + cargo/pipx araclari (`extra`) |
| `--no-tools` | gelistirici araclarini kurma |
| `--no-dotfiles` | dotfile kurulumunu atla |
| `--with-wireshark` | wireshark'i da kur |
| `-h` | yardim |

### `tools/install-tools.sh`

Gelistirici araclarini gruplar halinde kurar. Zaten kurulu olani ve apt'te bulunmayani atlar, hatalari sonda raporlar.

```bash
tools/install-tools.sh [--dry-run] [grup...]    # varsayilan: core git
tools/install-tools.sh all                      # tum gruplar
```

| Parametre | Ne yapar |
|---|---|
| `--dry-run` | Ne kurulacagini yazar, hicbir sey kurmaz |
| `core` | varsayilan: cppcheck, clang-tidy, clang-format, bear, git-delta, fd-find, bat, eza, zoxide, direnv, shellcheck |
| `c-debug` | ltrace, rr, lcov, doxygen |
| `net` | tshark, binwalk, qemu-user-static, tio (seri konsol), lnav, moreutils, mosh, sshfs |
| `git` | varsayilan: tig, pre-commit |
| `misc` | entr, hyperfine, ncdu, duf, just, tmuxp, httpie, tldr |
| `dev` | ripgrep, git-absorb, gping |
| `extra` | apt'te olmayanlar: `cargo install --locked` (surum sabitli, derleme dakikalar surer) ve `uv` (pipx). starship, atuin, watchexec, dust, difftastic, ast-grep, procs, tokei, xh |
| `all` | hepsi |

Not: `mise` icin rustc 1.95 gerekir, elle kurulur ([docs/araclar.md](docs/araclar.md)). Her aracin ne ise yaradigi ve
ornek kullanimi: `lc-help tool <kelime>` ya da [docs/araclar.md](docs/araclar.md).

### `lc-doctor`

Kurulumun repoyla uyumunu denetler ve her eksik icin nasil duzeltilecegini soyler.

| Komut | Ne yapar |
|---|---|
| `lc-doctor` | tam rapor |
| `lc-doctor -q` | yalniz sorunlari goster |
| `lc-doctor -h` | yardim |

Bolumler: baglar, gerekli programlar, tmux eklentileri (sabit commit), `~/.fzf.bash`, neovim, kabuk ortami, istege bagli araclar.
Cikti `ok` (iyi), `WARN` (istege bagli / bakilmali), `MISS` (zorunlu parca yok; cikis kodu 1).
Ayrinti: [docs/lc-doctor.md](docs/lc-doctor.md).

### `lc-help`

Komut, git alias'i, tmux/nvim kisayolu ve arac arama. Arayuz Ingilizce; indeks `# help:` satirlarindan, `bind-key -N`
notlarindan, nvim keymap aciklamalarindan ve `help/tools.tsv`'den **otomatik** uretilir (kaynak degisince kendini yeniler).

| Komut | Ne yapar |
|---|---|
| `lc-help` | her seyde bulanik arama (fzf; terminal degilse duz liste) |
| `lc-help <kelime>...` | tum kelimeleri iceren kayitlar (buyuk/kucuk harf fark etmez) |
| `lc-help cmd\|env\|git\|local\|tmux\|nvim\|tool [kelime]...` | yalniz o tur |
| `lc-help -k`, `--keys [kelime]` | yalniz tmux ve Neovim kisayollari |
| `lc-help -l`, `--list` | turler ve kayit sayilari |
| `lc-help --pick [kelime]` | fzf ile sec, yazilacak metni yazdir (`Ctrl-x h` bunu komut satirina yazar) |
| `lc-help --tsv [kelime]` | ham indeks satirlari (tur, anahtar, aciklama, kaynak, ornek) |
| `lc-help --popup` | secimden sonra tus bekler (tmux `Prefix F1` bunu kullanir) |
| `lc-help --rebuild` | indeksi simdi yeniden uret |
| `lc-help -h`, `--help` | yardim |

Turler: `cmd` kabuk komutlari, `env` ortam degiskenleri, `git` alias'lar, `local` makineye ozel kayitlar, `tmux`, `nvim`,
`tool` araclar (aciklama + calistirilabilir ornek). Girislerden biri:

- `Ctrl-x h` (bash): sec, ornek komut satirina yazilir (calistirilmaz). tmux/nvim tusu secilirse ayrintisi gosterilir.
- `Prefix F1` (tmux): popup. `<leader>fl` (Neovim): Telescope, Enter metni panoya kopyalar.
- Makineye ozel kayitlar: `~/.bashrc.local` icinde `# help: komut -- aciklama` satiri ya da
  `~/.config/lc-help/extra.tsv` (`anahtar<TAB>aciklama<TAB>ornek`). Repo'ya girmez.

Ornekler:

```bash
lc-help git                 # git alias'lari
lc-help tool serial         # seri konsol araclari
lc-help -k pane             # pane ile ilgili tuslar
lc-help --tsv ripgrep       # script icin ham cikti
```

Ayrinti: [docs/lc-help.md](docs/lc-help.md).

### `lc-issue-hook`

Baska bir repoya `Issue: KEY-123` satirini zorunlu kilan `commit-msg` kancasini kurar (Gerrit bu satirsiz push'u reddeder).
Merge, `fixup!`, `squash!` ve `amend!` mesajlarini atlar. Yabanci bir kanca varsa dokunmaz. Bu repoda (linux-configs) calismaz.

| Komut | Ne yapar |
|---|---|
| `lc-issue-hook install [repo]` | kancayi repoya bagla (varsayilan: bulunulan repo) |
| `lc-issue-hook uninstall [repo]` | kaldir (yalniz bizim bagimizsa) |
| `lc-issue-hook status [repo]` | kurulu mu |

### `check.sh`

Tek komutla tum kontroller: sozdizimi, shellcheck, kabuk / kanca / arac / dokuman testleri, tmux eklentisi ve nvim testleri.

| Komut | Ne yapar |
|---|---|
| `./check.sh` | hepsi (tmux eklentisi ve nvim testi eklenti indirir, ag gerekir) |
| `./check.sh --fast` | ag gerektiren testleri atla |
| `SHELLCHECK=/yol/shellcheck ./check.sh` | baska bir shellcheck ikilisi kullan |

Test bolumu tek tek de calisir: `bash tests/<ad>_test.sh`.

### Kabuk komutlari

`bash/.bashrc` ile gelir; hepsinde `Tab` tamamlamasi vardir.

| Komut | Parametre | Ne yapar |
|---|---|---|
| `tm [isim]` | session adi (varsayilan `main`) | tmux session'ina baglan ya da olustur; tmux icindeyse `switch-client` ile gecer |
| `tp [filtre]` | baslangic filtresi | `TP_ROOT` altindaki klasorlerden birini `fzf` ile sec, o klasorde klasor adli session ac. Tek eslesme varsa sormadan acar |
| `tmw <session:pencere> [hedef]` | kaynak pencere, hedef session (varsayilan: simdiki) | baska session'daki pencereyi buraya tasi. Ornek: `tmw work:2` |
| `tmj [session:pencere] [hedef]` | kaynak, hedef pencere (varsayilan: simdiki) | pencereyi pane olarak birlestir. Parametresiz: secim menusu (fzf) |
| `tmuxt <bilet>` | bilet adi | bilet icin tmux ortami: seri konsol (`tio`/`minicom`), notlar (`vimt`), ag ayari. `RTS` ile baslayan biletler `192.168.111.200`, digerleri `192.168.2.200` |
| `cdt <bilet>` | bilet adi | `~/Documents/FixedIssues/<bilet>` klasorune git (yoksa olusturur) |
| `vimt <bilet>` | bilet adi | biletin `notes.md` dosyasini `$EDITOR` ile ac |
| `vimj <bilet>` | bilet adi | biletin `notes.jira` dosyasini `$EDITOR` ile ac |
| `yardim [konu]` | konu (varsayilan `ozet`) | Turkce dokumanlari sayfala |
| `yardim -l` | - | konulari listele |
| `yardim ara <kelime>` | aranan | dokumanlarda ara |
| `lc-help` | bkz. [lc-help](#lc-help) | komut / kisayol / arac ara |
| `z <klasor>`, `zi` | klasor adi | sik gidilen klasore atla (zoxide kuruluysa) |
| `lt` | - | 2 seviyeli agac listesi (eza kuruluysa) |

Kisayollar: `Ctrl-x h` lc-help secici, `Ctrl-r` gecmis arama (atuin kuruluysa dizin / cikis kodu ile), `Ctrl-t` dosya sec
(fd + bat onizleme), `Alt-c` klasore gir.
`atuin`: `install-tools.sh extra` bash gecmisini bir kez iceri alir (`atuin import auto`) ve yukari oku tum gecmise acar; elle: `atuin import auto`.
Kuruluysa otomatik etkinlesenler: starship (prompt), mise, atuin, zoxide, direnv.

### git alias'lari

`git/.gitconfig` ile gelir (`lc-help git` hepsini aciklamasiyla listeler).

| Alias | Karsiligi / ne yapar |
|---|---|
| `a`, `aa` | `add`, `add .` |
| `c`, `ca`, `cm "mesaj"` | `commit`, `commit --amend`, `commit -m` |
| `cp`, `cpc` | `cherry-pick`, `cherry-pick --continue` |
| `d`, `ds` | `diff`, `diff --staged` |
| `s`, `su` | `status`, `status -uno` |
| `st`, `sp` | `stash`, `stash pop` |
| `pr`, `rc` | `pull --rebase`, `rebase --continue` |
| `b <dosya>` | `blame --` |
| `bl 10,20 DOSYA` | satir araliginin blame'i |
| `sh [N]` | son N commit'i goster (varsayilan 1) |
| `l`, `ll` | tek satirlik log; `ll` yazar ve goreli tarih ekler |
| `sa [-v] [derinlik] [klasor]` | altindaki **tum** git repolarinin durumu; `-v` degisiklikleri ve push edilmemis commit'leri listeler |
| `v`, `va`, `vm "mesaj"` | yazar `veli demirel` olarak commit, amend, mesajli commit |

Ayarlar: `pull.rebase`, `fetch.prune`, `rerere`, `diff.algorithm=histogram`, `merge.conflictstyle=zdiff3`.

## Kisayollar

### tmux

Prefix `Ctrl-a` (`Ctrl-b` kaldirildi). Tam liste: `lc-help -k` ya da `.tmux.conf` sonundaki yorum.

| Tus | Ne yapar |
|---|---|
| `Ctrl-h/j/k/l` | pane / nvim split'i degistir (vim-tmux-navigator) |
| `Prefix` `\|` / `-` | saga / alta bol (ayni klasorde) |
| `Prefix` `c` | ayni klasorde yeni pencere |
| `Prefix` `h/j/k/l`, `H/J/K/L` | pane'e gec, pane boyutu |
| `Prefix` `r` | config'i yeniden yukle |
| `Prefix` `Ctrl-s` / `Ctrl-r` | oturumlari kaydet / geri yukle (resurrect + continuum) |
| `Prefix` `Ctrl-v` | copy mode (`v` sec, `y` panoya) |
| `Prefix` `P`, sag tik | panodan yapistir |
| `Prefix` `F1` | `lc-help` popup'i |
| `Prefix` `Tab` | ekrandaki metinden (URL, yol, hash, IP) sec, kopyala ya da yaz (extrakto) |
| `Prefix` `Ctrl-h/j/k/l` | o tusu kabuga yolla (`Ctrl-k` / `Ctrl-l` icin) |

Ayrinti: [docs/tmux.md](docs/tmux.md).

### Neovim

Leader `Space`, Neovim >= 0.11. Her kisayolun aciklamasi var; `<F1>` ile aranir.

| Tus | Ne yapar |
|---|---|
| `<F1>` / `<leader>fk` | kisayol ara |
| `<leader>fl` | `lc-help` indeksinde ara |
| `<leader>ff` `fg` `fw` `fs` | dosya, grep, imlecteki kelime, bu dosyada ara |
| `<leader>fR` | proje capinda bul ve degistir |
| `<leader>e` | dosya agaci |
| `gd` `grr` `K` `grn` `gra` | tanima git, referanslar, hover, yeniden adlandir, code action |
| `<leader>cf` | bicimlendir (clang-format / LSP) |
| `<leader>mm` `mc`, `:Make [arg]` | asenkron derle, hatalar quickfix'e |
| `]q` `[q` | quickfix'te sonraki / onceki |
| `<leader>xx` | diagnostics paneli |
| `s` | ekranda 2 tusla atla (flash) |
| `<leader>aa` `am` | dosyayi sabitle / sabitlenenler menusu |
| `<leader>db` `dc` | breakpoint, debug baslat (gdb) |
| `<leader>gn` | git arayuzu (Neogit) |
| `<leader>u` | undo agaci |

`:Rg <aranan> [klasor]` sonuclari quickfix'e yazar. Proje basina ayar: proje kokune `.nvim.lua` (ilk seferde `:trust`).
Ayrinti: [docs/nvim.md](docs/nvim.md).

## Ortam degiskenleri

Makineye ozel olanlar `~/.bashrc.local`'a yazilir (repo'ya girmez).

| Degisken | Anlami | Varsayilan |
|---|---|---|
| `TP_ROOT` | `tp`'nin klasorlerini listeledigi dizin | `$HOME` |
| `TMUXT_SERIAL` | `tmuxt`'nin seri portu | `/dev/serial/by-id` altindaki ilk aygit, yoksa `/dev/ttyUSB0` |
| `TMUXT_ETH` | `tmuxt`'nin ag arayuzu | `eth0` |
| `LC_HELP_CACHE` | lc-help indeks dizini | `~/.cache/lc-help` |
| `LC_HELP_BASHRC_LOCAL` | `# help:` satirlari okunan dosya | `~/.bashrc.local` |
| `LC_HELP_EXTRA` | ek lc-help kayitlari (TSV) | `~/.config/lc-help/extra.tsv` |
| `LC_DENY_FILE` | pre-commit'in yerel yasak desenleri (satir basina bir `grep -E` deseni) | `~/.config/linux-configs/deny-patterns` |
| `TOOLS_SUDO` | `install-tools.sh`'in sudo komutu (bos = sudo kullanma) | `sudo` |
| `SHELLCHECK` | `check.sh`'in shellcheck yolu | `PATH`'teki |

## Repo icerigi

| Yol | Icerik |
|---|---|
| `bash/.bashrc` | Kabuk: `tm`, `tp`, `tmw`, `tmj`, bilet yardimcilari, tamamlamalar, `yardim`, arac entegrasyonlari |
| `tmux/.tmux.conf` | Prefix `Ctrl-a`, oturum kalicligi (resurrect + continuum), nvim ile pane gezintisi |
| `nvim/` | Neovim: arama, kisayol bulma, LSP, derleme, debug (`init.lua` + `lua/cfg/`) |
| `git/` | `.gitconfig` (alias'lar), `delta.gitconfig` (delta kuruluysa), `hooks/commit-msg` |
| `bin/lc-help`, `help/` | komut, git alias, kisayol ve arac arama |
| `bin/lc-doctor` | kurulum denetimi |
| `bin/lc-issue-hook` | `Issue: KEY` commit-msg kancasi kurucusu |
| `tools/install-tools.sh` | gelistirici araclarini gruplar halinde kurar |
| `.githooks/pre-commit` | commit oncesi gizli bilgi taramasi (anahtar, token, yerel desenler; atlamak: `git commit --no-verify`) |
| `lib/link.sh` | kurulum yardimcilari |
| `vim/` | eski vim ortami; ana kurulum cagirmaz |
| `docs/` | dokumanlar |
| `check.sh`, `tests/`, `nvim/tests/` | tek komutlu kontrol ve testler |

## Dokumanlar

Terminalde: `yardim <konu>`.

| Konu | Sayfa |
|---|---|
| Tek sayfalik ozet kart | [docs/ozet.md](docs/ozet.md) |
| Komut/kisayol arama (`lc-help`) | [docs/lc-help.md](docs/lc-help.md) |
| Kurulum denetimi ve commit kancasi (`lc-doctor`, `lc-issue-hook`) | [docs/lc-doctor.md](docs/lc-doctor.md) |
| Kabuk komutlari ve ortam degiskenleri | [docs/kabuk.md](docs/kabuk.md) |
| tmux | [docs/tmux.md](docs/tmux.md) |
| Neovim | [docs/nvim.md](docs/nvim.md) |
| Gelistirici araclari | [docs/araclar.md](docs/araclar.md) |
| Guvenlik ve testler | [docs/guvenlik-ve-testler.md](docs/guvenlik-ve-testler.md) |

Claude Code ayarlari bu repoda tutulmuyor; ayri repoda.
