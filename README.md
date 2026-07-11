<!--
  description: Dwarf Fortress Simplified Chinese Translation Plugin (dfzh). A DFHack-based mod providing real-time full-UI localization for Dwarf Fortress, covering menus, items, creatures, and buildings.
  keywords: dwarf fortress, 矮人要塞, chinese translation, 汉化, simplified chinese, 简体中文, dfhack, localization, game mod, steam
-->

<div align="center">

# Dwarf Fortress Chinese Translation Plugin (dfzh)

> ⛏️🏰 矮人要塞汉化 ｜ Dwarf Fortress Simplified Chinese Mod ｜ DFHack 中文翻译插件

[![Release](https://img.shields.io/github/v/tag/wodzys/dwarf-fortress-chinese?label=version&color=blue)](https://github.com/wodzys/dwarf-fortress-chinese/releases)
[![Windows Build Status](https://github.com/wodzys/dwarf-fortress-chinese/actions/workflows/build.yml/badge.svg)](https://github.com/wodzys/dwarf-fortress-chinese/actions/workflows/build.yml)
[![Platform](https://img.shields.io/badge/Platform-Windows-0078D6?logo=windows&logoColor=white)](https://github.com/wodzys/dwarf-fortress-chinese)
[![DFHack](https://img.shields.io/badge/DFHack-53.14+-purple)](https://github.com/DFHack/dfhack/releases)
[![Steam Workshop](https://img.shields.io/badge/Steam-Workshop-1a6b3c?logo=steam)](https://steamcommunity.com/sharedfiles/filedetails/?id=3762474859)
[![License](https://img.shields.io/badge/license-MIT%2FCC--BY--NC%204.0-green)](LICENSE)

**[English](README.md) | [简体中文](README.zh-CN.md)**

</div>

A **real-time Simplified Chinese localization mod** for **Dwarf Fortress** (Steam version). Built as a **DFHack plugin**, it translates the entire game UI — menus, item descriptions, creature names, building interfaces, and more — on the fly, directly from game memory.

> ⚡ **Quick Install**: Subscribe on [Steam Workshop](https://steamcommunity.com/sharedfiles/filedetails/?id=3762474859) (recommended) or follow the manual steps in [Installation](#-installation).

## Previews

### 🎮 Title Screen
<p align="center">
  <img src=".github/images/title_screen.png" alt="Chinese localized title screen" width="100%">
</p>

---

### 📜 Text & Character Details

| Embark Outpost Description | Dwarf Thoughts & Attributes |
| :---: | :---: |
| <img src=".github/images/embark_text.png" alt="Embark text preview" width="100%"> | <img src=".github/images/dwarf_thoughts.png" alt="Dwarf thoughts and attributes" width="100%"> |

---

### 📦 Items & Stocks
<p align="center">
  <img src=".github/images/stocks_list.png" alt="Chinese localized stocks list" width="50%">
</p>

---

### 🛠️ DFHack Tools

DFHack's common features and control panel are also localized for your convenience:

| DFHack Launcher | DFHack Control Panel |
| :---: | :---: |
| <img src=".github/images/dfhack_launcher.png" alt="DFHack Launcher" width="100%"> | <img src=".github/images/dfhack_control_panel.png" alt="DFHack Control Panel" width="100%"> |

---

## 📦 Installation

### Steam Workshop (Recommended)

> **Prerequisite**: [DFHack](https://store.steampowered.com/app/2346660) 53.14+ must be installed for Dwarf Fortress.

1. Subscribe to the mod on [Steam Workshop](https://steamcommunity.com/sharedfiles/filedetails/?id=3762474859)
2. Launch Dwarf Fortress with DFHack — the plugin auto-enables (look for **「汉化」** in the bottom-left corner)
3. Press **Ctrl-Alt-K** to toggle Chinese display

### Manual Installation

1. Install [DFHack](https://github.com/DFHack/dfhack/releases) 53.14+ for Dwarf Fortress
2. Download the latest `dfzh-v*.*.*-**.**-**-win64.zip` from [Releases](https://github.com/wodzys/dwarf-fortress-chinese/releases)
3. Extract the zip into the DF mods directory:
   ```
   C:\Users\<YourUserName>\AppData\Roaming\Bay 12 Games\Dwarf Fortress\mods\
   ```
   The extracted folder will be named like `dfzh-v0.8.2-53.15-r1`, with a directory structure like:
   ```
   ...\Dwarf Fortress\mods\dfzh-v0.8.2-53.15-r1\info.txt
   ```
4. Launch the game — the plugin auto-loads (look for **「汉化」** in the bottom-left corner)
5. Press **Ctrl-Alt-K** to toggle Chinese display

> **Report issues**: [GitHub Issues](https://github.com/wodzys/dwarf-fortress-chinese/issues)

---

## ✨ Features

- **Real-time full-UI translation** — menus, items, creatures, buildings, announcements, all translated on every frame
- **Two-tier translation engine**: CSV exact-match dictionary + TOML recursive rewriting rules for composite text (material + item combinations)
- **Smart sentence detection** — groups individual characters into sentences using position, case & punctuation rules
- **TTF Chinese font rendering** — dynamically loads SDL2_ttf, supports multiple font sizes and rendering modes
- **Color preservation** — retains original text colors, supports dynamic color updates in real time
- **Untranslated text collection** — auto-captures missed text (FIFO, max 2000 entries) for one-click export

---

## ⌨️ Usage

Once installed (via Steam Workshop or manually), the plugin auto-loads on game launch. Look for **「汉」** in the bottom-left corner, then press **Ctrl-Alt-K** to toggle Chinese display.

### Hotkeys

| Hotkey | Command | Action |
|--------|---------|--------|
| `Ctrl-Alt-L` | `dfzh save_untrans` | Export collected untranslated texts to log |
| `Ctrl-Alt-R` | `dfzh reload_dicts` | Reload dictionaries & rulesets, clear texture cache |
| `Ctrl-Alt-K` | `dfzh show_ch` | Toggle Chinese translation on/off |

---

## ❓ FAQ

**Q: Does this work with the Steam version of Dwarf Fortress?**  
A: Yes! The plugin is tested and confirmed working on the Steam version of Dwarf Fortress.

**Q: Do I need to install DFHack separately?**  
A: Yes. This is a DFHack plugin and requires DFHack 53.14+ to run. See [DFHack installation guide](https://docs.dfhack.org/en/stable/docs/installing.html).

**Q: What content is covered by the translation?**  
A: The plugin translates on-screen UI text in real time — menus, buttons, item descriptions, creature names, building interfaces, announcements, and most in-game text. Translation data is community-maintained and continuously expanding.

**Q: How can I report translation errors or missing text?**  
A: Use `Ctrl-Alt-L` to export untranslated text, then open an issue on [GitHub Issues](https://github.com/wodzys/dwarf-fortress-chinese/issues) or contribute via the [Dwarf Fortress Chinese Wiki](https://dfzh.huijiwiki.com/).

**Q: Can I use my own font?**  
A: Yes. Set `FONT_FILE` in `data/dfzh_config.txt` to your preferred TTF font path.

---

## ⚙️ Configuration

Edit `data/dfzh_config.txt` (`[KEY:VALUE]` format). All paths resolve relative to `<hack>/data/dfzh/`:

| Key | Description | Default |
|-----|-------------|---------|
| `FONT_FILE` | TTF font path | `fonts/MapleMonoNL-CN-Bold.ttf` |
| `LOG_FILE` | Log file path | `logs/dfzh.log` |
| `DICT_EXACT` | Exact-match dictionary | `dfzh_dict_exact.csv` |
| `DICT_WORD` | Word-level dictionary | `dfzh_dict_word.csv` |

### Dictionary Format

CSV with three fields: `"english","translation","control"`. Example:

```csv
"Continue Playing","继续游戏",
"DFHack Launcher","DFHack启动器","c"
"Hello World","你好 \a#FF0000世界\a","s"
```

See [Dictionary Format](#) for control character details.

---

<details>
<summary><b>🔧 Technical Architecture</b> (click to expand)</summary>

### Per-Frame Rendering Pipeline

```
Screen Buffer (DF Memory: gps.screen / gps.screen_top)
       │
       ▼
SentenceDetector.detectSentences()    Char-level → sentence/word grouping
       │
       ▼
ScreenManager::processTranslations()
  ├─ 1. DICTIONARY.tryTranslate()     CSV exact match (digit normalization)
  └─ 2. RULESETS.translate()          TOML rule engine (recursive rewrite + @placeholder)
       │
       ▼
TTFManager::RenderBlendedText()       Chinese TTF → SDL_Surface → SDL_Texture
       │
       ▼
LRU Texture Cache (500 entries)       Hit → reuse, Miss → regenerate
       │
       ▼
SDL_RenderCopy (via g_sdl2 hooks)     Composite onto game display
```

### Key Modules

| Module | Responsibility |
|--------|----------------|
| **ScreenManager** | Core dispatcher: buffer processing, translation dispatch, texture cache & rendering |
| **DictManager** | CSV dictionary: exact match + digit normalization, thread-safe |
| **RulesetsManager** | TOML rule engine: recursive rewriting, `@placeholder` capture, cycle detection, LRU memoization |
| **SentenceDetector** | Char-level text detection using compile-time lookup tables |
| **TTFManager** | Runtime SDL2_ttf loading, font matching by pixel height |
| **LoggerManager** | spdlog async logger: rotating file (10MB×3) + untranslated text log |

</details>

---

## 🏗️ Building from Source

DFHack plugins must be compiled within the DFHack source tree:

1. Place this directory at `plugins/df_chinese/` inside the DFHack source tree
2. Edit `build/win64/DF_PATH.txt` to point to your DF installation
3. Open **x64 Native Tools Command Prompt for VS 2022** and run:

```batch
cd build\win64
generate-MSVC-gui.bat
build-debug.bat
install-debug.bat
```

Dependencies (vcpkg-managed): detours, spdlog, tomlplusplus. SDL2_ttf downloaded at configure time.

See [DFHack Compilation Guide](https://docs.dfhack.org/en/stable/docs/dev/compile/Compile.html#windows) for full environment setup.

---

## 🙏 Acknowledgments

### Algorithm Reference
The rule-based translation engine (RulesetsManager) is an independent C++ reimplementation inspired by [DFI18n/dfi18n](https://github.com/DFI18n/dfi18n) (MIT). Optimizations include LRU memoization cache, compile-time lookup tables, and heterogeneous lookup.

### Translation Data
Copyright of the [Dwarf Fortress Chinese Wiki](https://dfzh.huijiwiki.com/) translation group, licensed under [CC BY-NC 4.0](https://creativecommons.org/licenses/by-nc/4.0/deed.en).

### Third-Party Libraries
| Library | License |
|---------|---------|
| [spdlog](https://github.com/gabime/spdlog) | MIT |
| [toml++](https://github.com/marzer/tomlplusplus) | MIT |
| [Microsoft Detours](https://github.com/microsoft/Detours) | MIT |
| [SDL2_ttf](https://github.com/libsdl-org/SDL_ttf) | zlib |
| [Maple Mono NF CN](https://github.com/subframe7536/maple-font) | SIL OFL 1.1 |

---

## 📄 License

Source code (C++) — **MIT**.  
Translation data (`data/rulesets/`) — **CC BY-NC 4.0**.  
Fonts (`data/fonts/`) — **SIL Open Font License 1.1**.  

Copyright (c) 2026 0x53an
