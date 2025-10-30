FROM python:3.11-alpine AS builder

WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir --user -r requirements.txt

FROM python:3.11-alpine

WORKDIR /app
RUN adduser -D appuser

COPY --from=builder /root/.local /home/appuser/.local
COPY app.py .

USER appuser
ENV PATH=/home/appuser/.local/bin:$PATH

EXPOSE 3000
CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "3000"]
