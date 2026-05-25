from flask import Flask, render_template
import os
import yaml
import socket

app = Flask(__name__)

def check_service_status(hostname, port, timeout=2):
    """Check if a service is reachable via TCP."""
    try:
        with socket.create_connection((hostname, port), timeout=timeout):
            return True
    except (socket.timeout, socket.error, OSError):
        return False

def parse_host_port(port_mapping):
    """Extract internal port from port mapping like '5678:5678'."""
    # Handle formats like '5678:5678', '5678:5678/tcp', etc.
    return int(str(port_mapping).split(':')[1].split('/')[0])

@app.route("/")
def index():
    server_name = os.environ.get("SERVER_NAME", "localhost")

    try:
        with open("docker-compose.yml", "r") as f:
            data = yaml.safe_load(f)
    except Exception as e:
        return f"<h1>Error reading compose file</h1><pre>{e}</pre>"

    services = data.get("services", {})
    
    # Check status for each service
    for name, svc in services.items():
        ports = svc.get("ports", [])
        if ports:
            internal_port = parse_host_port(ports[0])
            # Try to reach the service via its container name in the Docker network
            svc["status"] = check_service_status(name, internal_port)
        else:
            svc["status"] = None  # No port to check

    return render_template("index.html", services=services, server_name=server_name)

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8500)
