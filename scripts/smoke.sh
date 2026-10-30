#!/usr/bin/env bash
# 띄워둔 서버를 대상으로 API 상태 코드를 확인하고, 가능하면 화면 스크린샷을 남긴다.
# 사용: scripts/smoke.sh            (기본 API 127.0.0.1:$API_PORT|3000, 웹 127.0.0.1:$WEB_PORT|5173)
#       API=http://host:3000 WEB=http://host:5173 scripts/smoke.sh
#       SHOT=0 scripts/smoke.sh     (스크린샷 생략)
set -uo pipefail

API="${API:-http://127.0.0.1:${API_PORT:-3000}}"
WEB="${WEB:-http://127.0.0.1:${WEB_PORT:-5173}}"
OUT="${OUT:-.smoke}"
pass=0
fail=0

# check <METHOD> <PATH> <기대 상태 코드> [JSON 본문]
check() {
  local method="$1" path="$2" want="$3" data="${4:-}"
  local args=(-s -o "$OUT/body.txt" -w '%{http_code}' -X "$method" "$API$path")
  [ -n "$data" ] && args+=(-H 'Content-Type: application/json' -d "$data")
  local got
  got="$(curl "${args[@]}")"
  if [ "$got" = "$want" ]; then
    pass=$((pass + 1)); echo "통과  $method $path → $got"
  else
    fail=$((fail + 1)); echo "실패  $method $path → $got (기대 $want) $(head -c 200 "$OUT/body.txt")"
  fi
}

mkdir -p "$OUT"

# ---- 확인 목록: 기능이 생길 때마다 여기에 한 줄씩 추가한다 ----
check GET  /api/health         200
check GET  /api/__not_found__  404
# check POST /api/items 201 '{"title":"테스트"}'
# check POST /api/items 400 '{"title":""}'
# ------------------------------------------------------------

curl -s "$API/api/health" && echo

if [ "${SHOT:-1}" = "1" ]; then
  if npx --no-install playwright --version >/dev/null 2>&1; then
    npx --no-install playwright screenshot --full-page --viewport-size=1280,800 "$WEB" "$OUT/desktop.png" >/dev/null \
      && npx --no-install playwright screenshot --full-page --viewport-size=375,812 "$WEB" "$OUT/mobile.png" >/dev/null \
      && echo "스크린샷: $OUT/desktop.png, $OUT/mobile.png" \
      || echo "스크린샷 실패 (브라우저 미설치면: npx playwright install chromium)"
  else
    echo "스크린샷 생략: playwright 없음 (npm i -D playwright && npx playwright install chromium)"
  fi
fi

echo "결과: 통과 $pass, 실패 $fail"
[ "$fail" -eq 0 ]
