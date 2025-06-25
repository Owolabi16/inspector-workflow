#!/bin/bash

# Gitleaks Security Scanner Setup Script
# This script prepares and configures Gitleaks for secret scanning

set -e

echo "🔍 Setting up Gitleaks security scanner..."

# Check if gitleaks is installed
if ! command -v gitleaks &> /dev/null; then
    echo "❌ Gitleaks is not installed or not in PATH"
    exit 1
fi

# Check gitleaks version
GITLEAKS_VERSION=$(gitleaks version 2>/dev/null || echo "unknown")
echo "✅ Gitleaks version: $GITLEAKS_VERSION"

# Verify config file exists
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/gitleaks.toml"

if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "❌ Gitleaks config file not found: $CONFIG_FILE"
    exit 1
fi

echo "✅ Using config file: $CONFIG_FILE"

# Validate config file
echo "🔧 Validating Gitleaks configuration..."
if gitleaks detect --config="$CONFIG_FILE" --no-git --dry-run 2>/dev/null; then
    echo "✅ Gitleaks configuration is valid"
else
    echo "⚠️  Warning: Gitleaks configuration validation failed, proceeding anyway..."
fi

# Set environment variable for gitleaks config
export GITLEAKS_CONFIG="$CONFIG_FILE"

echo "🚀 Gitleaks setup completed successfully!"
echo "💡 You can now run: gitleaks detect --config=\"$CONFIG_FILE\" --source ."