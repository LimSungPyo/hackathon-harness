"""예시 테스트. 기능마다 이 모양으로 정상 1개 + 실패·경계 1개 이상을 쓴다."""


def test_health_ok(client):
    res = client.get("/api/health")

    assert res.status_code == 200
    assert res.json()["status"] == "ok"


def test_unknown_path_404(client):
    res = client.get("/api/__not_found__")

    assert res.status_code == 404
