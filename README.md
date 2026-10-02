<p align="center"><img src="docs/icon.png" width="128" alt="Unbind icon"></p>
<h1 align="center">Unbind</h1>
<p align="center"><b>Free any port in one click, right from your menu bar.</b></p>
<p align="center"><b>English</b> · <a href="README.ko.md">한국어</a> · <a href="README.zh.md">简体中文</a> · <a href="README.zh-Hant.md">繁體中文</a> · <a href="README.ja.md">日本語</a></p>

<p align="center"><img src="docs/screenshot.png" width="406" alt="Unbind screenshot"></p>

---

`Error: listen EADDRINUSE: address already in use :::3000`

You know the drill: `lsof -i :3000`, squint at the output, copy a PID, `kill -9`, try again. Or hunt down the forgotten terminal tab, the zombie dev server, the Docker container you started last week.

**Unbind skips all of that.** It sits in your menu bar, watches the ports you care about, and tells you what's holding each one. One click frees it.

## Why Unbind

- **See it at a glance**: the menu bar plug is unplugged when every watched port is free, and plugged in with a count when any are busy. No need to open anything
- **Know exactly what's running**: process name, PID, TCP/UDP, working folder and uptime. Hover to see the full command
- **Kill it, politely or not**: the first click sends SIGTERM so it can shut down cleanly; click again to SIGKILL. Asks for your admin password only when it has to
- **Docker-aware**: ports held by Docker show the container name, not a cryptic `com.docker.backend`, and are stopped properly with `docker stop`
- **Organize your stack**: label ports (`3000 → web`, `5432 → db`), group them, and free a whole group with "kill all"
- **Auto-kill**: mark a port and Unbind frees it whenever something grabs it
- **Get notified**: find out when a watched port becomes busy or free
- **Spot the strays**: unwatched open TCP ports are listed too; start watching any of them with one click
- **Tune it**: refresh every 1, 2, 5 or 10 seconds, toggle notifications, launch at login
- **Speaks your language**: English, 한국어, 日本語, 简体中文, 繁體中文. Follows your macOS language by default (others fall back to English), or pick one in Settings
- **Small and native**: one SwiftUI file, no Electron, no telemetry, MIT licensed

## Requirements

- macOS 26 or later
- Building from source only: Command Line Tools (`xcode-select --install`). Xcode is optional and only adds the Liquid Glass icon

## Install (Homebrew)

```sh
brew tap syc-labs/unbind https://github.com/syc-labs/Unbind
brew install --cask syc-labs/unbind/unbind
```

If macOS blocks the first launch:

1. Click **Done** on the warning
2. Open **System Settings → Privacy & Security** and scroll down
3. Click **Open Anyway** next to the Unbind message, then confirm with your password

You only need to do this once after each install or update.

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
