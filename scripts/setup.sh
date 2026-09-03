#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

echo "[1/5] Проверка vm.max_map_count..."
CURRENT="$(sysctl -n vm.max_map_count 2>/dev/null || echo 0)"
if [ "$CURRENT" -lt 262144 ]; then
  echo "Нужно sudo: sysctl -w vm.max_map_count=262144"
  sudo sysctl -w vm.max_map_count=262144
fi

echo "[2/5] Подготовка каталогов логов..."
mkdir -p nginx/logs app/logs
touch nginx/logs/access.log nginx/logs/error.log app/logs/service.log
chmod -R a+rw nginx/logs app/logs

echo "[3/5] Запуск ELK стека..."
bash "$(dirname "$0")/compose.sh" up -d

echo "[4/5] Ожидание Elasticsearch..."
for i in $(seq 1 30); do
  if curl -s "http://localhost:9200/_cluster/health?pretty" | grep -q '"status"'; then
    break
  fi
  sleep 5
done

echo "[5/5] Генерация трафика..."
bash "$ROOT/scripts/generate-traffic.sh"

echo
echo "Готово."
echo "Elasticsearch: http://localhost:9200"
echo "Kibana:        http://localhost:5601"
echo "Nginx:         http://localhost:8080"
echo
curl -s "http://localhost:9200/_cluster/health?pretty"
