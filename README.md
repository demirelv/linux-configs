# linux-configs

Kisisel Linux dotfile'lari ve kurulum script'leri (Ubuntu / GNOME).

| Klasor | Icerik |
|---|---|
| `bash/.bashrc` | Shell ayarlari, ticket yardimcilari, tmux fonksiyonlari (`tm`, `tmw`, `tmj`) ve Tab tamamlamasi |
| `tmux/.tmux.conf` | Prefix `Ctrl-a`, vi copy-mode, pano entegrasyonu, oturum kalicligi (resurrect + continuum) |
| `git/.gitconfig` | Alias'lar (`sa`, `bl`, `v`, `va`, `vm` ...) |
| `nvim/` | Neovim C/C++ ortami (`init.lua` + kurulum) |
| `vim/` | Eski vim ortami (Vundle). Ana kurulum cagirmaz, elle calistirilir |
| `lib/link.sh` | Kurulum yardimcilari (`link_file`, `clone_pinned`) |
| `tests/`, `nvim/tests/`, `check.sh` | Testler ve tek komutlu kontrol |

## Kurulum

```bash
./install.sh                    # nvim + araclar + dotfile'lar
./install.sh --with-wireshark   # wireshark'i da kur
./install.sh --no-dotfiles      # dotfile kopyalamayi atla
```

Dotfile'lar `$HOME` altina **sembolik bagla** kurulur (`~/.bashrc`, `~/.tmux.conf`, `~/.config/nvim/init.lua`):
repo'daki dosyayi duzenlemek canli ayari da degistirir, ikisi ayrismaz. Hedefte baska bir dosya varsa
silinmez, `.bak.<tarih>` adiyla yana tasinir. `~/.gitconfig` ise **kopyalanir**, cunku icindeki kullanici
kimligi makineye gore degisebilir.

### Makineye ozel ayarlar: `~/.bashrc.local`

Bu repo **public**. PATH, nvm, bun, hesap takma adlari, kayit defteri adresleri gibi makineye ozel
satirlar `~/.bashrc.local` dosyasina yazilir; `.bashrc` sonunda onu otomatik okur ve dosya repo'ya girmez.
Ornek (mod `600` onerilir):

```bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
export PATH="$HOME/.local/bin:$PATH"
```

### tmux eklentileri

`install.sh`, `tmux-resurrect` ve `tmux-continuum` eklentilerini `~/.tmux/plugins` altina kurar.
Kod her tmux acilisinda calistigi icin ikisi de **sabit commit**'e sabitlenir (`install.sh` icinde);
surum yukseltmek icin commit'i bilincli degistir. Eklentiler yoksa `.tmux.conf` sessizce atlar.

| Tus | Ne yapar |
|---|---|
| `Prefix` + `Ctrl-s` | Oturumlari simdi kaydet |
| `Prefix` + `Ctrl-r` | Son kaydi geri yukle |

`continuum` periyodik kaydeder ve tmux sunucusu acilirken son kaydi geri yukler. Otomatik kaydi yalnizca
makinede baska tmux sureci yokken baslatir; ilk acilista kaydin olusmasi bu yuzden gecikebilir.

## tmux fonksiyonlari

| Komut | Ne yapar |
|---|---|
| `tm [isim]` | Session'a baglan ya da olustur (varsayilan `main`). tmux icindeyse `switch-client` ile gecer. |
| `tmw kaynak [hedef]` | Baska session'daki pencereyi mevcut (ya da hedef) session'a tasi. Ornek: `tmw work:2` |
| `tmj [kaynak] [hedef]` | Baska session'daki pencereyi mevcut pencereye pane olarak birlestir. Parametresiz: tum pencereler arasindan sectirir (fzf, yoksa numarali menu). |

Uc komutta da `Tab` tamamlamasi vardir: `tm` session adlarini, `tmw`/`tmj` `session:pencere` adaylarini verir.

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

Tamamlama: LSP baglaninca yazdikca otomatik liste acilir (Neovim'in yerlesik ozelligi, ek eklenti yok).
`<C-n>`/`<C-p>` gez, `<C-y>` kabul et, `<C-e>` kapat, `<C-Space>` elle tetikle. C/C++ projelerinde `clangd`
`compile_commands.json` ister; Makefile projeleri icin `bear -- make` ile uretilir.

### Ek ozellikler (`nvim/lua/cfg/`)

Kod konuya gore ayri dosyalarda: `options.lua`, `build.lua`, `plugins/<konu>.lua`. Kisayollar (hepsinin
aciklamasi var, `<F1>` ile aranir):

| Tus | Ne yapar | Eklenti |
|---|---|---|
| `<leader>cf` | Bicimlendir (`clang-format`, yoksa clangd). Secimde yalniz secim. Kaydederken otomatik **degil**. | conform |
| `<leader>u` | Undo agaci (kalici undo `undofile` ile birlikte) | undotree |
| `s` | Ekranda 2 tusla atla (`f`/`t` davranisi degismez) | flash |
| `<leader>aa`, `am`, `a1`..`a4` | Dosyayi sabitle, sabitlenenler menusu, 1-4. dosyaya git | harpoon (harpoon2 dali) |
| `<leader>fR` | Proje capinda bul ve degistir (`rg`, canli onizleme). Secimde secimi. | grug-far |
| `<leader>xx`, `xX`, `xq`, `xl`, `xt` | Diagnostics (proje/dosya), quickfix, LSP referanslari, TODO paneli | trouble |
| `<leader>ft` | `TODO`/`FIXME`/`HACK` yorumlarini ara | todo-comments |
| `<leader>mm`, `mc`, `:Make [arg]` | `makeprg`'yi **asenkron** calistir (arayuz donmaz), hatalar quickfix'e | `build.lua` |
| `<leader>db`, `dc`, `do`, `di`, `dO`, `dx`, `dr`, `dv` | Breakpoint, baslat/devam, adim (ustunden/icine/disina), bitir, REPL, deger | nvim-dap + `gdb` (>= 14) |
| `<leader>qs`, `ql`, `qd` | Klasorun oturumunu yukle, son oturum, bu oturumu kaydetme | persistence |
| `<leader>gn` | Git arayuzu | Neogit |
| `<leader>cl` | Gorunmez karakterleri (tab, satir sonu bosluk) ac/kapat | - |
| `<C-h/j/k/l>` | nvim split'leri ve tmux pane'leri arasinda gezin | vim-tmux-navigator |

Quickfix'te gezinmek icin Neovim varsayilani `]q` / `[q` (eski `<C-n>`/`<C-j>` kaldirildi).

**Proje basina ayar:** `exrc` acik. Proje kokune `.nvim.lua` koyarsan Neovim onu calistirir, ama ilk seferde
`:trust` ile onayini ister. Ornek: `vim.o.makeprg = "make -j8 BOARD=ax3"`.

**tmux tarafi (gezinti):** `Ctrl-h/j/k/l` pane'de vim/nvim calisiyorsa ona gider, degilse tmux pane'i degisir.
Bedeli: kabukta `Ctrl-k` (satir sonuna kadar sil) ve `Ctrl-l` (ekrani temizle) artik pane degistirir; onlari
kabuga yollamak icin `Prefix` + ayni tus.

**Hata ayiklama:** `gdb` DAP modunda calisir (`gdb --interpreter=dap`). Derlerken `-g` kullan; `<leader>dc`
calistirilabilir dosyanin yolunu sorar.

Notlar: `gr` bilerek bagli degil (Neovim varsayilani `grr` referanslar, `grn` yeniden adlandir,
`gra` code action). `<C-v>` blok secimi icin birakildi; panoya yapistirmak `<leader>p`.

## Testler

```bash
./check.sh          # sozdizimi, shellcheck, kabuk testleri, tmux eklenti testi, nvim testi
./check.sh --fast   # ag gerektiren testleri (tmux eklentileri, nvim) atla
```

Testler gecici `HOME`, gecici tmux soketi ve gecici XDG dizinleri kullanir; gercek ayarlara ve acik tmux
oturumlarina dokunmaz. `shellcheck` kurulu degilse o adim uyarip atlanir (`sudo apt install shellcheck`;
`install.sh` de kurar).

## Not

Claude Code ayarlari bu repoda tutulmuyor; ayri repoda.
