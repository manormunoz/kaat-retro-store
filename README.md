# 🎮 K'aat Retro Store

**K'aat Retro Store** is a **source-available** multiplatform (android, windows, mac & linux) app built with **Flutter** + **GetX** that lets you browse and download retro game ROMs directly from [**Myrient**](https://myrient.erista.me/), enriched with **boxarts, logos, and metadata** from various sources.

> 🎨 **The user interfaces were designed with AI assistance.** We welcome contributions to improve the design, usability, and overall user experience!

## 🔗 Data Sources

- **ROM source:** [Myrient](https://myrient.erista.me/) (No‑Intro / Redump organized)
- **Boxarts & game logos:** [libretro-thumbnails](https://github.com/libretro/libretro-thumbnails) (served via jsDelivr)
- **Platform logos (FlatUI):** [retroarch-assets](https://github.com/libretro/retroarch-assets) (served via jsDelivr)
- **Metadata & boxarts:** [ScreenScraper](https://www.screenscraper.fr/)
- **CDN:** [jsDelivr](https://www.jsdelivr.com/) for fast, cacheable delivery of GitHub‑hosted assets

> ⚠️ **Disclaimer**: K'aat Retro Store does **not** include or host any ROMs or images.
> It provides links to third‑party resources. Users are responsible for ensuring they own the original games and comply with their local laws before downloading.

---

## Features

- Browse popular platforms (NES, SNES, N64, GB/GBC/GBA, DS/3DS, Genesis, Master System, PSP/PS1/PS2, GameCube/Wii, etc.).
- Download ROMs from **Myrient** using platform‑specific URLs (No‑Intro for cartridges/digital decrypted, Redump for discs).
- Show **boxarts** and **game logos** directly from **libretro‑thumbnails** via **jsDelivr**, without bundling assets.
- Show **platform logos (FlatUI)** from **retroarch‑assets** via **jsDelivr**.
- YAML configuration that maps each platform to its ROM index and corresponding thumbnail/icon folders.

---

## 📅 Upcoming Improvements

We are working on new features and optimizations for future versions:

- 📦 **Additional ROM providers** beyond Myrient to give users more options and sources.
- 📥 **Direct download from Myrient** to simplify the process and avoid extra steps.
- 🎮 **RetroArch compatibility**: option to save ROMs directly into RetroArch's corresponding folders so they're ready to play.
- 🎯 **Game controller support**: improved navigation using console controllers/gamepads for a more authentic retro gaming experience.
- 💻 **Optimized view for tablets and desktop computers** with a responsive interface that takes full advantage of larger screens.
- ⚡ **Performance improvements** for faster ROM list loading and smoother navigation.  

---

## 🤝 Contributing

We welcome contributions to improve **K'aat Retro Store**! Whether you want to:

- 🎨 **Enhance the UI/UX design** (remember, interfaces were AI-assisted and can be improved!)
- 🐛 **Fix bugs** or improve code quality
- ✨ **Add new features** or ROM providers
- 📝 **Improve documentation** or translations

Feel free to open an issue or submit a pull request. All contributions are appreciated!

---

## ☕ Support the Project

If you find **K'aat Retro Store** useful and want to support its development, consider buying me a coffee!

[![Buy Me A Coffee](https://img.shields.io/badge/Buy%20Me%20A%20Coffee-Support-yellow?style=for-the-badge&logo=buy-me-a-coffee)](https://buymeacoffee.com/kaat)

Your support helps maintain and improve this project. Thank you! 🙏

---

## 🛠 Useful Commands

### Generate localization classes

Compiles localization classes from `.arb` files in `lib/l10n/`:

```bash
flutter gen-l10n
```

---

## 📄 License

This project is licensed under a **Non-Commercial Source License**.

✅ **You can:**

- Use the application freely for personal purposes
- View and study the source code
- Modify the code for personal use
- Share the application with others

❌ **You cannot:**

- Use the code for commercial purposes or to make money
- Redistribute the source code without permission
- Remove copyright notices

For commercial licensing inquiries, please contact the author.

See the [LICENSE](LICENSE) file for full details
