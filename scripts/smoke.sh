#!/usr/bin/env bash
# 띄워둔 백엔드의 API 상태 코드를 확인한다.
# 사용: scripts/smoke.sh                       (기본 http://127.0.0.1:${BACKEND_PORT:-8000})
#       API=http://host:8000 scripts/smoke.sh
set -uo pipefail

API="${API:-http://127.0.0.1:${BACKEND_PORT:-8000}}"
OUT="$(mktemp)"
trap 'rm -f "$OUT"' EXIT
pass=0
fail=0

# check <METHOD> <PATH> <기대 상태 코드> [JSON 본문]
check() {
  local method="$1" path="$2" want="$3" data="${4:-}"
  local args=(-s -o "$OUT" -w '%{http_code}' -X "$method" "$API$path")
  [ -n "$data" ] && args+=(-H 'Content-Type: application/json' -d "$data")
  local got
  got="$(curl "${args[@]}")"
  if [ "$got" = "$want" ]; then
    pass=$((pass + 1)); echo "통과  $method $path → $got"
  else
    fail=$((fail + 1)); echo "실패  $method $path → $got (기대 $want) $(head -c 200 "$OUT")"
  fi
}

# ---- 확인 목록: 기능이 생길 때마다 여기에 한 줄씩 추가한다 ----
check GET  /api/health         200
check GET  /api/__not_found__  404
# check POST /api/items 201 '{"title":"테스트"}'
# check POST /api/items 422 '{"title":""}'
# ------------------------------------------------------------

echo "결과: 통과 $pass, 실패 $fail"
[ "$fail" -eq 0 ]
