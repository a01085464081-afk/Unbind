<p align="center"><img src="docs/icon.png" width="128" alt="Unbind アイコン"></p>
<h1 align="center">Unbind</h1>
<p align="center">ポートを監視し、ワンクリックで解放する macOS メニューバーアプリ</p>
<p align="center"><a href="README.md">English</a> · <a href="README.ko.md">한국어</a> · <a href="README.zh.md">简体中文</a> · <a href="README.zh-Hant.md">繁體中文</a> · <b>日本語</b></p>

---

「ポート 3000 は既に使用中です」——Unbind は誰がポートを掴んでいるかを表示し、メニューバーからすぐに終了できます。

## 機能

- **ポート監視**：監視中のポートがすべて空いていれば抜けたプラグ、使用中ならささったプラグと数を表示
- **プロセス情報**：名前、PID、TCP/UDP、作業フォルダ、実行時間（ホバーでコマンド全体を表示）
- **終了**：1 回目のクリックで SIGTERM、もう一度で SIGKILL。権限が必要な場合は管理者パスワードで終了
- **Docker**：Docker が使うポートはコンテナ名で表示し、`docker stop` で停止
- **ラベル・グループ・自動終了**：ポートに名前を付ける、グループ化して一括終了、ポートを掴むプロセスを自動終了
- **通知**：監視ポートが使用開始・解放されたときに通知
- **その他の開いているポート**：監視していない TCP ポートを一覧表示、ワンクリックで監視に追加
- 設定：更新間隔（1/2/5/10 秒）、通知、ログイン時に起動、言語
- **言語**：English、한국어、日本語、简体中文、繁體中文。初期設定では macOS の言語に合わせて自動で切り替わり（その他の言語は英語）、設定から選ぶこともできます

## 動作環境

- macOS 26 以降
- Xcode 26 以降（ビルド用）

## インストール（Homebrew）

```sh
brew install --cask a01085464081-afk/tap/unbind
```

Unbind は Apple の公証を受けていないため、初回起動時に macOS にブロックされることがあります。以下のコマンドを一度実行するか、システム設定 → プライバシーとセキュリティ で **このまま開く** をクリックしてください。

```sh
xattr -dr com.apple.quarantine /Applications/Unbind.app
```

アップデート：

```sh
brew upgrade --cask unbind
```

## アンインストール

メニューバーで **終了**をクリックしてから：

```sh
brew uninstall --cask unbind
```

設定と tap も削除するには：

```sh
brew uninstall --zap --cask unbind
brew untap a01085464081-afk/tap
```

ソースからビルドしてインストールした場合：

```sh
rm -rf /Applications/Unbind.app
defaults delete local.unbind
```

## ソースからビルド

```sh
git clone https://github.com/a01085464081-afk/Unbind.git
cd Unbind
./build.sh
cp -R Unbind.app /Applications/
open /Applications/Unbind.app
```

`build.sh` がセルフチェック、アイコンとアプリのコンパイル、ad-hoc 署名まで行います。

## 使い方

1. メニューバーのプラグアイコンをクリック
2. 監視するポートを入力（例：`3000, 8080`）して Enter
3. 使用中のポートの横にある **終了** をクリック。終了しなければもう一度（**強制終了**）
4. ✏️ ボタンでラベル・グループ・自動終了を編集
5. 下部の **設定** で更新間隔、通知、ログイン時に起動、言語を設定

## アイコン

ターミナルカーソル（`_`）から抜けたプラグ——「ポートが空いた」という意味です。ファイルと使用ルールは [logo/README.md](logo/README.md)（韓国語）を参照してください。

| アプリアイコン | メニューバー（空き） | メニューバー（使用中） |
|:-:|:-:|:-:|
| <img src="docs/icon.png" width="64"> | <img src="logo/final/menubar-free@2x.png"> | <img src="logo/final/menubar-busy@2x.png"> |

## ライセンス

[MIT](LICENSE)
