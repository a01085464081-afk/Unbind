<p align="center"><img src="docs/icon.png" width="128" alt="Unbind アイコン"></p>
<h1 align="center">Unbind</h1>
<p align="center"><b>メニューバーから、ワンクリックでポートを解放</b></p>
<p align="center"><a href="README.md">English</a> · <a href="README.ko.md">한국어</a> · <a href="README.zh.md">简体中文</a> · <a href="README.zh-Hant.md">繁體中文</a> · <b>日本語</b></p>

<p align="center"><img src="docs/screenshot.png" width="406" alt="Unbind スクリーンショット"></p>

---

`Error: listen EADDRINUSE: address already in use :::3000`

おなじみの流れです。`lsof -i :3000` を打ち、出力を目で追って PID をコピーし、`kill -9`、そしてやり直し。あるいは、閉じ忘れたターミナルタブや、ゾンビ化した開発サーバー、先週起動した Docker コンテナを探し回ることに。

**Unbind ならその手間はいりません。** メニューバーに常駐して大事なポートを見張り、何が掴んでいるかを教えてくれます。解放はワンクリックです。

## Unbind を選ぶ理由

- **ひと目でわかる**：監視中のポートがすべて空いていれば抜けたプラグ、使用中があればささったプラグと数を表示。何も開く必要はありません
- **何が動いているか正確に**：プロセス名、PID、TCP/UDP、作業フォルダ、実行時間。ホバーでコマンド全体を表示
- **まずは穏やかに、だめなら強制で**：1 回目のクリックで SIGTERM を送ってきれいに終了させ、もう一度で SIGKILL。管理者パスワードは本当に必要なときだけ
- **Docker 対応**：Docker が使うポートは分かりにくい `com.docker.backend` ではなくコンテナ名で表示し、`docker stop` で正しく停止
- **自分のスタックに合わせて整理**：ポートにラベルを付け（`3000 → web`、`5432 → db`）、グループ化して「すべて終了」
- **自動終了**：指定したポートは、何かが掴むたびに Unbind が自動で解放
- **通知**：監視ポートが使用開始・解放されたときにお知らせ
- **見落としているポートも**：監視していない開いている TCP ポートも一覧表示、ワンクリックで監視に追加
- **好みに合わせて**：更新間隔 1・2・5・10 秒、通知のオン・オフ、ログイン時に起動
- **あなたの言語で**：English、한국어、日本語、简体中文、繁體中文。初期設定では macOS の言語に合わせ（その他の言語は英語）、設定から選ぶこともできます
- **小さくてネイティブ**：SwiftUI ファイル 1 つ、Electron なし、テレメトリなし、MIT ライセンス

## 動作環境

- macOS 26 以降
- ソースからビルドする場合のみ：Command Line Tools（`xcode-select --install`）。Xcode は任意で、あれば Liquid Glass アイコンが入ります

## インストール（Homebrew）

```sh
brew tap syc-labs/unbind https://github.com/syc-labs/Unbind
brew install --cask syc-labs/unbind/unbind
```

初回起動時に macOS にブロックされた場合：

1. 警告ウインドウで **完了** をクリック
2. **システム設定 → プライバシーとセキュリティ** を開き、下にスクロール
3. Unbind のメッセージの横にある **このまま開く** をクリックし、パスワードを入力

インストールまたはアップデートのたびに一度だけ行えば大丈夫です。

アップデート：

```sh
brew upgrade --cask syc-labs/unbind/unbind
```

## アンインストール

メニューバーで **終了**をクリックしてから：

```sh
brew uninstall --cask syc-labs/unbind/unbind
```

設定と tap も削除するには：

```sh
brew uninstall --zap --cask syc-labs/unbind/unbind
brew untap syc-labs/unbind
```

ソースからビルドしてインストールした場合：

```sh
rm -rf /Applications/Unbind.app
defaults delete local.unbind
```

## ソースからビルド

```sh
git clone https://github.com/syc-labs/Unbind.git
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
