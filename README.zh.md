<p align="center"><img src="docs/icon.png" width="128" alt="Unbind 图标"></p>
<h1 align="center">Unbind</h1>
<p align="center"><b>在菜单栏一键释放任意端口</b></p>
<p align="center"><a href="README.md">English</a> · <a href="README.ko.md">한국어</a> · <b>简体中文</b> · <a href="README.zh-Hant.md">繁體中文</a> · <a href="README.ja.md">日本語</a></p>

<p align="center"><img src="docs/screenshot.png" width="406" alt="Unbind 截图"></p>

---

`Error: listen EADDRINUSE: address already in use :::3000`

熟悉的流程：敲 `lsof -i :3000`，盯着输出找 PID，复制，`kill -9`，再重试一遍。要么就得去翻那个忘了关的终端标签页、变成僵尸的开发服务器，或者上周启动的 Docker 容器。

**有了 Unbind，这些都省了。** 它常驻菜单栏，监视你关心的端口，告诉你是谁占用了它们，一键即可释放。

## 为什么选择 Unbind

- **一眼看清**：所有监视端口空闲时显示拔出的插头，有端口被占用时显示插入的插头和数量，无需打开任何东西
- **清楚知道在运行什么**：进程名、PID、TCP/UDP、工作目录、运行时长，悬停可查看完整命令
- **先礼后兵**：第一次点击发送 SIGTERM，让进程从容退出；再点一次发送 SIGKILL。只在确有需要时才要求管理员密码
- **懂 Docker**：Docker 占用的端口显示容器名，而不是费解的 `com.docker.backend`，并通过 `docker stop` 正确停止
- **按你的技术栈整理**：为端口加标签（`3000 → web`、`5432 → db`），分组，并按组"全部结束"
- **自动结束**：标记的端口一旦被占用，Unbind 就会自动释放
- **通知**：监视端口被占用或释放时提醒你
- **发现漏网端口**：同时列出未监视的开放 TCP 端口，一键加入监视
- **按需调整**：刷新间隔 1/2/5/10 秒，通知开关，登录时启动
- **说你的语言**：English、한국어、日本語、简体中文、繁體中文。默认跟随 macOS 系统语言（其他语言显示英语），也可在设置中手动选择
- **小巧原生**：单个 SwiftUI 文件，没有 Electron，没有遥测，MIT 许可

## 系统要求

- macOS 26 或更高版本
- 仅从源码构建时需要：Command Line Tools（`xcode-select --install`）。Xcode 可选，安装后会使用 Liquid Glass 图标

## 安装（Homebrew）

```sh
brew tap syc-labs/unbind https://github.com/syc-labs/Unbind
brew install --cask syc-labs/unbind/unbind
```

如果首次启动时被 macOS 阻止：

1. 在警告窗口中点击 **完成**
2. 打开 **系统设置 → 隐私与安全性**，向下滚动
3. 点击 Unbind 提示旁的 **仍要打开**，并输入密码确认

每次安装或更新后只需操作一次。

更新：

```sh
brew upgrade --cask syc-labs/unbind/unbind
```

## 卸载

先在菜单栏中点击 **退出**，然后：

```sh
brew uninstall --cask syc-labs/unbind/unbind
```

如需同时删除设置和 tap：

```sh
brew uninstall --zap --cask syc-labs/unbind/unbind
brew untap syc-labs/unbind
```

如果是从源码构建安装的：

```sh
rm -rf /Applications/Unbind.app
defaults delete local.unbind
```

## 从源码构建

```sh
git clone https://github.com/syc-labs/Unbind.git
cd Unbind
./build.sh
cp -R Unbind.app /Applications/
open /Applications/Unbind.app
```

`build.sh` 会运行自检、编译图标和应用，并进行 ad-hoc 签名。

## 使用方法

1. 点击菜单栏中的插头图标
2. 输入要监视的端口（例如 `3000, 8080`），按回车
3. 点击被占用端口旁的 **结束**。如果没有退出，再点一次（**强制结束**）
4. 用 ✏️ 按钮编辑标签、分组和自动结束
5. 在底部 **设置** 中设置刷新间隔、通知、登录时启动、语言

## 图标

从终端光标（`_`）上拔出的插头——表示"端口已空"。文件与使用规范见 [logo/README.md](logo/README.md)（韩语）。

| 应用图标 | 菜单栏（空闲） | 菜单栏（占用） |
|:-:|:-:|:-:|
| <img src="docs/icon.png" width="64"> | <img src="logo/final/menubar-free@2x.png"> | <img src="logo/final/menubar-busy@2x.png"> |

## 许可证

[MIT](LICENSE)
