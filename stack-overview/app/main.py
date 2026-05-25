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
    return int(str(port_mapping).split(':')[1].split('/')[0])

def parse_ui_config(svc):
    """Parse x-plaiground-ui configuration."""
    ui_config = svc.get("x-plaiground-ui")
    ports = svc.get("ports", [])

    # No UI configured
    if ui_config == []:
        return []

    # Default behavior: first port + "/"
    if ui_config is None:
        if ports:
            internal_port = parse_host_port(ports[0])
            external_port = int(str(ports[0]).split(':')[0].split('/')[0])
            return [{"path": "/", "label": None, "internal_port": internal_port, "external_port": external_port}]
        return []

    # Custom configuration
    ui_links = []
    for entry in ui_config:
        path = entry.get("path", "/")
        label = entry.get("label")
        port_str = entry.get("port")
        
        if port_str:
            internal_port = int(str(port_str).split(':')[1].split('/')[0]) if ':' in str(port_str) else int(port_str)
            external_port = int(str(port_str).split(':')[0].split('/')[0]) if ':' in str(port_str) else internal_port
        else:
            internal_port = parse_host_port(ports[0]) if ports else None
            external_port = int(str(ports[0]).split(':')[0].split('/')[0]) if ports else None
            
        ui_links.append({
            "path": path,
            "label": label,
            "internal_port": internal_port,
            "external_port": external_port
        })
    return ui_links

@app.route("/")
def index():
    server_name = os.environ.get("SERVER_NAME", "localhost")

    try:
        with open("docker-compose.yml", "r") as f:
            data = yaml.safe_load(f)
    except Exception as e:
        return f"<h1>Error reading compose file</h1><pre>{e}</pre>"

    services = data.get("services", {})
    
    # Check status and parse UI for each service
    for name, svc in services.items():
        ports = svc.get("ports", [])
        ui_links = parse_ui_config(svc)
        
        # Status check: use first UI link's port if available, else first port
        check_port = None
        if ui_links and ui_links[0].get("internal_port"):
            check_port = ui_links[0]["internal_port"]
        elif ports:
            check_port = parse_host_port(ports[0])
            
        if check_port:
            svc["status"] = check_service_status(name, check_port)
        else:
            svc["status"] = None
            
        svc["ui_links"] = ui_links

    return render_template("index.html", services=services, server_name=server_name)

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8500)
