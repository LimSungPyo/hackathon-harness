import pytest
from fastapi.testclient import TestClient

from app.main import app


@pytest.fixture
def client():
    # 서버를 띄우지 않고 앱을 직접 호출한다
    with TestClient(app) as c:
        yield c
