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
| c-debug | `strace` | Programin sistem cagrilarini izler (hangi dosya/soket/sinyal) |
| c-debug | `gdb` | GNU hata ayiklayici: breakpoint, backtrace, core dosyasi |
| c-debug | `bpftrace` | eBPF ile tek satirlik izleme (root ister) |
| c-debug | `linux-tools-KERNEL` | `perf`: CPU profili ve donanim sayaclari. KERNEL = `uname -r`; betik calisan kernel'in paketini kurar |
| c-debug | `rr` | Kaydet ve geri sar hata ayiklama (nadir hatalar icin). Donanim sayaci gerekir, sanal makinede calismayabilir |
| c-debug | `ltrace` | Kutuphane cagrilarini izler |
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
| net | `python3-scapy` | Python ile paket uret/yakala/fuzz et (`scapy` komutu) |
| net | `tcpdump` | Arayuzde paket yakalar; router uzerinde de calisir |
| net | `tcpreplay` | Yakalanmis pcap'i istenen hizda arayuze tekrar oynatir |
| net | `ngrep` | Canli trafikte ya da pcap'te payload icinde regex arar |
| net | `termshark` | Terminalde Wireshark benzeri arayuz (`tshark` kullanir) |
| net | `wavemon` | Canli Wi-Fi sinyal, gurultu ve baglanti kalitesi |
| net | `iperf3` | Iki makine arasi throughput testi (TCP/UDP, paralel akis) |
| net | `mtr-tiny` | `mtr`: ping + traceroute birlikte, kayip yapan hop'u bulur |
| net | `fping` | Cok sayida hosta ayni anda ping, betik dostu |
| net | `hping3` | Ozel TCP/UDP/ICMP probe uretir (firewall ve gecikme testi) |
| net | `nmap` | Port tarama ve servis tespiti. Yalniz kendi cihazlarinda ve yetkili agda |
| net | `netperf` | Throughput ve istek/cevap gecikmesi olcer (`netserver` karsi tarafta) |
| net | `dnsutils` | `dig`, `nslookup`: DNS sorgulari |
| net | `radvd` | `radvdump`: IPv6 router advertisement gosterir (radvd servisi ayarsiz kalir, kullanilmaz) |
| net | `ndisc6` | `rdisc6`, `ndisc6`: IPv6 router ve komsu kesfi |
| net | `snmp` | `snmpget`, `snmpwalk`: cihaz MIB'lerini SNMP ile okur |
| net | `iw` | Wi-Fi arayuz araci: kanal, bant, istasyon listesi, tarama |
| net | `socat` | Soket, seri port, dosya ve boru arasi aktarim (ornek: seri portu TCP'ye ac) |
| misc | `pv` | Boru icinden gecen verinin ilerleme/hiz/kalan sure gostergesi |
| misc | `visidata` | Terminalde tablo: CSV, xlsx, JSON ac, sirala, filtrele, pivot (`vd dosya.xlsx`) |
| misc | `entr` | Dosya degisince komut calistirir |
| misc | `hyperfine` | Komut suresini istatistikle olcer |
| misc | `ncdu`, `duf` | Disk kullanimi gezgini; bos alan tablosu |
| misc | `just` | `Makefile`'dan okunur komut sablonlari |
| misc | `tmuxp` | tmux duzenlerini YAML ile tanimlar |
| misc | `httpie`, `tldr` | Okunur HTTP istemcisi; kisa komut orneklerini gosterir |
| dev | `ripgrep` | Hizli `grep`, `.gitignore`'a uyar (Telescope canli arama bunu kullanir) |
| dev | `git-absorb` | Staged degisiklikleri dogru eski commit'lere fixup olarak dagitir: `git absorb --and-rebase` |
| dev | `gping` | Canli grafikli `ping` |

## Otomatik entegrasyonlar

Arac kuruluysa `.bashrc` (ya da Git) onu kendiliginden kullanir, kurulu degilse sessizce atlanir:

| Arac | Ne olur |
|---|---|
| `zoxide` | `z`, `zi` komutlari tanimlanir |
| `direnv` | Kabuk kancasi eklenir; `.envrc` olan klasorde `direnv allow` gerekir |
| `fd` | `fzf` dosya listesi (`Ctrl-T`) `fd` ile uretilir: hizli, `.gitignore`'a uyar |
| `bat` | `Ctrl-T` dosya secerken renkli onizleme |
| `eza` | `lt` takma adi (2 seviye agac) |
| `mise` | `mise activate bash`: dil surumleri (node, python) klasore gore degisir |
| `atuin` | `Ctrl-r` ve yukari ok gecmis aramasini devralir (dizin, cikis kodu, sure). Veritabani bos baslar: `install-tools.sh extra` bash gecmisini bir kez iceri alir (`atuin import auto`) ve yukari oku tum gecmise acar (`filter_mode_shell_up_key_binding = "global"`, varsayilan yalniz bu oturum). Kendi ayarini yazdiysan ezilmez |
| `starship` | Prompt'u degistirir (git dali, venv, cikis kodu, komut suresi) |
| `~/.cargo/bin` | Varsa `PATH`'e eklenir (`cargo install` ile kurulanlar bulunur) |
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

## apt'te olmayan araclar

`tools/install-tools.sh` bunlari kurmaz; `curl | bash` yerine crates.io'dan, surum sabitli ve kilit dosyasiyla
kurulur (`--locked`). Rust gerekir (`cargo`); derleme birkac dakika surer. Surumler, bu makinede (apt'teki rustc 1.88) gercekten derlenen en
yeni surumlerdir (2026-11-02'de denendi); daha yeni surumler daha yeni rustc ister. Hepsini birden:
`tools/install-tools.sh extra` (ya da `./install.sh --with-tools`); kurulu olani atlar, biri basarisiz olursa digerlerine devam eder.
Her biri `lc-help tool <ad>` ile aranabilir. Hepsi kuruluysa `.bashrc` kendiliginden baglar (yukaridaki tablo).

| Arac | Ne ise yarar | Kurulum |
|---|---|---|
| `starship` | Hizli prompt | `cargo install --locked starship --version 1.24.0` |
| `atuin` | Sqlite gecmis; `Ctrl-r` dizin/cikis koduyla arar | `cargo install --locked atuin --version 18.8.0` |
| `mise` | Dil surumleri, ortam degiskenleri, gorevler | `cargo install --locked mise` (rustc 1.95+ ister; apt'teki 1.88 yetmez, betik kurmaz. Kendi kurulum yolu: mise.jdx.dev) |
| `uv` | Cok hizli Python paket/venv yoneticisi | `pipx install uv` (Ubuntu'da `pip install --user` engelli) |
| `watchexec` | Dosya degisince komut; `entr`'den rahat | `cargo install --locked watchexec-cli --version 2.4.3` |
| `dust` | Disk kullanimini cubukla gosterir | `cargo install --locked du-dust --version 1.2.5` |
| `difftastic` | Sozdizimine duyarli diff | `cargo install --locked difftastic --version 0.72.0` |
| `ast-grep` | Sozdizimi agacina gore ara/degistir (`sg`) | `cargo install --locked ast-grep --version 0.44.1` |
| `procs` | `ps` yerine: renk, agac, arama | `cargo install --locked procs --version 0.14.12` |
| `tokei` | Dile gore kod satiri sayar | `cargo install --locked tokei --version 15.0.0` |
| `xh` | Hizli httpie benzeri HTTP istemcisi | `cargo install --locked xh --version 0.26.3` |
| `glow` | Markdown'i terminalde bicimli gosterir | `sudo snap install glow` (apt'te yok; Go araci, `install-tools.sh extra` snap ile kurar) |
| `vtop` | `top` benzeri surec izleyici (C, kendi yazimim): ayni programi gruplar, PSI, disk G/C | kaynaktan: `git clone https://github.com/demirelv/vtop` + `make install PREFIX=~/.local` (commit `de41a78` sabit) |

`vtop` crates.io'da degil: `install-tools.sh extra` GitHub'dan klonlar, sabit commit'e alir, derler ve `~/.local/bin/vtop`'a kurar
(sudo yok; `/usr/bin/vtop` gibi eski bir kopya kurulumu engellemez, yeni kopya PATH'te onde gelir).

Kurmadan once crate'in sahibine ve son surum tarihine bak (supply-chain). `jless` kurulmuyor (derlemek icin `libxcb-*-dev` paketleri gerekir). `jira-cli` Go ile yazili;
bilerek eklenmedi.

Git icin `git/.gitconfig` artik `pull.rebase`, `fetch.prune`, `rerere`, `diff.algorithm=histogram` ve
`merge.conflictstyle=zdiff3` ayarlarini tasir (kurulum gerektirmez).
