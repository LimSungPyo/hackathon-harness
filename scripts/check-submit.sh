#!/usr/bin/env bash
# 제출 전 점검. 실패가 하나라도 있으면 종료 코드 1.
set -uo pipefail

fail=0
warn=0
ok()   { echo "통과  $1"; }
bad()  { echo "실패  $1"; fail=$((fail + 1)); }
note() { echo "주의  $1"; warn=$((warn + 1)); }

if [ -z "$(git status --porcelain)" ]; then ok "커밋 안 된 변경 없음"; else note "커밋 안 된 변경 있음: $(git status --porcelain | wc -l | tr -d ' ')개"; fi

envs="$(git ls-files | grep -E '(^|/)\.env($|\.)' | grep -v '\.env\.example$' || true)"
if [ -z "$envs" ]; then ok ".env가 커밋되지 않음"; else bad ".env 커밋됨: $envs"; fi

# 원래 비어 있어도 되는 파일(.gitkeep, __init__.py)은 뺀다
list_empty() {
  git ls-files | while read -r f; do
    [ -f "$f" ] && [ ! -s "$f" ] && echo "$f"
  done | grep -vE '(\.gitkeep|__init__\.py)$'
}
empty="$(list_empty || true)"
if [ -z "$empty" ]; then ok "비어 있는 파일 없음"; else bad "비어 있는 파일: $empty"; fi

secrets="$(git grep -nIE '(sk-[A-Za-z0-9_-]{20,}|AKIA[0-9A-Z]{16}|-----BEGIN [A-Z ]*PRIVATE KEY|ghp_[A-Za-z0-9]{30,})' -- . ':!package-lock.json' || true)"
if [ -z "$secrets" ]; then ok "비밀 키 모양의 문자열 없음"; else bad "비밀 키 의심: $(echo "$secrets" | cut -c1-120)"; fi

joined="$(git rev-list HEAD 2>/dev/null | while read -r c; do
  [ -n "$(git log -1 --format=%B "$c" | sed -n 2p)" ] && git log -1 --format='%h %s' "$c" | cut -c1-60
done)"
if [ -z "$joined" ]; then ok "커밋 메시지 제목·본문 사이 빈 줄"; else note "제목 아래 빈 줄이 없는 커밋: $joined"; fi

if [ -f README.md ] && grep -qE '실행|npm run|docker' README.md; then ok "README에 실행법 있음"; else bad "README 실행법 없음"; fi

ai="$(awk '/^## AI 제안 수정/{on=1; next} /^## /{on=0} on && /^\| A[0-9]+ *\|/ { split($0, c, "|"); gsub(/ /, "", c[3]); if (c[3] != "") n++ } END{print n+0}' docs/DECISIONS.md 2>/dev/null)"
if [ "${ai:-0}" -ge 2 ]; then ok "AI 제안 수정 ${ai}건"; else note "AI 제안 수정 ${ai:-0}건 (2건 이상 권장)"; fi

pending="$(grep -cE '^\|.*\| *(미확인|실패) *\|' docs/VERIFY.md 2>/dev/null || true)"
[ "${pending:-0}" -gt 0 ] && note "VERIFY.md에 미확인·실패 표시 ${pending}곳 (남은 한계에 이유가 있는지 확인)" || ok "VERIFY.md 미확인·실패 없음"

if [ -x scripts/smoke.sh ]; then
  mkdir -p .harness
  if SHOT=0 scripts/smoke.sh >.harness/smoke.out 2>&1; then ok "smoke: $(tail -1 .harness/smoke.out)"; else bad "smoke: $(grep -E '^실패|결과' .harness/smoke.out | tr '\n' ' ')"; fi
fi

echo "결과: 실패 $fail, 주의 $warn"
[ "$fail" -eq 0 ]
