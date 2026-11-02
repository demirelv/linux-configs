# tmux (`tmux/.tmux.conf`)

Bu sayfa: tmux ayarlari: prefix, oturum kalicligi eklentileri ve nvim ile pane gezintisi.
Baska konular: [INDEX.md](INDEX.md) ya da terminalde `yardim -l`.

Icindekiler: temel ayarlar, eklentiler (resurrect/continuum), nvim-tmux gezinti

## Temel ayarlar

| Ayar | Deger |
|---|---|
| Prefix | `Ctrl-a` (`Ctrl-b` kaldirildi). `Prefix` + `Ctrl-a` gercek `Ctrl-a`'yi yollar. |
| `Prefix` + `r` | Config'i yeniden yukle |
| `Prefix` + `\|` / `-` | Saga / alta bol (ayni klasorde) |
| `Prefix` + `c` | Ayni klasorde yeni pencere |
| `Prefix` + `h/j/k/l`, `H/J/K/L` | Pane'e gec, pane boyutu |
| `Prefix` + `Ctrl-v` | Copy mode (vi tuslari: `v` sec, `y` panoya kopyala) |
| `Prefix` + `P`, sag tik | Sistem panosundan yapistir |
| `escape-time` | 10 ms (Neovim'de `Esc` gecikmesin) |
| Pencere/pane numarasi | 1'den baslar, pencere kapaninca yeniden numaralanir |

Tum liste `.tmux.conf` sonundaki "SIK KULLANILAN TUSLAR" yorumunda.

## tmux eklentileri

`install.sh`, `tmux-resurrect` ve `tmux-continuum` eklentilerini `~/.tmux/plugins` altina kurar.
Kod her tmux acilisinda calistigi icin ikisi de **sabit commit**'e sabitlenir (`install.sh` icinde);
surum yukseltmek icin commit'i bilincli degistir. Eklentiler yoksa `.tmux.conf` sessizce atlar.

| Tus | Ne yapar |
|---|---|
| `Prefix` + `Ctrl-s` | Oturumlari simdi kaydet |
| `Prefix` + `Ctrl-r` | Son kaydi geri yukle |

`continuum` periyodik kaydeder ve tmux sunucusu acilirken son kaydi geri yukler. Otomatik kaydi yalnizca
makinede baska tmux sureci yokken baslatir; ilk acilista kaydin olusmasi bu yuzden gecikebilir.

## nvim-tmux gezinti

`Ctrl-h/j/k/l` pane'de vim/nvim (ya da fzf) calisiyorsa tusu ona yollar, degilse tmux pane'ini degistirir
(`vim-tmux-navigator`'in tmux tarafi). Bedeli: kabukta `Ctrl-k` (satir sonuna kadar sil) ve `Ctrl-l` (ekrani
temizle) artik pane degistirir; onlari kabuga yollamak icin `Prefix` + ayni tus. Kopya modunda da ayni tuslar
pane degistirir. Neovim tarafi: [nvim.md](nvim.md).
