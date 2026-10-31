# hackathon-harness

AI 코딩 에이전트(Codex)와 짧은 과제를 진행하기 위한 출발점. 과제 기능은 들어 있지 않고, 모노레포 빈 스캐폴드와 작업 규칙, 기록 양식, master 스킬만 있다.

## 구성

| 경로 | 내용 |
|------|------|
| `backend/` | FastAPI. `/api/health`만 있음. pytest 예시 `tests/test_health.py` |
| `frontend/` | React + Vite + TypeScript. `/api`를 백엔드로 프록시 |
| `docker-compose.yml` | 프론트·백엔드. PostgreSQL 16은 `--profile db`일 때만 |
| `AGENTS.md` | Codex 작업 규칙: 묻고 나서 구현, 백엔드는 기능마다 pytest, 한 기능씩 확인하고 커밋 |
| `docs/` | PLAN(요구사항·MVP), DECISIONS(결정·AI 제안 수정), VERIFY(확인 결과) |
| `.agents/skills/master/` | master 스킬: 계획은 6.1 Sol medium, 구현 slave는 6 Luna medium (Orca) |
| `scripts/smoke.sh` | curl로 API 상태 코드 확인 |

## 쓰는 법

빈 폴더에서 시작할 때:

```bash
git clone https://github.com/LimSungPyo/hackathon-harness app && cd app && rm -rf .git && git init
docker compose up --build
```

스타터 코드가 있을 때는 규칙과 문서만 가져온다:

```bash
git clone https://github.com/LimSungPyo/hackathon-harness ~/harness && cp -Rn ~/harness/AGENTS.md ~/harness/docs ~/harness/.agents .
```

master 세션은 6.1 Sol medium으로 띄운 Codex에서 시작한다:

```bash
codex -m gpt-6.1-sol -c model_reasoning_effort=medium
```

그다음 `$master <과제 요약>`(또는 "master로 진행해줘"). 작은 과제면 master 없이 바로 진행해도 된다.

## 확인

- 프론트: `http://<호스트>:5173`에 "API 연결됨"이 보이면 연결 끝
- 백엔드 테스트: `cd backend && .venv/bin/pip install -r requirements-dev.txt && .venv/bin/pytest -q`
- 띄운 백엔드 확인: `scripts/smoke.sh`
