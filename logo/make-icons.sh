#!/bin/sh
# final/menubar-*.svg → 메뉴바 PNG (앱 아이콘은 build.sh가 Unbind.icon에서 생성)
set -e
cd "$(dirname "$0")/final"
for n in free busy; do
  sed 's/viewBox="0 0 256 256" width="256" height="256"/viewBox="44 28 168 200" width="168" height="200"/' menubar-$n.svg > /tmp/mb.svg
  rsvg-convert -h 18 /tmp/mb.svg -o menubar-$n.png
  rsvg-convert -h 36 /tmp/mb.svg -o menubar-$n@2x.png
done
echo "아이콘 생성 완료"
