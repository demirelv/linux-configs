# 0. Model Ayrımı (ZORUNLU — diğer tüm kurallardan önce okunur)

Bu kural kullanıcının kalıcı talimatıdır; alt-ajan çağırmak için ayrıca izin istemeye gerek yoktur.

**Opus (ana oturum) — üretim işi:**
kod yazma, düzenleme, refactor, hata ayıklama, migration, komut/derleme/test çalıştırma,
commit & deploy. Bunlar ana oturumda kalır, alt-ajana devredilmez.

**Fable (en yeni sürüm) — düşünme işi:**
Aşağıdaki işler `Agent` tool'u ile `model: "fable"` verilerek devredilir:
- kod akışı çıkarma, çağrı zinciri haritalama, "bu nasıl çalışıyor" keşfi
- mimari / veri modeli / API tasarımı, uygulama planı hazırlama, seçenek karşılaştırma
- kod incelemesi, güvenlik ve performans taraması, dokümantasyon/envanter derlemesi

Devir biçimi:
`Agent({ subagent_type: "Explore" | "Plan" | "general-purpose", model: "fable", prompt: ... })`
(`subagent_type: "fork"` model override'ını yok sayar — onunla kullanma.)

**Geri düşme:** Fable erişilemez ya da kota yoksa (agent hata döner / model reddedilir),
sessizce Opus'a düş, tek satırla bildir, işi durdurma.

**İstisnalar:**
- Devir maliyeti işten büyükse (tek dosyada tek gerçeği okumak, bilinen satırı görmek)
  ana oturumda yapılır.
- Kullanıcı açıkça model söylerse (`/model`, "bunu opus ile yap") bu kuralı ezer.

---

@RTK.md
