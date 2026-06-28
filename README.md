# KeeperFX

![KeeperFX Logo](/docs/assets/readme-banner.png)

![PRs welcome](https://img.shields.io/badge/PRs-welcome-brightgreen?style=flat-square)
![Release](https://img.shields.io/github/v/release/dkfans/keeperfx?style=flat-square)
![Downloads](https://img.shields.io/github/downloads/dkfans/keeperfx/total?style=flat-square)
[![Discord](https://img.shields.io/discord/480505152806191114?style=flat-square)](https://discord.gg/hE4p7vy2Hb)

[Visit our website](https://keeperfx.net) | [Join our Discord (Keeper Klan)](https://discord.gg/hE4p7vy2Hb)

> **DoubyCz fork note:** This fork exists primarily to provide a reliable
> **native Linux build** of KeeperFX — a portable **AppImage** that runs on most
> distributions and an **Arch AUR** package — together with the fixes needed to
> build cleanly on modern Linux toolchains. See the [Linux](#linux) section.


## Intro
KeeperFX (Dungeon Keeper Fan eXpansion) is an open-source project that aims to fix up, enhance and modernize 
the classic dungeon management game, [Dungeon Keeper](https://en.wikipedia.org/wiki/Dungeon_Keeper).
This project is dedicated to providing an improved and customizable gaming experience while staying true to the spirit of the original game.

KeeperFX is a standalone game but requires a copy of the original game files as proof of ownership.
These files can be automatically copied from your old CDs, or from a digital edition like the ones from EA or GOG.

Originally, KeeperFX started out as a decompilation project, where we took the original game executables and reversed them back into usable code. 
Currently the whole codebase of Dungeon Keeper is remade and all code has been rewritten.


## Features
- Windows 7/10/11 support
- Linux support (portable AppImage, x86_64)
- Higher screen resolutions
- Increased FPS, decoupled gfx and game logic
- Improved and modernized controls
- Many bugfixes
- Map, campaign and modding customizability
- Improved AI
- Modern multiplayer protocol
- Additional campaigns, maps, creatures and other content
- ...


## How to play

Installation instructions and a FAQ can be found on the [Github Wiki](https://github.com/dkfans/keeperfx/wiki).

You will need the original Dungeon Keeper files, either from an old CD or from the digital edition available on
[EA](https://www.ea.com/games/dungeon-keeper/dungeon-keeper),
[GOG](https://www.gog.com/game/dungeon_keeper)
or [Steam](https://store.steampowered.com/app/1996630/Dungeon_Keeper_Gold/).


## Linux

KeeperFX runs natively on Linux. The easiest way is the **portable AppImage**,
which runs on most modern x86_64 distributions (Ubuntu, Fedora, Linux Mint,
Debian, Arch, …) **without installing any dependencies** — the engine, a modern
SDL2, ffmpeg and all other libraries are bundled inside.

### Quick start
1. Download `KeeperFX-<version>-linux-x86_64.AppImage` from the
   [Releases](https://github.com/DoubyCz/keeperfx/releases) page.
2. Make it executable: `chmod +x KeeperFX-*-x86_64.AppImage`
3. Run it: `./KeeperFX-*-x86_64.AppImage`

On the first run it creates a game folder at `~/.local/share/keeperfx`, fills it
with the free KeeperFX data, and tells you that the original Dungeon Keeper files
are still needed.

### Adding the original game data
KeeperFX needs the original Dungeon Keeper files (you must own the game — GOG /
Steam / CD); they are **not bundled** for copyright reasons. Copy the contents of
your original `data`, `sound`, `ldata` and `levels` folders into
`~/.local/share/keeperfx/` (GOG: the install folder; CD: the `keeper` folder),
then start the AppImage again. To use a different game folder, run
`KEEPERFX_HOME=/path/to/dir ./KeeperFX-*.AppImage`.

### Requirements & notes
- **x86_64** only.
- A reasonably **recent distribution**: the AppImage is built on Debian 12
  (glibc 2.36), so it runs on Ubuntu 22.10+/24.04, Fedora 37+, Mint 22+,
  Debian 12+, Arch and similar. Very old releases (e.g. Ubuntu 22.04 / Mint 21,
  glibc 2.35) may be too old.
- **FUSE** is needed to mount the AppImage. If your distribution lacks it,
  install `libfuse2`, or run the AppImage with `--appimage-extract-and-run`.
- The **first start** is a little slower (the image is mounted and the bundled
  data is copied into your game folder once).
- Works on both **X11 and Wayland**, including **multi-monitor** setups.

### Arch Linux
Arch users can also use the `keeperfx-git` AUR package, which builds from source
and integrates natively, instead of the AppImage. *(planned)*

### Building the AppImage yourself
The AppImage is built reproducibly in a Debian 12 container; see
[`dist/linux/build-appimage.sh`](dist/linux/build-appimage.sh) and the
[`Build Linux AppImage`](.github/workflows/linux-appimage.yml) workflow.


## Development
To get started with KeeperFX development, refer to the [Development Guide](https://github.com/dkfans/keeperfx/wiki/Building-KeeperFX) for 
detailed instructions on setting up a development environment and building KeeperFX from source.

If you wish to discuss development, you can join the [Keeper Klan discord](https://discord.gg/hE4p7vy2Hb) and ask to 
be added to the KeeperFX development channel.


## Components
| Component | Language | Info |
|---|---|---|
| [KeeperFX](https://github.com/dkfans/keeperfx) | C, C++ | - |
| [Launcher](https://github.com/dkfans/keeperfx-launcherwx) | C++ | Official Launcher to edit settings and start the game with run options. |
| [FXGraphics](https://github.com/dkfans/FXGraphics) | - | Sources of KeeperFX graphics files. |
| [FXSounds](https://github.com/dkfans/FXsounds) | - | Sources of KeeperFX audio files. |
| [Masterserver](https://github.com/dkfans/keeperfx-masterserver) | PHP (CLI) | Multiplayer masterserver. Allows players to easily find public lobbies of others. |
| [Website](https://github.com/dkfans/keeperfx-website) | PHP | https://keeperfx.net |


## Tools
| Tool | Usage |
|---|---|
| sndbanker | Makes usable ingame sounds from SFX archives. |
| po2ngdat | Converts `.po` files (language) to `.dat`. |
| png2bestpal | Decides the best in-game color palette for an image and creates a `.pal` file. |
| png2ico | Converts `.png` files to `.ico`. |
| pngpal2raw | Creates a `.raw` image file that can be used by the game from a `.png` and a `.pal` (palette) file. The palette file can be created with _png2bestpal_. |
| rnctools | Handles the RNC compression of many original DK data files. |
| dkillconv | An unfinished tool to convert a map to a text based format. |


## Further Improvements
KeeperFX could be further improved in these key areas:
- Multiplayer performance and features
- Expand and improve AI / Computer player behavior
- Improve pathfinding performance
- Expand creative freedom for modders even further
- Native cross-platform support
- Improve code readability and maintainability
- Lua support
- ...


## Contributing
We welcome contributions from the community to improve and expand KeeperFX.
- Report bugs by opening [issues](https://github.com/dkfans/keeperfx/issues).
- Submit feature requests and discuss potential improvements.
- Contribute code by creating pull requests. 


## Code Signing Policy
Free code signing provided by [SignPath.io](https://about.signpath.io/), certificate by [SignPath Foundation](https://signpath.org/).


## License
This project is licensed under the [GNU General Public License v2.0](LICENSE).
Feel free to use, modify, and distribute it according to the terms of this license.
