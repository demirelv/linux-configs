# linux-configs

Kisisel Linux dotfile'lari ve kurulum script'leri (Ubuntu / GNOME).

| Klasor | Icerik |
|---|---|
| `bash/.bashrc` | Shell ayarlari, ticket yardimcilari, tmux fonksiyonlari (`tm`, `tmw`, `tmj`) |
| `tmux/.tmux.conf` | Prefix `Ctrl-a`, vi copy-mode, pano entegrasyonu |
| `git/.gitconfig` | Alias'lar (`sa`, `bl`, `v`, `va`, `vm` ...) |
| `nvim/` | Neovim C/C++ ortami (`init.lua` + kurulum) |
| `vim/` | Eski vim ortami (Vundle). Ana kurulum cagirmaz, elle calistirilir |

## Kurulum

```bash
./install.sh                    # nvim + araclar + dotfile'lar
./install.sh --with-wireshark   # wireshark'i da kur
./install.sh --no-dotfiles      # dotfile kopyalamayi atla
```

`install.sh` dotfile'lari `$HOME` altina **kopyalar**; farkli bir dosya varsa `.bak.<tarih>` yedegi alir.
Makineye ozel satirlar (nvm, takma adlar vb.) olan bir `~/.bashrc` uzerine yazilirsa yedekten geri tasinmalidir.

## tmux fonksiyonlari

| Komut | Ne yapar |
|---|---|
| `tm [isim]` | Session'a baglan ya da olustur (varsayilan `main`). tmux icindeyse `switch-client` ile gecer. |
| `tmw kaynak [hedef]` | Baska session'daki pencereyi mevcut (ya da hedef) session'a tasi. Ornek: `tmw work:2` |
| `tmj [kaynak] [hedef]` | Baska session'daki pencereyi mevcut pencereye pane olarak birlestir. Parametresiz: tum pencereler arasindan sectirir (fzf, yoksa numarali menu). |

## Neovim (`nvim/init.lua`)

Neovim >= 0.11 gerekir. Eklentiler sabitlenmez: `lazy-lock.json` repo'da tutulmaz, her
`Lazy sync` en guncel surumu alir. `nvim-treesitter` icin `tree-sitter` CLI gerekir
(`nvim/install.sh` kurar).

Tum kisayollarin aciklamasi var. Hepsini aramak icin:

| Tus | Ne yapar |
|---|---|
| `<F1>` ya da `<leader>fk` | Kisayol ara (popup, yazdikca filtreler) |
| `<leader>fc` | Komut ara |
| `<leader>?` | Bu buffer'in kisayollari (which-key) |
| `<leader>` yazip bekle | which-key, gruplari ve devamini gosterir |

Popup ile arama (Telescope, ortada, onizlemeli):

| Tus | Ne yapar |
|---|---|
| `<leader>ff` / `<F4>` | Dosya ara |
| `<leader>fg` / `<F5>` | Proje ici grep (rg). `<C-k>` metni tirnaklar, `<C-i>` `--iglob` ekler: `"foo" --iglob *.c` |
| `<leader>fw` | Imlecteki kelimeyi ya da secimi grep'le |
| `<leader>fs` | Bu dosyada ara |
| `<leader>fb`, `fo`, `fr`, `fd`, `fh` | Buffer, son dosyalar, son arama, diagnostics, yardim |

`:Rg <aranan> [klasor]` sonuclari quickfix'e yazar; `nvim-bqf` onizleme gosterir.
`<C-q>` quickfix'i acar/kapatir.

Notlar: `gr` bilerek bagli degil (Neovim varsayilani `grr` referanslar, `grn` yeniden adlandir,
`gra` code action). `<C-v>` blok secimi icin birakildi; panoya yapistirmak `<leader>p`.

Test (taze kurulum, gecici dizinde; ag gerekir, gercek config'e dokunmaz):

```bash
bash nvim/tests/run.sh
```

## Not

Claude Code ayarlari bu repoda tutulmuyor; ayri repoda.
