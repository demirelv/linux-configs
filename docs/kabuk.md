# Kabuk (`bash/.bashrc`)

Bu sayfa: gunluk kabuk komutlari (`tm`, `tp`, `tmw`, `tmj`, bilet yardimcilari), ortam degiskenleri ve `~/.bashrc.local`.
Baska konular: [INDEX.md](INDEX.md) ya da terminalde `yardim -l`.

Icindekiler: makineye ozel ayarlar, gunluk kisayollar, tmux fonksiyonlari

## Makineye ozel ayarlar: `~/.bashrc.local`

Bu repo **public**. PATH, nvm, bun, hesap takma adlari, kayit defteri adresleri gibi makineye ozel
satirlar `~/.bashrc.local` dosyasina yazilir; `.bashrc` sonunda onu otomatik okur ve dosya repo'ya girmez.
Ornek (mod `600` onerilir):

```bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
export PATH="$HOME/.local/bin:$PATH"
```

## Gunluk kisayollar

| Komut | Ne yapar |
|---|---|
| `tp [filtre]` | `TP_ROOT` (varsayilan `$HOME`) altindaki klasorlerden birini `fzf` ile sectir; o klasorde, klasor adiyla bir tmux session'i ac ya da bagla. Tek eslesme varsa sormadan acar. |
| `cdt`, `vimt`, `vimj`, `tmuxt <bilet>` | `~/Documents/FixedIssues/<bilet>` klasorune git / `notes.md` / `notes.jira` ac / bilet icin tmux ortami kur. Hepsinde Tab ile bilet adi tamamlanir. |

| `lc-help [kelime]` | Komut/kisayol/arac arama (Ingilizce); ayrinti: [lc-help.md](lc-help.md) |
| `yardim [konu]` | Bu dokumanlari terminalde goster. `yardim -l` konular, `yardim ara <kelime>` arama. Varsayilan konu `ozet`. |
| `z <klasor>`, `zi` | Sik gidilen klasore atla (zoxide kuruluysa; bkz. [araclar.md](araclar.md)) |

Ortam degiskenleri (makineye ozel olanlar `~/.bashrc.local`'a):

| Degisken | Anlami |
|---|---|
| `TP_ROOT` | `tp`'nin klasorlerini listeledigi dizin |
| `TMUXT_SERIAL` | `tmuxt`'nin seri portu. Verilmezse `/dev/serial/by-id` altindaki ilk aygit, o da yoksa `/dev/ttyUSB0`. `by-id` adi aygit yeniden baslasa da degismez. |
| `TMUXT_ETH` | `tmuxt`'nin ag arayuzu (varsayilan `eth0`) |

`tmuxt`, `tio` kuruluysa onu (aygit yeniden baslayinca otomatik yeniden baglanir), degilse `minicom`'u kullanir.
`EDITOR`/`VISUAL` bos ya da `vi`/`vim` ise `nvim` olur; baska bir editor bilerek ayarlanmissa ezilmez
(`git` editoru de `nvim`). Her komuttan sonra gecmis dosyaya eklenir, boylece tmux pane'leri `Ctrl-r` gecmisini paylasir.

## tmux fonksiyonlari

| Komut | Ne yapar |
|---|---|
| `tm [isim]` | Session'a baglan ya da olustur (varsayilan `main`). tmux icindeyse `switch-client` ile gecer. |
| `tmw kaynak [hedef]` | Baska session'daki pencereyi mevcut (ya da hedef) session'a tasi. Ornek: `tmw work:2` |
| `tmj [kaynak] [hedef]` | Baska session'daki pencereyi mevcut pencereye pane olarak birlestir. Parametresiz: tum pencereler arasindan sectirir (fzf, yoksa numarali menu). |

Uc komutta da `Tab` tamamlamasi vardir: `tm` session adlarini, `tmw`/`tmj` `session:pencere` adaylarini verir.
