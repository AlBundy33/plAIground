from flask import Flask, render_template
import os
import yaml

app = Flask(__name__)

@app.route("/")
def index():
    server_name = os.environ.get("SERVER_NAME", "localhost")

    try:
        with open("docker-compose.yml", "r") as f:
            data = yaml.safe_load(f)
    except Exception as e:
        return f"<h1>Fehler beim Lesen der Compose-Datei</h1><pre>{e}</pre>"

    services = data.get("services", {})
    return render_template("index.html", services=services, server_name=server_name)

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8500)
