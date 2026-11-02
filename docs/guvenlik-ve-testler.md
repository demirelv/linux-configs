# Guvenlik ve testler

Bu sayfa: repo public oldugu icin gizli bilgi korumasi (pre-commit) ve tum testlerin calistirilmasi.
Baska konular: [INDEX.md](INDEX.md) ya da terminalde `yardim -l`.

Icindekiler: gizli bilgi korumasi, testler

## Gizli bilgi korumasi (pre-commit)

Repo **public** oldugu icin `.githooks/pre-commit` her commit'te **eklenen** satirlari tarar: ozel anahtar basligi,
AWS/GitHub/GitLab/Slack token'lari ve `api_key = '...'` gibi atanmis sir degerleri. Bulunan degeri ekrana basmaz,
yalniz dosya adini soyler. `install.sh` kancayi `core.hooksPath=.githooks` ile etkinlestirir
(elle: `git config core.hooksPath .githooks`). Gerekirse atlamak icin `git commit --no-verify`.

Makineye ozel degerler (kendi kayit defteri adresin, ozel dizin adin, sirket alan adin) repo'ya yazilmaz;
`~/.config/linux-configs/deny-patterns` dosyasina her satira bir `grep -E` deseni olarak yazilir
(`#` yorum ve bos satirlar yok sayilir). Ornek: `\.internal\.example\.com`.

## Testler

```bash
./check.sh          # sozdizimi, shellcheck, kabuk/kanca/arac/dokuman testleri, tmux eklenti testi, nvim testi
./check.sh --fast   # ag gerektiren testleri (tmux eklentileri, nvim) atla
```

Testler gecici `HOME`, gecici tmux soketi ve gecici XDG dizinleri kullanir; gercek ayarlara ve acik tmux
oturumlarina dokunmaz. `shellcheck` kurulu degilse o adim uyarip atlanir (`sudo apt install shellcheck`;
`install.sh` de kurar).

| Test | Ne dogrular |
|---|---|
| `tests/shell_test.sh` | `link_file`, `clone_pinned`, `.bashrc.local`, tamamlamalar, `tp`, `tmuxt`, `yardim`, arac entegrasyonlari |
| `tests/hook_test.sh` | pre-commit kancasi (gercek `git commit` ile, kanca bozulunca kirmizi olur) |
| `tests/tools_test.sh` | `tools/install-tools.sh` (sahte apt ile: atlama, kurulu olani kurmama, `fd`/`bat` baglari, delta) |
| `tests/docs_test.sh` | Dokuman baglantilari, INDEX tamligi, kisayol/arac listelerinin koddan sapmasi |
| `tests/lc_help_test.sh` | `lc-help` indeksi kaynaklarla uyumlu mu, arama, bayat indeks, `fzf` yolu (pty) |
| `tests/lc_doctor_test.sh` | `lc-doctor`: bos HOME'da MISS, baglar kurulunca temiz, yanlis hedefli bag, arac tablosu `tools.tsv` ile tam |
| `tests/commit_msg_test.sh` | `commit-msg` kancasi ve `lc-issue-hook` (gercek `git commit` ile, baska hook'a dokunmaz) |
| `tests/tmux_plugins_test.sh` | tmux config, resurrect/continuum, nvim-tmux gezinti (ag gerekir) |
| `nvim/tests/run.sh` | Taze kurulumda Neovim: tus cakismasi, eklentiler, LSP, biçimlendirme, `:Make`, treesitter (ag gerekir) |
