#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

echo "Переключение доставки логов Nginx: Logstash -> Filebeat"
echo "1) Отключаем nginx pipeline в Logstash"
mv logstash/pipeline/nginx.conf logstash/pipeline/nginx.conf.disabled 2>/dev/null || true
cat > logstash/pipelines.yml << 'EOF'
- pipeline.id: app
  path.config: "/usr/share/logstash/pipeline/app.conf"
  pipeline.workers: 1
EOF

echo "2) Перезапуск Logstash и Filebeat"
bash "$(dirname "$0")/compose.sh" restart logstash filebeat

echo "3) Генерация нового трафика"
bash "$ROOT/scripts/generate-traffic.sh"

echo "Готово. В Kibana смотрите индекс nginx-filebeat-*"
