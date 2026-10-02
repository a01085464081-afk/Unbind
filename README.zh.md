<p align="center"><img src="docs/icon.png" width="128" alt="Unbind 图标"></p>
<h1 align="center">Unbind</h1>
<p align="center">监视端口并一键释放的 macOS 菜单栏应用</p>
<p align="center"><a href="README.md">English</a> · <a href="README.ko.md">한국어</a> · <b>简体中文</b> · <a href="README.zh-Hant.md">繁體中文</a> · <a href="README.ja.md">日本語</a></p>

---

"端口 3000 已被占用"——Unbind 会显示是谁占用了端口，并让你直接在菜单栏中结束它。

## 功能

- **端口监视**：所有监视端口空闲时显示拔出的插头，有端口被占用时显示插入的插头和数量
- **进程信息**：名称、PID、TCP/UDP、工作目录、运行时长（悬停可查看完整命令）
- **结束进程**：第一次点击发送 SIGTERM，再次点击发送 SIGKILL。需要权限时可用管理员密码结束
- **Docker**：Docker 占用的端口以容器名显示，并通过 `docker stop` 停止
- **标签、分组、自动结束**：为端口命名、分组并一键全部结束、自动结束占用端口的进程
- **通知**：监视端口被占用或释放时通知
- **其他开放端口**：列出未监视的 TCP 端口，一键加入监视
- 设置：刷新间隔（1/2/5/10 秒）、通知、登录时启动、语言
- **语言**：English、한국어、日本語、简体中文、繁體中文。默认跟随 macOS 系统语言（其他语言显示英语），也可在设置中手动选择

## 系统要求

- macOS 26 或更高版本
- Xcode 26 或更高版本（用于构建）

## 安装（Homebrew）

```sh
brew tap syc-labs/unbind https://github.com/syc-labs/Unbind
brew install --cask syc-labs/unbind/unbind
```

Unbind 未经 Apple 公证，首次启动时 macOS 可能会阻止运行。请运行一次以下命令，或在 系统设置 → 隐私与安全性 中点击 **仍要打开**。

```sh
xattr -dr com.apple.quarantine /Applications/Unbind.app
```

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
