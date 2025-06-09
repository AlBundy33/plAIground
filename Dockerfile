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
ENV TORCH_HOME=/torch.hub
ENV DATA_DIR=/data

RUN --mount=type=cache,target=/root/.cache/pip \
    mkdir -m 775 -p $DATA_DIR $HF_HOME $TORCH_HOME \
 && set -e \
 && ./webui.sh -f --data-dir $DATA_DIR --skip-torch-cuda-test --exit --xformers --reinstall-xformers

EXPOSE 7860

VOLUME ${HF_HOME}
VOLUME ${TORCH_HOME}
VOLUME ${DATA_DIR}

# do not use json-sytanx for CMD or DATA_DIR will not be set
CMD ./webui.sh -f --api --listen --skip-prepare-environment --data-dir "${DATA_DIR}" --xformers

FROM base AS comfyui
WORKDIR /app

# Clone repo
RUN git clone https://github.com/comfyanonymous/ComfyUI.git .

ENV HF_HOME=/huggingface
ENV TORCH_HOME=/torch.hub
ENV DATA_DIR=/data

# Install requirements
RUN --mount=type=cache,target=/root/.cache/pip \
    mkdir -m 775 -p $HF_HOME $DATA_DIR $TORCH_HOME \
 && pip install -r requirements.txt

VOLUME ${HF_HOME}
VOLUME ${TORCH_HOME}
VOLUME ${DATA_DIR}

EXPOSE 8188

# download
# https://huggingface.co/Comfy-Org/stable-diffusion-v1-5-archive/resolve/main/v1-5-pruned-emaonly-fp16.safetensors?download=true
# to data/comfyui/models/checkpoints

# Default entrypoint
# mkdir is workaround for https://github.com/comfyanonymous/ComfyUI/issues/8434
CMD mkdir -p ${DATA_DIR}/custom_nodes && python main.py --listen --base-directory "${DATA_DIR}"
#CMD python main.py --listen --base-directory "${DATA_DIR}"