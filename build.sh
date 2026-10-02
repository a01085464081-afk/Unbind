#!/bin/bash
set -e
cd "$(dirname "$0")"
VERSION=1.2.0
BUILD=$(date +%Y%m%d%H%M)
# 파서 자체 점검
swiftc -D CHECK -parse-as-library Unbind.swift -o /tmp/unbind-check && /tmp/unbind-check
mkdir -p Unbind.app/Contents/MacOS Unbind.app/Contents/Resources
cp logo/final/menubar-*.png Unbind.app/Contents/Resources/
# 번역: 문법 검사, 언어별 키가 영어와 같은지 확인 후 복사
plutil -lint -s l10n/*.lproj/*.strings
for l in ja zh-Hans zh-Hant; do diff <(cut -d'"' -f2 l10n/en.lproj/Localizable.strings) <(cut -d'"' -f2 l10n/$l.lproj/Localizable.strings) || { echo "$l 번역 키 불일치"; exit 1; }; done
cp -R l10n/*.lproj Unbind.app/Contents/Resources/
# 앱 아이콘(.icon, 유리 효과 끔) → Assets.car + Unbind.icns
if xcrun -f actool >/dev/null 2>&1; then
  xcrun actool "$PWD/logo/final/Unbind.icon" --compile "$PWD/Unbind.app/Contents/Resources" --output-format human-readable-text \
    --errors --output-partial-info-plist /tmp/unbind-icon.plist --app-icon Unbind --include-all-app-icons \
    --enable-on-demand-resources NO --development-region ko --target-device mac --minimum-deployment-target 26.0 \
    --platform macosx >/dev/null
  test -f Unbind.app/Contents/Resources/Assets.car || { echo "아이콘 컴파일 실패"; exit 1; }
  cp Unbind.app/Contents/Resources/Unbind.icns logo/final/Unbind.icns  # Xcode 없는 빌드용
else
  # ponytail: Command Line Tools만 있으면 미리 만든 icns 사용 (Liquid Glass 아이콘 없음)
  cp logo/final/Unbind.icns Unbind.app/Contents/Resources/
fi
swiftc -O -parse-as-library Unbind.swift -o Unbind.app/Contents/MacOS/Unbind
cat > Unbind.app/Contents/Info.plist <<P
<?xml version="1.0" encoding="UTF-8"?>
<plist version="1.0"><dict>
<key>CFBundleExecutable</key><string>Unbind</string>
<key>CFBundleIdentifier</key><string>local.unbind</string>
<key>CFBundleDevelopmentRegion</key><string>en</string>
<key>CFBundleLocalizations</key><array><string>en</string><string>ko</string><string>ja</string><string>zh-Hans</string><string>zh-Hant</string></array>
<key>CFBundleName</key><string>Unbind</string>
<key>CFBundleIconFile</key><string>Unbind</string>
<key>CFBundleIconName</key><string>Unbind</string>
<key>CFBundleShortVersionString</key><string>$VERSION</string>
<key>CFBundleVersion</key><string>$BUILD</string>
<key>LSUIElement</key><true/>
</dict></plist>
P
codesign -s - --force Unbind.app
