import os

import pytest

from app import app as flask_app


@pytest.fixture()
def client():
    flask_app.config.update(TESTING=True)

    with flask_app.test_client() as test_client:
        yield test_client


def test_home_returns_new_landing_page(client):
    response = client.get("/")
    html = response.get_data(as_text=True)

    assert response.status_code == 200
    assert response.mimetype == "text/html"

    # Verify the main landing-page content
    assert "VGC Cloud Platform" in html
    assert "Infrastructure that ships with" in html
    assert "GitHub Actions" in html
    assert "Argo CD" in html
    assert "Amazon EKS" in html
    assert "Prometheus" in html
    assert "Grafana" in html

    # Verify the health-check interface
    assert "Run health check" in html
    assert "fetch('/health'" in html


def test_home_displays_environment_information(client):
    response = client.get("/")
    html = response.get_data(as_text=True)

    expected_environment = os.getenv("APP_ENV", "development")
    expected_region = os.getenv("AWS_REGION", "ca-central-1")
    expected_version = os.getenv("APP_VERSION", "v1.0.0")

    assert response.status_code == 200
    assert expected_environment.capitalize() in html
    assert expected_region in html
    assert expected_version in html


def test_health_returns_healthy_json(client):
    response = client.get("/health")
    body = response.get_json()

    assert response.status_code == 200
    assert response.is_json
    assert body is not None

    assert body["status"] == "healthy"
    assert body["service"] == "vgc-platform-demo"
    assert body["version"] == os.getenv("APP_VERSION", "v1.0.0")
    assert body["environment"] == os.getenv("APP_ENV", "development")


def test_health_response_contains_required_fields(client):
    response = client.get("/health")
    body = response.get_json()

    assert response.status_code == 200
    assert body is not None

    required_fields = {
        "status",
        "service",
        "version",
        "environment",
    }

    assert required_fields.issubset(body.keys())


def test_unknown_route_returns_404(client):
    response = client.get("/route-that-does-not-exist")

    assert response.status_code == 404
