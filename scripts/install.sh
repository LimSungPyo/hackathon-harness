#!/usr/bin/env bash
# 하네스(규칙, 문서, 스크립트)를 과제 폴더에 복사한다. 이미 있는 파일은 절대 덮어쓰지 않는다.
# 사용: scripts/install.sh <과제 폴더> [--with-template]
#   --with-template  스타터 코드가 없을 때만. template/ 내용도 함께 복사한다.
set -euo pipefail

HERE="$(cd "$(dirname "$0")/.." && pwd)"
TARGET="${1:?과제 폴더 경로를 넣어 주세요}"
mkdir -p "$TARGET"

copy() {
  local src="$1" dst="$2"
  if [ -e "$dst" ]; then
    echo "건너뜀 (이미 있음): $dst"
  else
    mkdir -p "$(dirname "$dst")"
    cp "$src" "$dst"
    echo "복사: $dst"
  fi
}

copy "$HERE/AGENTS.md" "$TARGET/AGENTS.md"
for f in "$HERE"/docs/*.md; do copy "$f" "$TARGET/docs/$(basename "$f")"; done
copy "$HERE/scripts/smoke.sh" "$TARGET/scripts/smoke.sh"

if [ "${2:-}" = "--with-template" ]; then
  (cd "$HERE/template" && find . -type f ! -path './node_modules/*' ! -name 'package-lock.json') | while read -r f; do
    f="${f#./}"
    copy "$HERE/template/$f" "$TARGET/$f"
  done
fi

chmod +x "$TARGET/scripts/smoke.sh"
echo "끝. 다음: cd \"$TARGET\" && git status"
