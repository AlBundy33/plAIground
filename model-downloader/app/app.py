from flask import Flask, request, render_template, jsonify
from huggingface_hub import model_info, hf_hub_download
from pathlib import Path
import os
import threading
import glob

app = Flask(__name__)
hf_home = os.environ.get("HF_HOME", str(Path.home() / ".cache/huggingface"))
model_cache_path = Path(hf_home) / "hub"

progress_data = {"status": "idle", "progress": 0, "total": 0, "model_id": ""}

def list_cached_models():
    model_dirs = glob.glob(f"{model_cache_path}/models--*")
    models = []
    for d in model_dirs:
        model_name = Path(d).name.replace("models--", "").replace("--", "/")
        size = sum(f.stat().st_size for f in Path(d).rglob("*") if f.is_file())
        models.append({"name": model_name, "size": round(size / (1024 ** 2), 2)})
    return models

def download_model(model_id):
    global progress_data
    try:
        info = model_info(model_id)
        files = [s.rfilename for s in info.siblings]
        progress_data.update({"status": "running", "progress": 0, "total": len(files), "model_id": model_id})

        for i, filename in enumerate(files, 1):
            hf_hub_download(repo_id=model_id, filename=filename, cache_dir=model_cache_path)
            progress_data["progress"] = i

        progress_data["status"] = "done"
    except Exception as e:
        progress_data.update({"status": f"error: {str(e)}", "progress": 0, "total": 0})

@app.route("/", methods=["GET", "POST"])
def index():
    message = None
    if request.method == "POST":
        model_id = request.form["model_id"]
        if progress_data["status"] == "running":
            message = "❗ Ein Download läuft bereits. Bitte warten."
        else:
            thread = threading.Thread(target=download_model, args=(model_id,))
            thread.start()
            message = f"⬇️ Download von Modell '{model_id}' gestartet."
    models = list_cached_models()
    return render_template("index.html", models=models, message=message, progress=progress_data)

@app.route("/progress")
def progress():
    return jsonify(progress_data)

if __name__ == "__main__":
    app.run(debug=True, host="0.0.0.0")
