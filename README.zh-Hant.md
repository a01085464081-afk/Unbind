<p align="center"><img src="docs/icon.png" width="128" alt="Unbind 圖示"></p>
<h1 align="center">Unbind</h1>
<p align="center"><b>在選單列一鍵釋放任何連接埠</b></p>
<p align="center"><a href="README.md">English</a> · <a href="README.ko.md">한국어</a> · <a href="README.zh.md">简体中文</a> · <b>繁體中文</b> · <a href="README.ja.md">日本語</a></p>

<p align="center"><img src="docs/screenshot.png" width="406" alt="Unbind 截圖"></p>

---

`Error: listen EADDRINUSE: address already in use :::3000`

熟悉的流程：輸入 `lsof -i :3000`，盯著輸出找 PID，複製，`kill -9`，再重試一次。要不然就得去翻那個忘了關的終端機分頁、變成殭屍的開發伺服器，或是上週啟動的 Docker 容器。

**有了 Unbind，這些都省了。** 它常駐選單列，監看你在意的連接埠，告訴你是誰佔用了它們，一鍵即可釋放。

## 為什麼選擇 Unbind

- **一眼看清**：所有監看的連接埠都閒置時顯示拔出的插頭，有連接埠被佔用時顯示插入的插頭和數量，不必打開任何東西
- **清楚知道在執行什麼**：程序名稱、PID、TCP/UDP、工作資料夾、執行時間，游標停留可查看完整指令
- **先禮後兵**：第一次點按傳送 SIGTERM，讓程序從容結束；再按一次傳送 SIGKILL。只在確實需要時才要求管理員密碼
- **懂 Docker**：Docker 佔用的連接埠顯示容器名稱，而不是難懂的 `com.docker.backend`，並透過 `docker stop` 正確停止
- **依你的技術堆疊整理**：為連接埠加上標籤（`3000 → web`、`5432 → db`），分組，並按群組「全部結束」
- **自動結束**：標記的連接埠一旦被佔用，Unbind 就會自動釋放
- **通知**：監看的連接埠被佔用或釋放時提醒你
- **找出漏網連接埠**：同時列出未監看的開啟 TCP 連接埠，一鍵加入監看
- **依需求調整**：更新間隔 1/2/5/10 秒、通知開關、登入時啟動
- **說你的語言**：English、한국어、日本語、简体中文、繁體中文。預設跟隨 macOS 系統語言（其他語言顯示英文），也可在設定中手動選擇
- **小巧原生**：單一 SwiftUI 檔案，沒有 Electron，沒有遙測，MIT 授權

## 系統需求

- macOS 26 或以上版本
- 僅從原始碼建置時需要：Command Line Tools（`xcode-select --install`）。Xcode 為選用，安裝後會使用 Liquid Glass 圖示

## 安裝（Homebrew）

```sh
brew tap syc-labs/unbind https://github.com/syc-labs/Unbind
brew install --cask syc-labs/unbind/unbind
```

如果首次開啟時被 macOS 阻擋：

1. 在警告視窗中點按 **完成**
2. 打開 **系統設定 → 隱私權與安全性**，向下捲動
3. 點按 Unbind 訊息旁的 **強制打開**，並輸入密碼確認

每次安裝或更新後只需操作一次。

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
