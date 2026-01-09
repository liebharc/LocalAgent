#!/bin/bash
set -e

echo "=============================================="
echo "FIREWALL TEST"
echo "=============================================="
echo "User: $(whoami)"
echo ""

echo "[TEST] AI provider access"
curl -s http://localai:8080/models

echo "[TEST] Firewall integrity"
iptables -F 2>&1 | grep -q "Permission denied"

echo "[TEST] Firewall: external internet access"
if curl -s --connect-timeout 5 http://example.com >/dev/null 2>&1; then
    echo "ERROR: External internet access is allowed"
    exit 1
else
    echo "PASS: External internet access blocked"
fi

echo ""
echo "ALL TESTS PASSED"
