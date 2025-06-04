# https://github.com/AUTOMATIC1111/stable-diffusion-webui/discussions/5049
# https://hub.docker.com/r/nvidia/cuda/tags?name=base-ubuntu
FROM nvidia/cuda:12.9.0-base-ubuntu22.04 AS base

ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    PYTHONIOENCODING=UTF-8

RUN --mount=type=cache,target=/var/lib/apt/lists \
    --mount=type=cache,target=/var/cache/apt \
    --mount=type=cache,target=/root/.cache/pip \
    <<INSTALL
        apt update
        apt install -y --no-install-recommends \
            bc \
            git \
            google-perftools \
            libgl1 \
            libglib2.0-0 \
            libsm6 \
            libxext6 \
            libxrender-dev \
            python-is-python3 \
            python3 \
            python3-pip \
            python3-venv \
            wget
        apt clean
INSTALL

FROM base AS automatic1111
WORKDIR /app

RUN git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui .

ENV HF_HOME=/huggingface
ENV DATA_DIR=/data

RUN --mount=type=cache,target=/root/.cache/pip \
    mkdir -m 775 -p $DATA_DIR $HF_HOME \
 && set -e \
 && ./webui.sh -f --data-dir $DATA_DIR --skip-torch-cuda-test --exit --xformers --reinstall-xformers

EXPOSE 7860

VOLUME ${HF_HOME}
VOLUME ${DATA_DIR}

# do not use json-sytanx for CMD or DATA_DIR will not be set
CMD ./webui.sh -f --api --listen --skip-prepare-environment --data-dir "${DATA_DIR}" --xformers

# TBD
FROM base as comfyui
FROM nvidia/cuda:12.9.0-cudnn-runtime-ubuntu24.04

# System dependencies
RUN apt install --update -y --no-install-recommends \
    git \
    python3 python3-pip python-is-python3 \
    wget curl libgl1 libglib2.0-0 \
 && apt clean

# Clone repo
RUN git clone https://github.com/comfyanonymous/ComfyUI.git /app

WORKDIR /app
ENV HF_HOME=/huggingface

# Install requirements
RUN --mount=type=cache,target=/root/.cache/pip \
    mkdir -m 775 -p $HF_HOME \
 && python3 -m pip config set global.break-system-packages true \
 && pip install -r requirements.txt

VOLUME /huggingface
VOLUME /app/models
VOLUME /app/outputs
VOLUME /app/config
VOLUME /app/extensions

EXPOSE 8188

# Default entrypoint
CMD ["python", "main.py", "--listen", "0.0.0.0"]