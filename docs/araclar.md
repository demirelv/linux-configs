# Gelistirici araclari

Bu sayfa: kurulan araclarin ne ise yaradigi, nasil kurulacagi, hangilerinin kabuga/Git'e otomatik baglandigi
ve neden bazilarinin kurulmadigi. Kimin icin: bu repoyu yeni bir makineye kuran ya da bir aracin ne oldugunu
merak eden.

Icindekiler: kurulum, gruplar, otomatik entegrasyonlar, ornek kullanim, zaten kurulu olanlar, apt disi araclar.

## Kurulum

```bash
tools/install-tools.sh --dry-run all   # ne kurulacagini goster (sudo gerekmez)
tools/install-tools.sh                 # varsayilan: core + git gruplari
tools/install-tools.sh net c-debug     # istedigin gruplar
tools/install-tools.sh all             # hepsi
./install.sh --with-tools              # install.sh icinden, hepsi
```

Betik yalnizca apt'te bulunan ve kurulu olmayan paketleri kurar; olmayani atlar ve soyler. `sudo` gerekir.

## Gruplar

| Grup | Arac | Ne ise yarar |
|---|---|---|
| core | `cppcheck` | Statik analiz, derleme gerektirmez, hizli |
| core | `clang-tidy` | Derleyiciye dayali analiz; `compile_commands.json` ister |
| core | `clang-format` | Kod bicimlendirici; Neovim'de `<leader>cf` |
| core | `bear` | `bear -- make` ile `compile_commands.json` uretir (clangd/clang-tidy icin sart) |
| core | `git-delta` | `git diff/show/log` cikti renklendirici (yan yana, kelime farki) |
| core | `fd-find` | Hizli dosya bulucu; `fd` adiyla baglanir (Ubuntu'da `fdfind`) |
| core | `bat` | Renkli `cat`; `bat` adiyla baglanir (Ubuntu'da `batcat`) |
| core | `eza` | `ls`'in agac gosterebilen karsiligi |
| core | `zoxide` | `z <ad>` ile sik gidilen klasore atla |
| core | `direnv` | Klasore girince `.envrc` yukler (toolchain `PATH`, `CROSS_COMPILE`) |
| core | `shellcheck` | Kabuk betigi denetleyicisi (`check.sh` kullanir) |
| c-debug | `rr` | Kaydet ve geri sar hata ayiklama (nadir hatalar icin). Donanim sayaci gerekir, sanal makinede calismayabilir |
| c-debug | `ltrace` | Kutuphane cagrilarini izler (`strace` zaten kurulu) |
| c-debug | `lcov` | Kod kapsama raporu |
| c-debug | `doxygen` | Kod dokumantasyonu uretir |
| net | `tshark` | Wireshark'in komut satiri hali, capture dosyasi analizi |
| net | `binwalk` | Firmware imajlarini cozumler (squashfs, kernel, uboot) |
| net | `qemu-user-static` | ARM/MIPS ikilileri x86'da calistirir |
| net | `tio` | Seri konsol; cihaz yeniden baslayinca otomatik baglanir, kayit tutar. `tmuxt` kuruluysa kullanir |
| net | `lnav` | Log gezgini: zaman damgasini ayristirir, filtreler, renklendirir |
| net | `moreutils` | `ts` komutu: satirlara zaman damgasi ekler |
| net | `mosh`, `sshfs` | Kopmayan uzak oturum; uzak dosya sistemini yerel klasor gibi bagla |
| git | `tig` | Terminalde git gecmisi/blame gezgini |
| git | `pre-commit` | Commit kancasi cercevesi. NOT: bu repo `core.hooksPath` kullandigi icin burada `pre-commit install` calismaz; baska repolarda kullan |
| misc | `entr` | Dosya degisince komut calistirir |
| misc | `hyperfine` | Komut suresini istatistikle olcer |
| misc | `ncdu`, `duf` | Disk kullanimi gezgini; bos alan tablosu |
| misc | `just` | `Makefile`'dan okunur komut sablonlari |
| misc | `tmuxp` | tmux duzenlerini YAML ile tanimlar |
| misc | `httpie`, `tldr` | Okunur HTTP istemcisi; kisa komut orneklerini gosterir |

## Otomatik entegrasyonlar

Arac kuruluysa `.bashrc` (ya da Git) onu kendiliginden kullanir, kurulu degilse sessizce atlanir:

| Arac | Ne olur |
|---|---|
| `zoxide` | `z`, `zi` komutlari tanimlanir |
| `direnv` | Kabuk kancasi eklenir; `.envrc` olan klasorde `direnv allow` gerekir |
| `fd` | `fzf` dosya listesi (`Ctrl-T`) `fd` ile uretilir: hizli, `.gitignore`'a uyar |
| `bat` | `Ctrl-T` dosya secerken renkli onizleme |
| `eza` | `lt` takma adi (2 seviye agac) |
| `git-delta` | `~/.gitconfig.delta` kopyalanir ve `~/.gitconfig` icinden include edilir (pager, `zdiff3` cakisma stili, tasinan satir rengi) |

Entegrasyonlar `~/.bashrc.local`'dan sonra yuklenir; arac `~/.local/bin` altindaysa bulunur.

## Ornek kullanim

```bash
bear -- make                                       # compile_commands.json
cppcheck --enable=warning,performance --inline-suppr .
ls *.c | entr -c make test                         # kaydedince test
hyperfine 'make -j8'                               # derleme suresi
lnav konsol.log                                    # log gezgini
tio /dev/serial/by-id/usb-...                      # seri konsol
komut | ts '%H:%M:%S'                              # cikti satirlarina saat
tshark -r x.pcap -Y dns -T fields -e dns.qry.name  # pcap'ten alan cikar
binwalk -e firmware.bin                            # imaji ac
qemu-arm-static -L <sysroot> ./program             # ARM ikilisini calistir
rr record ./program && rr replay                   # kaydet, geri sararak izle
```

## Zaten kurulu olanlar (bu betik yonetmez)

`jq`, `htop`, `btop`, `socat`, `nc`, `tcpdump`, `strace`, `perf`, `bpftrace`, `gh`, `lazygit`, `ccache`, `valgrind`.

## apt'te olmayan araclar (bilerek kurulmuyor)

`starship` (prompt), `atuin` (gecmis aramasi), `glow` (Markdown okuyucu), `watchexec` (`entr`'in gelismisi),
`jira-cli`, `tokei` (kod satiri sayaci). Bunlar `curl | bash` ya da GitHub release indirmesi ister; her biri
icin once sahip, lisans, bakim durumu ve kurulum betigi kontrol edilmeli. Ihtiyac olursa tek tek, kontrol ederek kur.
