#!/usr/bin/env bash
# 과제 시작 한 줄. 하네스 설치 → git·훅 준비 → 의존성 설치 → (스캐폴드면) 서버 기동과 확인 → 커밋 → Codex에 "시작".
# 사용: ~/harness/start.sh [과제 폴더, 기본 현재 폴더]
#   NO_CODEX=1   마지막에 Codex를 띄우지 않는다
#   TOTAL_MIN=180  제한 시간(분). scripts/elapsed.sh가 쓴다
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
TARGET="${1:-.}"
mkdir -p "$TARGET"
TARGET="$(cd "$TARGET" && pwd)"

say() { printf '\n== %s\n' "$1"; }

say "환경 확인"
for cmd in git node npm; do
  command -v "$cmd" >/dev/null || { echo "$cmd 없음. 설치 후 다시 실행"; exit 1; }
done
node_major="$(node -p 'process.versions.node.split(".")[0]')"
echo "node $(node -v), npm $(npm -v), git $(git --version | awk '{print $3}')"
[ "$node_major" -ge 20 ] || echo "주의: node 20 이상이 아니다. 스캐폴드의 --env-file-if-exists가 동작하지 않을 수 있다"
command -v codex >/dev/null && echo "codex 있음" || echo "주의: codex 없음. 끝난 뒤 직접 실행"

cd "$TARGET"

# .git, .DS_Store 말고 아무것도 없으면 빈 폴더로 본다
if [ -z "$(find . -mindepth 1 -maxdepth 1 ! -name .git ! -name .DS_Store ! -name .harness | head -1)" ]; then
  mode=template
else
  mode=starter
fi
say "모드: $mode ($([ "$mode" = template ] && echo '빈 폴더 → 스캐폴드 사용' || echo '스타터 코드 있음 → 스캐폴드 안 씀'))"

if [ ! -d .git ]; then
  git init -q
  git symbolic-ref HEAD refs/heads/main
  echo "git init (main)"
fi

say "하네스 설치"
if [ "$mode" = template ]; then
  "$HERE/scripts/install.sh" "$TARGET" --with-template | grep -v '^끝' | sed "s|$TARGET/||"
else
  "$HERE/scripts/install.sh" "$TARGET" | grep -v '^끝' | sed "s|$TARGET/||"
fi

# 작업 시각과 서버 로그는 커밋하지 않는다. 과제의 .gitignore는 건드리지 않고 로컬 제외 목록에만 넣는다
mkdir -p .harness
grep -qxF '.harness/' .git/info/exclude 2>/dev/null || echo '.harness/' >> .git/info/exclude
grep -qxF '.smoke/' .git/info/exclude 2>/dev/null || echo '.smoke/' >> .git/info/exclude
[ -f .harness/started_at ] || date +%s > .harness/started_at
echo "시작 시각 기록: $(date '+%H:%M')"

if [ -n "$(git config core.hooksPath || true)" ]; then
  echo "주의: core.hooksPath가 설정돼 있어(husky 등) commit-msg 훅을 설치하지 않았다"
elif [ -e .git/hooks/commit-msg ]; then
  echo "commit-msg 훅이 이미 있어 그대로 둔다"
else
  cp scripts/hooks/commit-msg .git/hooks/commit-msg
  chmod +x .git/hooks/commit-msg
  echo "commit-msg 훅 설치 (커밋 형식 검사)"
fi

if [ -f package.json ] && [ ! -d node_modules ]; then
  say "npm install"
  npm install --no-audit --no-fund 2>&1 | tail -2
fi

if [ "$mode" = template ]; then
  say "서버 기동과 확인"
  scripts/dev.sh start
  SHOT=0 scripts/smoke.sh || echo "주의: smoke 실패. scripts/dev.sh log 확인"
else
  say "서버"
  echo "스타터 실행 방법은 Codex가 PLAN.md에 정리한다. 정해지면:"
  echo "  DEV_CMD='npm run dev' HEALTH_URL=http://127.0.0.1:<포트>/<경로> scripts/dev.sh start"
fi

say "커밋"
if [ "$mode" = template ]; then
  git add -A
else
  git add AGENTS.md docs scripts
fi
if git diff --cached --quiet; then
  echo "새로 커밋할 하네스 파일 없음"
else
  git commit -q -F - <<'MSG'
chore: [하네스] 작업 규칙, 문서 템플릿, 검증 스크립트 추가

- [추가] [AGENTS.md] Codex 작업 규칙과 단계별 명령어
- [추가] [docs, scripts] 계획·결정·검증 기록 양식, 서버·검증·제출 점검 스크립트
MSG
  git log --oneline -1
fi

say "다음"
cat <<'TXT'
1. Codex가 과제를 읽고 PLAN.md와 질문을 올린다 (명령: 시작)
2. 그동안 과제 안내를 직접 읽는다. Codex가 PLAN.md "실무자에게 물을 것"에 적은 질문을 실무자 에이전트에게 묻는다
3. Codex 질문과 실무자 답변을 한 번에 보낸다 → "확정"
4. 이후 "다음"을 반복. 130분부터 "검증", 155분부터 "마감"
   남은 시간: scripts/elapsed.sh   서버: scripts/dev.sh status|log|restart
TXT

if [ "${NO_CODEX:-0}" != 1 ] && command -v codex >/dev/null && [ -t 0 ]; then
  exec codex "시작"
fi
