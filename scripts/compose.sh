#!/usr/bin/env bash
# Общий wrapper для docker compose / docker-compose

compose() {
  if docker compose version >/dev/null 2>&1; then
    if docker info >/dev/null 2>&1; then
      docker compose "$@"
      return
    fi
  fi

  if command -v docker-compose >/dev/null 2>&1; then
    if docker-compose version >/dev/null 2>&1 && docker info >/dev/null 2>&1; then
      docker-compose "$@"
      return
    fi
  fi

  if docker info >/dev/null 2>&1; then
    cat <<'EOF'
Docker Compose не найден.

Установите плагин v2:
  sudo apt update
  sudo apt install -y docker-compose-v2
  docker compose version
EOF
    exit 1
  fi

  cat <<'EOF'
Нет доступа к Docker (permission denied на /var/run/docker.sock).

Вариант 1 — добавить пользователя в группу docker (рекомендуется):
  sudo usermod -aG docker $USER
  newgrp docker
  docker info

После этого перезапустите терминал или выполните newgrp docker,
затем снова:
  bash scripts/setup.sh

Вариант 2 — разовый запуск через sudo:
  sudo bash scripts/setup.sh
EOF
  exit 1
}

compose "$@"
