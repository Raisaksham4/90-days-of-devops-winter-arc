FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt \
    && groupadd --gid 10001 app \
    && useradd --uid 10001 --gid 10001 --no-create-home \
       --shell /usr/sbin/nologin app

COPY --chown=10001:10001 app.py .

USER 10001:10001

EXPOSE 5000

CMD ["python", "app.py"]
