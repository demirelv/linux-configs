# Claude Code ayarlari

Kisisel veri icermez. Icerik:

| Dosya | Aciklama |
|---|---|
| `CLAUDE.md` | Global talimatlar (model ayrimi kurallari, `@RTK.md` include) |
| `RTK.md` | rtk (Rust Token Killer) komut referansi |
| `settings.json` | Model, tema, statusline, `rtk hook claude` PreToolUse hook'u, plugin ve marketplace listesi |
| `statusline.sh` | Statusline: `[CAVEMAN] kullanici@host \| model \| dizin \| git branch` |
| `install.sh` | Yukaridakileri `~/.claude` altina kurar |

## Kurulum

```bash
./install.sh          # repo kokunden, digerleriyle birlikte
bash claude/install.sh  # sadece Claude ayarlari
```

## Notlar

- `settings.json` **birlestirilir**: mevcut `permissions.allow` ve `additionalDirectories`
  korunur, sadece repo'daki alanlar (model, tema, hooks, statusLine, plugins) uzerine yazilir.
- Ustune yazilan her dosyanin `.bak.<tarih>` yedegi alinir.
- `statusLine.command` kurulum sirasinda mutlak yola cevrilir.
- Repo'ya girmeyenler: `~/.claude/.credentials.json`, `history.jsonl`, `projects/`,
  `sessions/`, `plugins/` ve kisiye ozel izin listesi.
