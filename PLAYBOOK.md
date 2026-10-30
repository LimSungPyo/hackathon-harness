# PLAYBOOK

당일에 내가 보는 문서. Codex에게 보낼 말을 미리 적어 둔다.

## 0~15분: 읽고, 묻고, 계획

```bash
git clone https://github.com/LimSungPyo/hackathon-harness ~/harness
~/harness/scripts/install.sh <과제 폴더>                   # 스타터 코드가 있을 때
~/harness/scripts/install.sh <과제 폴더> --with-template   # 빈 폴더에서 시작할 때
```

Codex에게:

> 과제 안내와 스타터 코드를 끝까지 읽고 AGENTS.md 0단계대로 PLAN.md를 채워줘. 구현은 하지 말고, 애매한 점과 열린 선택을 한 번에 물어봐.

- 실무자 에이전트에게 물을 질문은 PLAN.md "실무자에게 물을 것"에 먼저 적고, 답을 받으면 그 표에 붙인다.
- 답을 Codex에게 전달할 때 결정을 DECISIONS.md에 적게 한다.

## 15~30분: 띄우고 연결 확인

```bash
npm install          # npm ci가 아니라 install. 환경의 npm 버전이 달라도 넘어간다
npm run dev          # 별도 터미널. 끄지 않는다
scripts/smoke.sh
```

브라우저 도구로 `http://<호스트>:5173`에서 "API 연결됨"이 보이는지 확인.

## 30~130분: 기능 루프

기능마다:

> PLAN.md의 <기능>을 해줘. 끝나면 curl/화면으로 확인한 결과를 보여주고 VERIFY.md에 적은 뒤 커밋해줘.

- 제안이 이상하면 바로 받지 말고 근거를 물은 뒤 바꾼다. 바꾸면: "방금 바꾼 거 DECISIONS.md AI 제안 수정에 적어줘."
- 40분 넘게 한 기능에 묶이면 범위를 줄인다. MVP가 끝까지 도는 게 먼저.

## 130~155분: 검증

> VERIFY.md의 경계·실패 경로를 채워줘. 확인 못 한 건 미확인으로 두고 이유를 남은 한계에 적어줘.

## 155~170분: 마감

> 마감. README에 실행법(새로 clone한 상태 기준), 결정 요약, 남은 한계를 정리해줘.

제출 전 VERIFY.md 맨 아래 체크리스트.

## 170분~: 서술형 전에

- "핵심 동작과 확인 방법" → VERIFY.md 표
- "AI 제안을 확인하거나 수정한 부분" → DECISIONS.md "AI 제안 수정", TROUBLESHOOT.md
- `git log --oneline`을 한 번 훑어 커밋 순서대로 이야기를 기억해 둔다.

## 원칙

- MCP 설정에 10분 넘게 걸리면 버린다.
- Codex가 "됐다"고 하면 결과(명령 출력, 스크린샷)를 본 뒤에 믿는다.
- 서버가 이상하면 먼저 `curl -s localhost:3000/api/health`의 pid가 지금 터미널에 찍힌 pid와 같은지 본다.
