<p align="center"><img src="docs/icon.png" width="128" alt="Unbind icon"></p>
<h1 align="center">Unbind</h1>
<p align="center">A macOS menu bar app that watches your ports and frees them in one click.</p>
<p align="center"><b>English</b> · <a href="README.ko.md">한국어</a> · <a href="README.zh.md">简体中文</a> · <a href="README.zh-Hant.md">繁體中文</a> · <a href="README.ja.md">日本語</a></p>

<p align="center"><img src="docs/screenshot.png" width="406" alt="Unbind screenshot"></p>

---

"Port 3000 is already in use" — Unbind shows who is holding it and lets you kill it right from the menu bar.

## Features

- **Port watch**: the menu bar icon is unplugged when all watched ports are free, plugged in with a count when any are busy
- **Process details**: name, PID, TCP/UDP, working folder, uptime (hover for the full command)
- **Kill**: first click sends SIGTERM, second click sends SIGKILL. Asks for an admin password when needed
- **Docker**: ports held by Docker are shown by container name and stopped with `docker stop`
- **Labels, groups, auto-kill**: name ports, group them, "kill all" per group, auto-kill whatever grabs a port
- **Notifications**: when a watched port becomes busy or free
- **Other open ports**: lists unwatched TCP ports, add any with one click
- Settings: refresh interval (1/2/5/10s), notifications, launch at login, language
- **Languages**: English, 한국어, 日本語, 简体中文, 繁體中文 — follows your macOS language by default (others fall back to English), or pick one in Settings

## Requirements

- macOS 26 or later
- Building from source only: Command Line Tools (`xcode-select --install`). Xcode is optional and only adds the Liquid Glass icon

## Install (Homebrew)

```sh
brew tap syc-labs/unbind https://github.com/syc-labs/Unbind
brew install --cask syc-labs/unbind/unbind
```

If macOS blocks the first launch, run this once, or allow it in System Settings → Privacy & Security → **Open Anyway**.

```sh
xattr -dr com.apple.quarantine /Applications/Unbind.app
```

To update:

```sh
brew upgrade --cask syc-labs/unbind/unbind
```

## Uninstall

Quit Unbind from the menu bar (**Quit**), then:

```sh
brew uninstall --cask syc-labs/unbind/unbind
```

To also remove settings and the tap:

```sh
brew uninstall --zap --cask syc-labs/unbind/unbind
brew untap syc-labs/unbind
```

If you built from source:

```sh
rm -rf /Applications/Unbind.app
defaults delete local.unbind
```

## Build from source

```sh
git clone https://github.com/syc-labs/Unbind.git
cd Unbind
./build.sh
cp -R Unbind.app /Applications/
open /Applications/Unbind.app
```

`build.sh` runs the self-check, compiles the icon and app, and ad-hoc signs it.

## Usage

1. Click the plug icon in the menu bar
2. Type ports to watch, e.g. `3000, 8080`, then press Enter
3. Click **Kill** next to a busy port. Click again (**Force Kill**) if it won't quit
4. Use the ✏️ button to edit labels, groups and auto-kill
5. **Settings** at the bottom: refresh interval, notifications, launch at login, language

## Icon

An unplugged plug above a terminal cursor (`_`) — "the port is empty". See [logo/README.md](logo/README.md) for the files and rules.

| App icon | Menu bar (free) | Menu bar (busy) |
|:-:|:-:|:-:|
| <img src="docs/icon.png" width="64"> | <img src="logo/final/menubar-free@2x.png"> | <img src="logo/final/menubar-busy@2x.png"> |

## License

[MIT](LICENSE)
