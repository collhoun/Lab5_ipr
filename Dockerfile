FROM python:3.13-alpine AS dependencies

WORKDIR /app

COPY requirements.txt .

RUN apk add --no-cache --virtual .build-deps build-base libffi-dev openssl-dev python3-dev musl-dev && \
    pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir --target=/app/vendor -r requirements.txt && \
    apk del .build-deps

FROM python:3.13-alpine AS builder

WORKDIR /app

COPY --from=dependencies /app/vendor /app/vendor

COPY src/ ./src/

ENV PYTHONPATH="/app/vendor:/app" \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1


RUN python -m py_compile src/*.py


FROM builder AS tester

COPY tests/ ./tests/

RUN pip install --no-cache-dir pytest && \
    pytest tests/ -v

FROM python:3.13-alpine AS production

WORKDIR /app


RUN addgroup -g 1000 -S appgroup && \
    adduser -u 1000 -S appuser -G appgroup && \
    mkdir -p /app && chown -R appuser:appgroup /app


COPY --from=dependencies --chown=appuser:appgroup /app/vendor /app/vendor
COPY --from=builder --chown=appuser:appgroup /app/src ./src/


ENV PYTHONPATH="/app/vendor:/app" \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1

USER appuser

HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
    CMD python -c "import src.calculator; print('OK')" || exit 1

ENTRYPOINT ["python", "-m", "src.main"]
