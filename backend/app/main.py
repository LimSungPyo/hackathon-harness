"""FastAPI 앱 진입점."""

import os
from datetime import datetime, timezone

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.core.config import get_settings

app = FastAPI(title="app API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=get_settings().cors_origin_list,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

STARTED_AT = datetime.now(timezone.utc).isoformat()


@app.get("/api/health")
def health():
    # pid로 재시작 뒤 응답한 게 새 프로세스인지 구분한다
    return {"status": "ok", "pid": os.getpid(), "started_at": STARTED_AT}
