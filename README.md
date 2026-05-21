# plAIground

AI playground featuring Ollama, Open WebUI, AnythingLLmu, and Image Generation (ComfyUI/Automatic1111).

## 🚀 Quick Start

This project uses a dual-mode configuration to support both CPU-only environments and NVIDIA GPU workstations.

### Mode 1: CPU Only (Universal)
Use this mode for any machine (Laptop, Server, etc.) without an NVIDIA GPU.
```bash
docker compose --profile all up -d
```

### Mode 2: GPU Accelerated
Use this mode on machines with an **NVIDIA GPU** and the **NVIDIA Container Toolkit** installed. This enables hardware acceleration for Ollama, ComfyUI, Automatic1111, and Jupyter.
```bash
docker compose --profile all -f docker-compose.yml -f docker-compose.gpu.yml up -d
```

### Useful Commands
* **View Logs**: `docker compose logs -f`
* **Stop Stack**: `docker compose down`
* **Check Status**: `docker compose ps`

---

## 🛠 Services Overview

| Service | Port | Description |
| :--- | :--- | :--- |
| **Open WebUI** | `8080` | Main interface for LLMs (with Web Search & Tika integration). |
| **AnythingLLM** | `3001` | RAG-focused client with local vector support. |

| Service | Port | Description |
| :--- | :--- | :--- |
| **Ollama** | `11434` | Local LLM engine. |
| **ComfyUI** | `8188` | Stable Diffusion node-based UI (GPU required for speed). |
| **Automatic1111** | `7860` | Stable Diffusion WebUI. |
| **Jupyter** | `8888` | Python/Data Science notebook. |
| **Qdrant** | `6333` | Vector database for RAG. |
| **Tika** | `9998` | Content extraction engine (OCR/Text). |
| **SearXNG** | `9081` | Privacy-respecting metasearch engine. |
| **Stack Overview** | `4444` | Dashboard for service monitoring. |

---

## 🔍 Feature Usage

### OCR & Document Processing (Tika)
You can send documents to the Tika endpoint to extract text/OCR:
```bash
curl -s https://example.com/image.png | curl -s -H "accept: text/plain" -T - http://localhost:9998/tika
```

### Image Generation (ComfyUI)
To use the default workflow, ensure your nodes match these parameters in the JSON:
* **Text**: 6, **ckpt_name**: 4, **width**: 5, **height**: 5, **steps**: 3, **seed**: 3.

---

## ⚙️ Setup & Maintenance

### WSL2 & Docker Optimization (Windows Users)
If running in WSL2, use bind-mounts outside the WSL-VM for better performance. To prevent the WSL VHDX from growing indefinitely:
1.  **Cleanup Docker**: `docker system prune -to --volumes`
2.  **Shutdown WSL**: `wsl --shutdown`
3.  **Shrink Disk (PowerShell)**: 
    `Optimize-VHD -Path "$env:USERPROFILE\AppData\Local\Packages\CanonicalGroupLimited.UbuntuonWindows_79rhkp1fndgsc\LocalState\ext4.vhdx" -Mode Full`

### Prerequisites (Linux/WSL)
**NVIDIA Container Toolkit Installation:**
```bash
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
  && curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
    sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
    sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list

sudo apt-get update
sudo apt-get install -y nvidia-container-toolkit
sudo nvidia-ctk runtime configure --runtime=docker
sudo systemctl restart docker
```

**Exposing Ports to LAN (Windows)**: 
Run `wsl-portproxy.cmd` (which calls `wint-portproxy.ps1`) to make your services accessible from other devices on your local network.
