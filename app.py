import os
from time import perf_counter

from flask import Flask, Response, g, jsonify, render_template, request
from prometheus_client import (
    CONTENT_TYPE_LATEST,
    Counter,
    Gauge,
    Histogram,
    generate_latest,
)

app = Flask(__name__)


HTTP_REQUESTS_TOTAL = Counter(
    "http_requests_total",
    "Total HTTP requests processed by the application.",
    ("method", "route", "status"),
)

HTTP_REQUEST_DURATION_SECONDS = Histogram(
    "http_request_duration_seconds",
    "HTTP request duration in seconds.",
    ("method", "route"),
    buckets=(0.005, 0.01, 0.025, 0.05, 0.1, 0.25, 0.5, 1, 2.5, 5),
)

HTTP_REQUESTS_IN_PROGRESS = Gauge(
    "http_requests_in_progress",
    "HTTP requests currently being processed.",
    ("method",),
)


@app.before_request
def start_request_metrics():
    """Start timing application requests while excluding Prometheus scrapes."""
    if request.path == "/metrics":
        return

    g.metrics_started_at = perf_counter()
    g.metrics_method = request.method
    HTTP_REQUESTS_IN_PROGRESS.labels(method=request.method).inc()
    return


@app.after_request
def record_request_metrics(response):
    """Record request rate, status code, and duration with bounded labels."""
    started_at = getattr(g, "metrics_started_at", None)
    if started_at is None:
        return response

    method = getattr(g, "metrics_method", request.method)
    route = request.url_rule.rule if request.url_rule else "unmatched"
    duration = perf_counter() - started_at

    HTTP_REQUESTS_TOTAL.labels(
        method=method,
        route=route,
        status=str(response.status_code),
    ).inc()
    HTTP_REQUEST_DURATION_SECONDS.labels(
        method=method, route=route).observe(duration)
    HTTP_REQUESTS_IN_PROGRESS.labels(method=method).dec()
    return response


@app.get("/")
def home():
    return render_template(
        "index.html",
        app_version=os.getenv("APP_VERSION", "v1.0.0"),
        environment=os.getenv("APP_ENV", "development"),
        aws_region=os.getenv("AWS_REGION", "ca-central-1"),
    )


@app.get("/health")
def health():
    return jsonify(
        status="healthy",
        service="vgc-platform-demo",
        version=os.getenv("APP_VERSION", "v1.0.0"),
        environment=os.getenv("APP_ENV", "development"),
    )


@app.get("/metrics")
def metrics():
    """Expose application and default Python process metrics to Prometheus."""
    return Response(generate_latest(), content_type=CONTENT_TYPE_LATEST)


if __name__ == "__main__":
    app.run(
        host="0.0.0.0",
        port=int(os.getenv("PORT", "5000")),
        debug=os.getenv("FLASK_DEBUG", "false").lower() == "true",
    )
