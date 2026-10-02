<p align="center"><img src="docs/icon.png" width="128" alt="Unbind 아이콘"></p>
<h1 align="center">Unbind</h1>
<p align="center">포트를 감시하고 클릭 한 번으로 비워 주는 macOS 메뉴바 앱</p>
<p align="center"><a href="README.md">English</a> · <b>한국어</b> · <a href="README.zh.md">中文</a> · <a href="README.ja.md">日本語</a></p>

---

"3000번 포트가 이미 사용 중" — Unbind는 누가 포트를 잡고 있는지 보여 주고 메뉴바에서 바로 종료해요.

## 기능

- **포트 감시**: 감시 중인 포트가 모두 비어 있으면 뽑힌 플러그, 사용 중이면 꽂힌 플러그와 개수 표시
- **프로세스 정보**: 이름, PID, TCP/UDP, 작업 폴더, 실행 시간 (마우스를 올리면 전체 명령어)
- **종료**: 첫 클릭은 SIGTERM, 다시 누르면 SIGKILL. 권한이 필요하면 관리자 암호로 종료
- **Docker**: Docker가 잡은 포트는 컨테이너 이름으로 보여 주고 `docker stop`으로 중지
- **라벨·그룹·자동 종료**: 포트에 이름 붙이기, 그룹으로 묶고 한 번에 종료, 포트를 잡는 프로세스 자동 종료
- **알림**: 감시 포트가 사용 시작되거나 비면 알림
- **다른 열린 포트**: 감시하지 않는 TCP 포트 목록, 클릭 한 번으로 감시 추가
- 설정: 조회 주기(1/2/5/10초), 알림, 로그인 시 실행

## 요구 사항

- macOS 26 이상
- Xcode 26 이상 (빌드용)

## 빌드와 설치

```sh
git clone https://github.com/a01085464081-afk/Unbind.git
cd Unbind
./build.sh
cp -R Unbind.app /Applications/
open /Applications/Unbind.app
```

`build.sh`가 자체 점검, 아이콘·앱 컴파일, 애드혹 서명까지 해요.

## 사용법

1. 메뉴바의 플러그 아이콘 클릭
2. 감시할 포트 입력 (예: `3000, 8080`) 후 Enter
3. 사용 중인 포트 옆 **종료** 클릭. 안 꺼지면 한 번 더 (**강제 종료**)
4. ✏️ 버튼으로 라벨·그룹·자동 종료 편집
5. 아래 **설정**에서 조회 주기, 알림, 로그인 시 실행 설정

## 아이콘

터미널 커서(`_`)에서 뽑혀 나간 플러그 — "포트가 비었다"는 뜻이에요. 파일과 사용 규칙은 [logo/README.md](logo/README.md)를 보세요.

| 앱 아이콘 | 메뉴바 (비어 있음) | 메뉴바 (사용 중) |
|:-:|:-:|:-:|
| <img src="docs/icon.png" width="64"> | <img src="logo/final/menubar-free@2x.png"> | <img src="logo/final/menubar-busy@2x.png"> |

## 라이선스

[MIT](LICENSE)
