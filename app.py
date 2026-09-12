from flask import Flask

app = Flask(__name__)


@app.route("/")
def home():
    return """
        <!DOCTYPE html>
        <html>
            <head>
                <title>GitOps Demo</title>
            </head>
            <body>
                <h1>Hello from Python GitOps! 🚀</h1>
                <p>Deployed using Git Action, Argo CD, and Kubernetes.</p>
            </body>
        </html>
    """


@app.route("/health")
def health():
    return {
        "status": "healthy🧑‍⚕️"
    }


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
