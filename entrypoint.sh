#!/bin/bash
set -e

echo "Starting container as root..."

echo "Installing Python dependencies ..."

su node -c "cd /workspace && poetry install --only main"

# Initialize firewall as root
/usr/local/bin/init-firewall.sh

echo "Switching to user 'node'..."
echo ""

# Run tests and Claude Code as node
exec su node -c "cd /workspace && /usr/local/bin/run-tests.sh && exec crush --yolo"
#exec su node -c "cd /workspace && /usr/local/bin/run-tests.sh && exec bash"