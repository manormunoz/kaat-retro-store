# 🎮 K'aat Retro Store

**K'aat Retro Store** is an **open-source** mobile app built with **Flutter** + **GetX** that lets you browse and download retro game ROMs directly from [**Myrient**](https://myrient.erista.me/), enriched with **boxarts, logos, and metadata** from:

- **ROM source:** [Myrient](https://myrient.erista.me/) (No‑Intro / Redump organized)
- [**libretro-thumbnails**](https://github.com/libretro/libretro-thumbnails)  
- [**RetroArch assets**](https://github.com/libretro/retroarch-assets)  
- [**ScreenScraper**](https://www.screenscraper.fr/)

> ⚠️ **Disclaimer**: K'aat Retro Store does **not** include any ROMs.  
> Users are responsible for ensuring they own the original games and comply with their local laws before downloading.

---

- **ROM source:** [Myrient](https://myrient.erista.me/) (No‑Intro / Redump organized)
- **Boxarts & game logos:** [libretro-thumbnails](https://github.com/libretro/libretro-thumbnails) (served via jsDelivr)
- **Platform logos (FlatUI):** [retroarch-assets](https://github.com/libretro/retroarch-assets) (served via jsDelivr)
- **CDN:** [jsDelivr](https://www.jsdelivr.com/) for fast, cacheable delivery of GitHub‑hosted assets

> **Note:** K'aat Retro Store does **not** host ROMs or images. It provides links to third‑party resources and a YAML map of platform metadata so you can integrate easily with RetroArch and other emulators.

---

## Features

- Browse popular platforms (NES, SNES, N64, GB/GBC/GBA, DS/3DS, Genesis, Master System, PSP/PS1/PS2, GameCube/Wii, etc.).
- Download ROMs from **Myrient** using platform‑specific URLs (No‑Intro for cartridges/digital decrypted, Redump for discs).
- Show **boxarts** and **game logos** directly from **libretro‑thumbnails** via **jsDelivr**, without bundling assets.
- Show **platform logos (FlatUI)** from **retroarch‑assets** via **jsDelivr**.
- YAML configuration that maps each platform to its ROM index and corresponding thumbnail/icon folders.

---

## 🛠 Useful Commands

### Generate localization classes

Compiles localization classes from `.arb` files in `lib/l10n/`:

```bash
flutter gen-l10n
