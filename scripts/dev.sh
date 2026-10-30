#!/usr/bin/env bash
# 개발 서버를 백그라운드에서 다룬다. 로그와 pid는 .harness/에 남는다.
# 사용: scripts/dev.sh start|stop|restart|status|log
#   DEV_CMD     실행 명령 (기본 npm run dev)
#   HEALTH_URL  준비 확인 주소 (기본 http://127.0.0.1:${API_PORT:-3000}/api/health)
set -uo pipefail

DEV_CMD="${DEV_CMD:-npm run dev}"
HEALTH_URL="${HEALTH_URL:-http://127.0.0.1:${API_PORT:-3000}/api/health}"
STATE=.harness
PIDFILE="$STATE/dev.pid"
LOG="$STATE/dev.log"
mkdir -p "$STATE"

running() { [ -f "$PIDFILE" ] && kill -0 -- "-$(cat "$PIDFILE")" 2>/dev/null; }
health() { curl -sf --max-time 2 "$HEALTH_URL" 2>/dev/null; }
health_pid() { health | sed -n 's/.*"pid":\([0-9]*\).*/\1/p'; }

start() {
  if running; then echo "이미 실행 중 (그룹 $(cat "$PIDFILE"))"; return 0; fi
  # set -m: 서버가 자기 프로세스 그룹을 가져서 자식(vite, node)까지 한 번에 끌 수 있다
  set -m
  nohup bash -c "$DEV_CMD" >"$LOG" 2>&1 &
  echo $! >"$PIDFILE"
  set +m
  echo "기동: $DEV_CMD (그룹 $(cat "$PIDFILE"), 로그 $LOG)"
  for _ in $(seq 1 60); do
    if health >/dev/null; then echo "준비됨: $(health)"; return 0; fi
    running || { echo "프로세스가 바로 끝났다. 로그:"; tail -20 "$LOG"; return 1; }
    sleep 0.5
  done
  echo "30초 안에 $HEALTH_URL 응답 없음 (health가 없는 프로젝트면 정상일 수 있다). 로그:"; tail -10 "$LOG"
  return 1
}

stop() {
  if ! running; then echo "실행 중 아님"; rm -f "$PIDFILE"; return 0; fi
  local pg; pg="$(cat "$PIDFILE")"
  kill -TERM -- "-$pg" 2>/dev/null
  # 그룹이 완전히 사라질 때까지 기다린다. 꺼지는 중인 프로세스가 포트를 쥐고 대신 응답할 수 있다
  for _ in $(seq 1 30); do kill -0 -- "-$pg" 2>/dev/null || break; sleep 0.5; done
  if kill -0 -- "-$pg" 2>/dev/null; then kill -KILL -- "-$pg" 2>/dev/null; sleep 0.5; fi
  rm -f "$PIDFILE"
  echo "종료됨 (그룹 $pg)"
}

case "${1:-status}" in
  start) start ;;
  stop) stop ;;
  restart)
    old="$(health_pid)"
    stop
    for _ in $(seq 1 20); do health >/dev/null || break; sleep 0.5; done
    if health >/dev/null; then echo "경고: 종료 뒤에도 누군가 $HEALTH_URL에 응답한다 (pid $(health_pid)). 다른 프로세스가 포트를 쓰는지 확인"; exit 1; fi
    start || exit 1
    new="$(health_pid)"
    if [ -n "$old" ] && [ "$old" = "$new" ]; then echo "경고: pid가 그대로다 ($new). 이전 서버가 응답하고 있다"; exit 1; fi
    echo "pid ${old:-없음} → ${new:-확인 불가}"
    ;;
  status)
    if running; then echo "실행 중 (그룹 $(cat "$PIDFILE"))"; else echo "실행 중 아님"; fi
    health && echo || echo "$HEALTH_URL 응답 없음"
    ;;
  log) tail -n "${2:-40}" "$LOG" ;;
  *) echo "사용: scripts/dev.sh start|stop|restart|status|log [줄 수]"; exit 2 ;;
esac
