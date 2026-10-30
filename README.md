# hackathon-harness

AI 코딩 에이전트(Codex)와 함께 짧은 시간 안에 과제를 진행하기 위한 작업 방식 모음이다.
과제 기능은 들어 있지 않다. 규칙, 기록 양식, 검증 스크립트, 빈 스캐폴드만 있다.

## 구성

| 경로 | 내용 |
|------|------|
| `AGENTS.md` | Codex가 매 요청마다 읽는 작업 규칙: 묻고 나서 구현, 한 기능씩, 실행 결과로 검증, 기록 |
| `docs/PLAN.md` | 요구사항(원문), 범위(MVP / 나중 / 안 함), 실행 포트 |
| `docs/DECISIONS.md` | 결정과 대안, 이유. AI 제안을 바꾼 내역 |
| `docs/VERIFY.md` | 기능별 핵심 동작과 확인 방법, 결과 |
| `docs/TROUBLESHOOT.md` | 증상 / 원인 / 해결 / 확인 |
| `template/` | Vite + Vue + Express 빈 스캐폴드. `npm run dev` 하나로 둘 다 뜨고 둘 다 `0.0.0.0`에 바인딩 |
| `scripts/smoke.sh` | curl로 API 상태 코드 확인, Playwright로 데스크톱·375px 스크린샷 |
| `scripts/install.sh` | 하네스를 과제 폴더에 복사. 이미 있는 파일은 덮어쓰지 않음 |
| `codex/config.example.toml` | Playwright MCP, Context7 MCP 설정 (키 없이) |
| `PLAYBOOK.md` | 시간대별 진행 순서와 Codex에게 보낼 말 |

## 왜 이렇게 나눴나

- **규칙은 짧게, 기록은 파일로.** 에이전트는 AGENTS.md를 매번 읽으므로 규칙만 둔다. 진행 상황은 docs/에 쌓여서 대화가 길어져도 사라지지 않는다.
- **구현 전에 한 번에 묻는다.** 갈림길마다 멈추면 시간이 샌다. 열린 선택을 처음에 모아 정하고, 되돌리기 쉬운 것만 에이전트가 정해 기록한다.
- **"됐다"는 실행 결과로만.** API는 curl, 화면은 스크린샷. 실패는 실패로 남긴다.
- **health가 pid를 돌려준다.** 서버 재시작 직후 꺼지는 중인 이전 프로세스가 응답하는 경우를 구분하려고.
- **스크립트는 덮어쓰지 않는다.** install.sh는 기존 파일을 건너뛴다. 커밋 전에는 `git diff --stat`으로 파일이 통째로 비지 않았는지 본다.

## 쓰는 법

```bash
scripts/install.sh <과제 폴더>                  # 스타터 코드가 있을 때
scripts/install.sh <과제 폴더> --with-template  # 빈 폴더에서 시작할 때
cd <과제 폴더> && npm install && npm run dev
scripts/smoke.sh
```

포트는 `API_PORT`(기본 3000), `WEB_PORT`(기본 5173) 환경변수로 바꾼다. 웹은 `/api`를 API 서버로 넘긴다.
