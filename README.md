# plAIground

AI playground featuring Ollama, Open WebUI, AnythingLLM, and Image Generation (ComfyUI/Automatic1111).

## 🧠 Project Philosophy

**This project is designed as an educational playground.** 

The primary goal is to allow users to $\text{explore}$, $\text{understand}$, and $\text{experiment}$ with individual AI services in a containerized environment. To facilitate easy testing, debugging, and direct interaction (via CLI or Browser) without complex networking hurdles, **services are intentionally configured to expose their ports directly to the host**.

> [!WARNING]
> **Not for Production**: Because of this intentional port exposure, this configuration should **never** be used in a production environment or on a publicly accessible server.

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

### 🖥️ Interfaces (Web UIs)
| Service | Port | Description |
| :--- | :--- | :--- |
| **Open WebUI** | `8080` | Main interface for LLMs (with Web Search & Tika integration). |
| **AnythingLLM** | `3001` | RAG-focused client with local vector support. |
| **n8n** | `5678` | Workflow automation and AI agent orchestration. |
| **Stack Overview** | `4444` | Dashboard for service monitoring and stack status. |

### 🤖 Inference & Generation
| Service | Port | Description |
| :--- | :--- | :--- |
| **Ollama** | `11434` | Local LLM engine (running models like Llama 3.1). |
| **ComfyUI** | `8188` | Stable Diffusion node-based UI (GPU required for speed). |
| **Automatic1111** | `7860` | Stable Diffusion WebUI. |
| **Jupyter** | `8888` | Python/Data Science notebook for AI experimentation. |

### 🏗️ Data & Infrastructure
| Service | Port | Description |
| :--- | :--- | :--- |
| **Qdrant** | `6333` | Vector database for RAG (Retrieval Augmented Generation). |
| **Tika** | `9998` | Content extraction engine (OCR/Text/Document parsing). |
| **SearXNG** | `9081` | Privacy-respecting metasearch engine for web search integration. |
| **Valkey** | `6379` | High-performance key-value store (Redis alternative) for caching. |

---

## 🔍 Feature Usage

### Running Specific Services (Profiles)
To save resources, you can start only the services you are currently interested in using Docker Compose **profiles**:

* **Start only Ollama**: `docker compose --profile ollama up -d`
* **Start only Image Generation**: `docker compose --profile comfyui up -d` (includes model-downloader)
* **Start only Automatic1111**: `docker compose --profile automatic1111 up -d` (includes model-downloader)
* **Start only n8n**: `docker compose --profile n8n up -d`
* **Start only Stack Overview**: `docker compose --profile stack-overview up -d`
* **Start everything**: `docker compose --profile all up -d`

### OCR & Document Processing (Tika)
You can send documents to the Tika endpoint to extract text/OCR:
```bash
curl -s https://example.com/image.png | curl -s -H "accept: text/plain" -T - http://localhost:9998/tika
```

### Image Generation (ComfyUI)
To use the default workflow, ensure your nodes match these parameters in the JSON:
* **Text**: 6, **ckpt_name**: 4, **width**: 5, **height**: 5, **steps**: 3, **seed**: 3.

> 💡 *Note: This setup is based on insights from [this Open WebUI discussion](https://github.com/open-webui/open-webui/discussions/13434).*

---

## ⚙️ Configuration

The stack is configured via a `.env` file. You can create one by copying the template:
```bash
cp .env.example .env
```

### Key Variables

#### 🤖 LLM Control
* **`ENABLE_OLLAMA_API`**: Set to `true` (default) to use local Ollama.
* **`OPENAI_API_BASE_URL`**: If you provide a URL here (e.g., for LM Studio via `http://host.docker.internal:1234/v1`), Open WebUI will automatically enable the OpenAI-compatible mode.
* **`OPENAI_API_KEY`**: The API key for external services.

#### 🔐 Security & Services
* **`WEBUI_AUTH`**: Set to `true` to enable authentication in Open WebUI.
* **`WEBUI_SECRET_KEY`**: A secure string for session management.

#### ⚙️ n8n Configuration
* **`N8N_HOST`**: Hostname for n8n (default: `localhost`).
* **`N8N_PROTOCOL`**: Protocol for n8n (default: `http`).
* **`N8N_PORT`**: Port for n8n (default: `5678`).
* **`N8N_SECURE_COOKIE`**: Set to `true` when using HTTPS (default: `false`).
* **`N8N_ENCRYPTION_KEY`**: REQUIRED. A secure encryption key for n8n data. Generate with `openssl rand -base64 24`.
* **`N8N_INSTANCE_OWNER_MANAGED_BY_ENV`**: Set to `true` to auto-provision the owner account on first start.
* **`N8N_INSTANCE_OWNER_EMAIL`**: Email address for the n8n owner account.
* **`N8N_INSTANCE_OWNER_FIRST_NAME`**: First name for the n8n owner account.
* **`N8N_INSTANCE_OWNER_LAST_NAME`**: Last name for the n8n owner account.
* **`N8N_INSTANCE_OWNER_PASSWORD_HASH`**: bcrypt hash of the owner's password. Generate with:
  ```bash
  docker run --rm node:20-alpine sh -c "cd /tmp && npm install bcryptjs && node -e \"const bcryptjs = require('bcryptjs'); console.log(bcryptjs.hashSync('YOUR_PASSWORD', 10))\""
  ```

---

## 🛠 Setup & Maintenance

### WSL2 & Docker Optimization (Windows Users)
If running in WSL2, use bind-mounts outside the WSL-VM for better performance. To prevent the WSL VHDX from growing indefinitely:
1.  **Cleanup Docker**: `docker system prune -a --volumes`
2.  **Shutdown WSL**: `wsl --shutdown`
3.  **Shrink Disk (PowerShell)**: 
    `Optimize-VHD -Path "$env:USERPROFILE\\AppData\\Local\\Packages\\CanonicalGroupLimited.UbuntuonWindows_79rhkp1fndgsc\\LocalState\\ext4.vhdx" -Mode Full`

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

---

## 🤖 AI Assistance Notice

Parts of the development, documentation, and configuration management of this project are performed with the assistance of **Pi** (from [pi.dev](https://pi.dev)) using the **google/gemma-4-26b-a4b** model.
