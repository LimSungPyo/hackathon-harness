# hackathon-harness

AI 코딩 에이전트(Codex)와 함께 짧은 시간 안에 과제를 진행하기 위한 작업 방식 모음이다.
과제 기능은 들어 있지 않다. 규칙, 기록 양식, 검증·운영 스크립트, 빈 스캐폴드만 있다.

## 쓰는 법

과제 폴더에서:

```bash
git clone https://github.com/LimSungPyo/hackathon-harness ~/harness && ~/harness/start.sh
```

이후 Codex에게 단어 하나씩 보낸다: `시작` → `확정` → `다음` 반복 → `검증` → `마감`. 자세한 순서는 [PLAYBOOK.md](PLAYBOOK.md).

## 구성

| 경로 | 내용 |
|------|------|
| `start.sh` | 시작 한 줄: 설치, git·훅 준비, 의존성 설치, 서버 기동·확인, 커밋, Codex 실행 |
| `AGENTS.md` | Codex가 매 요청마다 읽는 작업 규칙과 단계별 명령어 |
| `docs/PLAN.md` | 요구사항(원문), 범위(MVP / 나중 / 안 함), 실무자 질문, 진행 표 |
| `docs/DECISIONS.md` | 결정과 대안, 이유, 누가 정했나. AI 제안을 바꾼 내역 |
| `docs/VERIFY.md` | 기능별 핵심 동작과 확인 방법, 결과 |
| `docs/TROUBLESHOOT.md` | 증상 / 원인 / 해결 / 확인 |
| `scripts/dev.sh` | 서버 start / stop / restart / status / log. 재시작 시 이전 프로세스 종료와 pid 변경까지 확인 |
| `scripts/smoke.sh` | curl로 API 상태 코드 확인, Playwright로 데스크톱·375px 스크린샷 |
| `scripts/elapsed.sh` | 경과·남은 시간과 지금 단계 |
| `scripts/check-submit.sh` | 제출 전 점검: .env·빈 파일·비밀 키·커밋 형식·README·AI 제안 수정 건수·smoke |
| `scripts/hooks/commit-msg` | 커밋 메시지 형식 검사 (`<type>: [범위] 제목`, 빈 줄, 본문 3줄) |
| `scripts/install.sh` | 하네스를 과제 폴더에 복사. 이미 있는 파일은 덮어쓰지 않음 |
| `template/` | Vite + Vue + Express 빈 스캐폴드. `npm run dev` 하나로 둘 다 뜨고 둘 다 `0.0.0.0`에 바인딩 |
| `codex/config.example.toml` | Playwright MCP, Context7 MCP 설정 (키 없이) |

## 왜 이렇게 나눴나

- **규칙은 짧게, 기록은 파일로.** 에이전트는 AGENTS.md를 매번 읽으므로 규칙만 둔다. 진행 상황은 docs/에 쌓여서 대화가 길어져도 사라지지 않는다.
- **구현 전에 한 번에 묻는다.** 갈림길마다 멈추면 시간이 샌다. 열린 선택을 처음에 모아 정하고, 되돌리기 쉬운 것만 에이전트가 정해 기록한다.
- **사람이 할 일은 판단만.** 반복 절차는 스크립트와 명령어로 고정하고, 사람은 요구사항 질문과 선택, 결과 확인에 시간을 쓴다.
- **"됐다"는 실행 결과로만.** API는 curl, 화면은 스크린샷. 실패는 실패로 남긴다.
- **health가 pid를 돌려준다.** 서버 재시작 직후 꺼지는 중인 이전 프로세스가 응답하는 경우를 구분하려고.
- **덮어쓰지 않는다.** install.sh는 기존 파일을 건너뛰고, 과제의 .gitignore 대신 `.git/info/exclude`를 쓴다.

포트는 `API_PORT`(기본 3000), `WEB_PORT`(기본 5173) 환경변수로 바꾼다. 웹은 `/api`를 API 서버로 넘긴다.
