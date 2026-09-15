import os

from flask import Flask, jsonify, render_template


app = Flask(__name__)


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


if __name__ == "__main__":
    app.run(
        host="0.0.0.0",
        port=int(os.getenv("PORT", "5000")),
        debug=os.getenv("FLASK_DEBUG", "false").lower() == "true",
    )
