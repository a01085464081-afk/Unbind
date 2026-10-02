<p align="center"><img src="docs/icon.png" width="128" alt="Unbind 圖示"></p>
<h1 align="center">Unbind</h1>
<p align="center">監看連接埠並一鍵釋放的 macOS 選單列 App</p>
<p align="center"><a href="README.md">English</a> · <a href="README.ko.md">한국어</a> · <a href="README.zh.md">简体中文</a> · <b>繁體中文</b> · <a href="README.ja.md">日本語</a></p>

<p align="center"><img src="docs/screenshot.png" width="406" alt="Unbind 截圖"></p>

---

「連接埠 3000 已被佔用」——Unbind 會顯示是誰佔用了連接埠，並讓你直接在選單列中結束它。

## 功能

- **連接埠監看**：所有監看的連接埠都閒置時顯示拔出的插頭，有連接埠被佔用時顯示插入的插頭和數量
- **程序資訊**：名稱、PID、TCP/UDP、工作資料夾、執行時間（游標停留可查看完整指令）
- **結束程序**：第一次點按傳送 SIGTERM，再按一次傳送 SIGKILL。需要權限時可用管理員密碼結束
- **Docker**：Docker 佔用的連接埠以容器名稱顯示，並透過 `docker stop` 停止
- **標籤、群組、自動結束**：為連接埠命名、分組並一鍵全部結束、自動結束佔用連接埠的程序
- **通知**：監看的連接埠被佔用或釋放時通知
- **其他開啟的連接埠**：列出未監看的 TCP 連接埠，一鍵加入監看
- 設定：更新間隔（1/2/5/10 秒）、通知、登入時啟動、語言
- **語言**：English、한국어、日本語、简体中文、繁體中文。預設跟隨 macOS 系統語言（其他語言顯示英文），也可在設定中手動選擇

## 系統需求

- macOS 26 或以上版本
- Xcode 26 或以上版本（建置用）

## 安裝（Homebrew）

```sh
brew tap syc-labs/unbind https://github.com/syc-labs/Unbind
brew install --cask syc-labs/unbind/unbind
```

Unbind 未經 Apple 公證，首次開啟時 macOS 可能會阻擋。請執行一次以下指令，或在 系統設定 → 隱私權與安全性 中點按 **強制打開**。

```sh
xattr -dr com.apple.quarantine /Applications/Unbind.app
```

更新：

```sh
brew upgrade --cask syc-labs/unbind/unbind
```

## 解除安裝

先在選單列中點按 **結束 Unbind**，然後：

```sh
brew uninstall --cask syc-labs/unbind/unbind
```

如需一併刪除設定和 tap：

```sh
brew uninstall --zap --cask syc-labs/unbind/unbind
brew untap syc-labs/unbind
```

如果是從原始碼建置安裝的：

```sh
rm -rf /Applications/Unbind.app
defaults delete local.unbind
```

## 從原始碼建置

```sh
git clone https://github.com/syc-labs/Unbind.git
cd Unbind
./build.sh
cp -R Unbind.app /Applications/
open /Applications/Unbind.app
```

`build.sh` 會執行自我檢查、編譯圖示和 App，並進行 ad-hoc 簽署。

## 使用方式

1. 點按選單列中的插頭圖示
2. 輸入要監看的連接埠（例如 `3000, 8080`），按 Return
3. 點按被佔用連接埠旁的 **結束**。如果沒有結束，再按一次（**強制結束**）
4. 用 ✏️ 按鈕編輯標籤、群組和自動結束
5. 在底部 **設定** 中設定更新間隔、通知、登入時啟動、語言

## 圖示

從終端機游標（`_`）上拔出的插頭——表示「連接埠已空」。檔案與使用規範請見 [logo/README.md](logo/README.md)（韓文）。

| App 圖示 | 選單列（閒置） | 選單列（使用中） |
|:-:|:-:|:-:|
| <img src="docs/icon.png" width="64"> | <img src="logo/final/menubar-free@2x.png"> | <img src="logo/final/menubar-busy@2x.png"> |

## 授權條款

[MIT](LICENSE)
