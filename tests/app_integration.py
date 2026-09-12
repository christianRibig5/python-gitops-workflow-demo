import pytest

from app import app as flask_app


@pytest.fixture
def client():
    flask_app.config.update(TESTING=True)
    return flask_app.test_client()


def test_home_returns_html(client):
    response = client.get("/")

    assert response.status_code == 200
    assert response.mimetype == "text/html"
    assert "Hello from Python GitOps!" in response.get_data(as_text=True)


def test_health_returns_healthy_json(client):
    response = client.get("/health")

    assert response.status_code == 200
    assert response.is_json

    body = response.get_json()
    assert body["status"].startswith("healthy")


def test_unknown_route_returns_404(client):
    response = client.get("/route-that-does-not-exist")

    assert response.status_code == 404
