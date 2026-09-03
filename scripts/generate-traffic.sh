#!/usr/bin/env bash
set -euo pipefail

echo "Генерация access-логов Nginx..."
for i in $(seq 1 20); do
  curl -s "http://localhost:8080/" > /dev/null
  curl -s "http://localhost:8080/api/" > /dev/null
done

echo "Генерация логов demo-app..."
for i in $(seq 1 10); do
  printf '{"timestamp":"%s","level":"INFO","service":"demo-app","message":"order processed","order_id":%s}\n' \
    "$(date -Iseconds)" "$i" >> app/logs/service.log
done

echo "Логи записаны."
