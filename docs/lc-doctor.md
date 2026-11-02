# lc-doctor ve lc-issue-hook

Bu sayfa: iki yardimci komut. `lc-doctor` makinenin bu repoyla uyumunu denetler, `lc-issue-hook` baska repolara
commit mesajinda `Issue: KEY-123` satirini zorunlu kilan kanca kurar. Kimin icin: yeni makineyi dogrulayan ya da
Gerrit reposunda commit atan.

Icindekiler: lc-doctor, lc-issue-hook, testler.

## lc-doctor

```bash
lc-doctor      # tam rapor
lc-doctor -q   # yalniz sorunlar
```

Satir basi: `ok` (tamam), `WARN` (istege bagli ya da bakmaya deger), `MISS` (zorunlu parca eksik; cikis kodu 1).
Her sorunun yaninda `->` ile nasil duzeltilecegi yazar.

| Bolum | Ne denetler |
|---|---|
| links | `~/.bashrc`, `~/.tmux.conf`, nvim `init.lua` ve `lua/`, `~/.local/bin/lc-*` repoya sembolik bagli mi; `~/.gitconfig` repodakiyle ayni mi (kopyalanir, bagli degildir) |
| required programs | `git`, `tmux`, `nvim` (0.11+), `fzf`, `python3`; `tree-sitter` CLI |
| tmux plugins | resurrect, continuum, extrakto kurulu ve `install.sh`'deki sabit commit'te mi |
| neovim | eklentiler kurulmus mu (`lazy.nvim`) |
| shell environment | `~/.bashrc.local`, `PATH` (`~/.local/bin`, `~/.cargo/bin`), `deny-patterns`, repoda pre-commit kancasi |
| optional tools | `help/tools.tsv`'deki araclardan hangileri kurulu degil (apt ve apt-disi ayri satirda) |

Yeni bir arac `help/tools.tsv`'e girince `bin/lc-doctor` icindeki paket-komut tablosuna da girmeli
(`tests/lc_doctor_test.sh` eksigi yakalar).

## lc-issue-hook

Gerrit `Issue:` satirsiz push'u reddeder; bu kanca hatayi commit aninda gosterir.

```bash
lc-issue-hook install [repo]     # varsayilan: bulundugun repo
lc-issue-hook status [repo]
lc-issue-hook uninstall [repo]
```

- Kanca `git/hooks/commit-msg`: mesajda `Issue: ABC-123` (buyuk harf anahtar, tire, sayi) satiri aranir; `#` ile
  baslayan yorum satirlari sayilmaz. `Merge`, `fixup!`, `squash!` ve `amend!` mesajlari atlanir.
- Bir kez atlamak icin `git commit --no-verify`.
- `install` hooks klasorune sembolik bag koyar (`core.hooksPath` varsa onu kullanir). Orada baska bir `commit-msg`
  varsa dokunmaz, reddeder. `uninstall` yalniz kendi bagini siler.
- linux-configs deposunun kendisine kurulmaz: buradaki commit'lerde `Issue:` satiri yok.

## Testler

`tests/lc_doctor_test.sh` ve `tests/commit_msg_test.sh`. Bkz. [guvenlik-ve-testler.md](guvenlik-ve-testler.md).
