#!/bin/bash

set -e

echo "🚀 Installing Telegram MTProto Proxy..."

# Check root
if [ "$EUID" -ne 0 ]; then
  echo "❌ Please run as root (sudo)"
  exit 1
fi

# Install Docker if not installed
if ! command -v docker &> /dev/null; then
  echo "📦 Installing Docker..."
  apt update
  apt install -y ca-certificates curl gnupg lsb-release

  curl -fsSL https://get.docker.com | sh
  systemctl enable docker
  systemctl start docker
fi

# Generate random secret
SECRET=$(head -c 16 /dev/urandom | xxd -ps)
PORT=4856

# Run proxy container
docker rm -f telegram-proxy >/dev/null 2>&1 || true

docker run -d \
  --name telegram-proxy \
  -p $PORT:4856 \
  -e SECRET=$SECRET \
  --restart always \
  telegrammessenger/proxy:latest

# Get server IP
IP=$(curl -s ifconfig.me || hostname -I | awk '{print $1}')

echo ""
echo "✅ Telegram MTProto Proxy is ready!"
echo ""
echo "📡 Proxy info:"
echo "IP:     $IP"
echo "Port:   $PORT"
echo "Secret: $SECRET"
echo ""
echo "🔗 tg://proxy?server=$IP&port=$PORT&secret=$SECRET"
echo ""
