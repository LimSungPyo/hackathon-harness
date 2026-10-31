# 작업 규칙

## 구조

```
backend/    FastAPI (Python 3.12). 진입점 app/main.py, 설정 app/core/config.py, 테스트 tests/
frontend/   React + Vite + TypeScript. /api 요청은 백엔드로 프록시
docs/       PLAN.md(요구사항·범위), DECISIONS.md(결정·AI 제안 수정), VERIFY.md(확인 결과)
.agents/skills/master/   큰 작업을 slave로 나눠 진행하는 스킬
```

- 환경 변수는 루트 `.env` 하나(`.env.example` 참고). 기본값이 있어 없어도 뜬다.
- DB(PostgreSQL 16)는 필요할 때만 `docker compose --profile db up`. 쓰면 DECISIONS.md에 이유를 적는다.

## 실행

```bash
docker compose up --build          # 프론트 5173, 백엔드 8000
```

Docker 없이:

```bash
cd backend && python3 -m venv .venv && .venv/bin/pip install -r requirements.txt && .venv/bin/uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
cd frontend && npm install && npm run dev
```

백엔드 테스트 (서버를 띄우지 않아도 된다):

```bash
cd backend && .venv/bin/pip install -r requirements-dev.txt && .venv/bin/pytest -q
```

## 진행 방식

1. 구현 전에 과제 안내와 코드를 읽고 `docs/PLAN.md`에 요구사항(원문)과 MVP를 적는다. 애매한 점과 열린 선택은 한 번에 모아 묻고, 답을 받은 뒤 시작한다.
2. MVP부터 한 기능씩: 구현 → 백엔드 테스트 작성 → `pytest` 통과 → 실행해서 확인 → `docs/VERIFY.md` 한 줄 → 커밋. 끝나면 바로 다음으로 간다.
3. 되돌리기 어려운 선택(데이터 구조, API 모양, 패키지 추가, 범위 변경)은 묻고, 결정은 `docs/DECISIONS.md`에 적는다.
4. 내가 네 제안을 바꾸거나 거절하면 DECISIONS.md "AI 제안 수정"에 원래 제안 / 바꾼 것 / 이유를 적는다.
5. 응답은 짧게: 바꾼 파일과 이유, 확인 결과.

## 검증

- **백엔드는 테스트가 의무다.** API를 만들거나 바꾸면 `backend/tests/`에 pytest를 함께 쓴다(`tests/test_health.py` 모양, `client` fixture 사용).
  - 엔드포인트마다 정상 1개 + 실패·경계 1개 이상(빈 값, 없는 id, 중복, 권한).
  - 버그를 고치면 그 버그를 재현하는 테스트를 먼저 추가한다.
  - 테스트용 가짜(mock)는 진짜와 같은 시점에 같은 값을 돌려줘야 한다.
- 프론트는 테스트 코드 대신 브라우저로 화면을 확인한다.
- "동작한다"는 실행 결과로만 말한다. API는 curl(상태 코드 + 본문), 화면은 브라우저로 확인한다.
- 정상 경로 하나와 실패·경계 경로 하나 이상을 확인한다.
- 새 API를 만들면 `scripts/smoke.sh` 확인 목록에 한 줄 추가한다.
- 실패를 숨기거나 테스트를 지우지 않는다. 확실하지 않으면 그렇다고 말한다.

## 커밋

- 기능 하나 = 커밋 하나. 커밋 전에 `pytest -q`가 전부 통과하는지, `git diff --stat`으로 의도하지 않은 삭제가 없는지 본다.
- 형식 (한국어, 제목과 본문 사이 빈 줄, 본문 최대 3줄):

  ```
  <type>: [<범위>] <제목>

  - [추가|변경|수정|삭제|참고] [<파일명>|공통] <내용>
  ```

  type: feat, fix, refactor, test, docs, style, build, chore
- push, amend, reset --hard, force는 내가 말할 때만 한다.

## 금지

- 과제 범위 밖 기능, 요청하지 않은 리팩터링
- 비밀 키 하드코딩, 오류 로그에 요청 헤더·키 남기기
- 서버를 0.0.0.0이 아닌 주소에 바인딩
