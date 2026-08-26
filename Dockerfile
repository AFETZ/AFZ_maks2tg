ARG PYTHON_VERSION=3.12

FROM python:${PYTHON_VERSION}-slim AS builder

WORKDIR /build

COPY requirements.txt ./

RUN python -m pip install \
    --no-cache-dir \
    --progress-bar off \
    --prefix=/install \
    -r requirements.txt

FROM python:${PYTHON_VERSION}-slim AS runtime

ENV MALLOC_ARENA_MAX=2 \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

COPY --from=builder /install /usr/local

COPY app/ ./app/

CMD ["python", "-m", "app.main"]
