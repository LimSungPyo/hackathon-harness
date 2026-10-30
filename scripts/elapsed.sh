#!/usr/bin/env bash
# start.sh가 기록한 시작 시각 기준으로 경과·남은 시간과 지금 단계를 알려 준다.
set -uo pipefail

TOTAL="${TOTAL_MIN:-180}"
f=.harness/started_at
[ -f "$f" ] || { echo "시작 시각 기록 없음 (.harness/started_at). start.sh로 시작했는지 확인"; exit 1; }
min=$(( ($(date +%s) - $(cat "$f")) / 60 ))
left=$(( TOTAL - min ))

if   [ "$min" -lt 15 ];  then phase="계획 단계 (읽기, 질문, PLAN.md)"
elif [ "$min" -lt 30 ];  then phase="연결 확인 단계"
elif [ "$min" -lt 130 ]; then phase="기능 단계 (MVP부터)"
elif [ "$min" -lt 155 ]; then phase="검증 단계: 새 기능 시작 금지"
elif [ "$min" -lt 170 ]; then phase="마감 단계: 문서 정리만"
else                          phase="제출 단계: 지금 제출"
fi

echo "경과 ${min}분 / 남은 ${left}분 — $phase"
