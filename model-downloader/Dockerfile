FROM python:3.11-slim

WORKDIR /app

ENV HF_HOME=/huggingface

COPY requirements.txt .
RUN --mount=type=cache,target=/root/.cache/pip \
    pip install --no-cache-dir -r requirements.txt \
 && mkdir ${HF_HOME}

COPY app /app

EXPOSE 8080

CMD ["flask", "run", "--host=0.0.0.0", "--port=8080"]
