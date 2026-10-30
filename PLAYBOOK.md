# PLAYBOOK

당일에 내가 보는 문서. 할 일은 명령 한 줄과 Codex에게 보내는 단어 몇 개뿐이다.

## 시작 (0분)

과제 폴더에서:

```bash
git clone https://github.com/LimSungPyo/hackathon-harness ~/harness && ~/harness/start.sh
```

`start.sh`가 하는 일:

1. node, npm, git, codex 확인
2. 빈 폴더면 스캐폴드까지, 스타터 코드가 있으면 규칙·문서·스크립트만 설치 (기존 파일은 덮어쓰지 않음)
3. git 준비, 커밋 형식 훅 설치, 시작 시각 기록
4. `npm install`
5. (빈 폴더일 때) 서버를 백그라운드로 띄우고 health·smoke 확인
6. 하네스 파일 커밋
7. Codex를 띄우고 `시작`을 보냄

## 그다음 내가 할 일

| 언제 | 나 | Codex에게 |
|------|----|-----------|
| 0~15분 | 과제 안내를 직접 읽는다. Codex가 PLAN.md "실무자에게 물을 것"에 적은 질문을 실무자 에이전트에게 묻는다 | (Codex는 `시작` 진행 중) |
| ~15분 | Codex 질문에 답하고 실무자 답변을 붙인다 | `1번 A, 2번 B. 실무자: ○○. 확정` |
| 15~130분 | 결과를 보고 이상하면 바꾼다 | `다음` 반복. 제안을 바꿨으면 `수정기록` |
| 130분 | | `검증` |
| 155분 | | `마감` |
| 170분 | `scripts/check-submit.sh` 결과 확인 후 제출 | |

Codex가 `다음` 끝에 경과 시간을 붙여 보고하고, 130분이 넘으면 새 기능 대신 먼저 알린다.

## 도구

```bash
scripts/elapsed.sh          # 경과·남은 시간과 지금 단계
scripts/dev.sh status       # 서버 상태와 health
scripts/dev.sh log          # 서버 로그 마지막 40줄
scripts/dev.sh restart      # 이전 프로세스가 완전히 사라진 뒤 재시작, pid 바뀜 확인
scripts/smoke.sh            # API 상태 코드 확인 (+ Playwright 있으면 스크린샷)
scripts/check-submit.sh     # 제출 전 점검
```

스타터 코드가 있으면 서버는 Codex가 실행 방법을 정리한 뒤:

```bash
DEV_CMD='npm run dev' HEALTH_URL=http://127.0.0.1:8080/health scripts/dev.sh start
```

## 서술형 전에

- "핵심 동작과 확인 방법" → VERIFY.md 표
- "AI 제안을 확인하거나 수정한 부분" → DECISIONS.md "AI 제안 수정", TROUBLESHOOT.md
- `git log --oneline`을 훑어 커밋 순서대로 이야기를 기억해 둔다

## 원칙

- MCP 설정에 10분 넘게 걸리면 버린다.
- Codex가 "됐다"고 하면 결과(명령 출력, 스크린샷)를 본 뒤에 믿는다.
- 한 기능에 40분 넘게 묶이면 범위를 줄인다. MVP가 끝까지 도는 게 먼저다.
