# linux-configs ozet karti

Bu sayfa: en cok kullanilan komut ve tuslarin tek sayfalik ozeti. Ayrintilar icin `yardim <konu>`.
Konular: `yardim -l` (kabuk, tmux, nvim, araclar, guvenlik-ve-testler). Bir sey ararken: `yardim ara <kelime>`.

## Kabuk

| Komut | Ne yapar |
|---|---|
| `tm [isim]` | tmux session'ina baglan ya da olustur (tmux icindeyse gecer) |
| `tp [filtre]` | `TP_ROOT` altindaki klasorlerden birini sec, o klasorde session ac |
| `tmw session:pencere` | Baska session'daki pencereyi buraya tasi |
| `tmj [session:pencere]` | Pencereyi pane olarak birlestir (parametresiz: secim menusu) |
| `cdt` `vimt` `vimj` `tmuxt <bilet>` | Bilet klasorune git / notes.md / notes.jira / tmux ortami (Tab tamamlar) |
| `lc-help [kelime]` | Komut, tmux/nvim kisayolu, arac ara (Ingilizce; `Ctrl-x h` secileni komut satirina yazar, tmux `Prefix F1`, nvim `<leader>fl`) |
| `yardim [konu]` | Bu dokumanlar (Turkce) |
| `lc-doctor` | Bu makine repoyla uyumlu mu: baglar, programlar, eklentiler, eksik araclar |
| `lc-issue-hook install` | Bu repoda commit mesajinda `Issue: KEY-123` satiri zorunlu olsun (Gerrit) |
| `z <klasor>` | En cok gittigin klasore atla (zoxide kuruluysa) |

## tmux (prefix `Ctrl-a`)

| Tus | Ne yapar |
|---|---|
| `Ctrl-h/j/k/l` | Pane / nvim split'i degistir |
| `Prefix` + `\|` `-` `c` | Sag bol, alta bol, yeni pencere |
| `Prefix` + `r` | Config'i yenile |
| `Prefix` + `Ctrl-s` / `Ctrl-r` | Oturumlari kaydet / geri yukle |
| `Prefix` + `Ctrl-v` | Copy mode (`v` sec, `y` kopyala) |
| `Prefix` + `Ctrl-h/j/k/l` | O tusu kabuga yolla (`Ctrl-k`, `Ctrl-l` icin) |

## Neovim (leader = `Space`)

| Tus | Ne yapar |
|---|---|
| `<F1>` / `<leader>fk` | Kisayol ara |
| `<leader>ff` `fg` `fw` `fs` | Dosya, grep, kelime-grep, bu dosyada ara |
| `<leader>fR` | Proje capinda bul-degistir |
| `<leader>e` | Dosya agaci |
| `gd` `grr` `K` `grn` `gra` | Tanima git, referanslar, hover, yeniden adlandir, code action |
| `<leader>cf` | Biçimlendir (clang-format / LSP) |
| `<leader>mm` | Derle (asenkron, hatalar quickfix'e) |
| `<leader>xx` | Diagnostics paneli |
| `]q` `[q` | Quickfix'te sonraki / onceki |
| `s` | Ekranda atla (flash) |
| `<leader>aa` `am` | Dosyayi sabitle / sabitlenenler menusu |
| `<leader>db` `dc` | Breakpoint, debug baslat (gdb) |
| `<leader>gn` | Git arayuzu (Neogit) |

## Gunluk akis ornegi

```bash
tp                      # projeyi sec -> o klasorde tmux session'i
tmuxt RTS-1234          # bilet icin: seri konsol + notlar + ag ayari
bear -- make            # compile_commands.json (clangd icin)
# nvim: <leader>mm derle, hatalar quickfix'te, ]q ile gez, <leader>cf biçimlendir
```
