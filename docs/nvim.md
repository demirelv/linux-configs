# Neovim (`nvim/`)

Bu sayfa: Neovim'de arama, kisayol bulma, LSP, derleme, debug ve eklentiler.
Baska konular: [INDEX.md](INDEX.md) ya da terminalde `yardim -l`.

Icindekiler: ayarlar ve arama, ek ozellikler (nvim/lua/cfg), test

## Ayarlar ve arama (`nvim/init.lua`)

Neovim >= 0.11 gerekir. Eklentiler sabitlenmez: `lazy-lock.json` repo'da tutulmaz, her
`Lazy sync` en guncel surumu alir. `nvim-treesitter` icin `tree-sitter` CLI gerekir
(`nvim/install.sh` kurar).

Tum kisayollarin aciklamasi var. Hepsini aramak icin:

| Tus | Ne yapar |
|---|---|
| `<F1>` ya da `<leader>fk` | Kisayol ara (popup, yazdikca filtreler) |
| `<leader>fc` | Komut ara |
| `<leader>fl` | `lc-help` indeksinde ara (kabuk komutlari, git alias, tmux tuslari, araclar); Enter metni panoya kopyalar |
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

**tmux ile gezinti:** `Ctrl-h/j/k/l` nvim split'i ile tmux pane'i arasinda ortak calisir; ayrinti ve bedeli: [tmux.md](tmux.md#nvim-tmux-gezinti).

**Hata ayiklama:** `gdb` DAP modunda calisir (`gdb --interpreter=dap`). Derlerken `-g` kullan; `<leader>dc`
calistirilabilir dosyanin yolunu sorar.

Notlar: `gr` bilerek bagli degil (Neovim varsayilani `grr` referanslar, `grn` yeniden adlandir,
`gra` code action). `<C-v>` blok secimi icin birakildi; panoya yapistirmak `<leader>p`.
