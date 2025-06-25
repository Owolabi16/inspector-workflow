#!/bin/bash

# Workflow Input Validation Script
# This script validates the inputs passed to the security workflow

set -e

echo "🔍 Starting workflow input validation..."

# Parse JSON inputs from environment variables
SERVICE_NAME=$(echo "$WORKFLOW_INPUTS" | jq -r '.service_name // empty')
ENVIRONMENT=$(echo "$WORKFLOW_INPUTS" | jq -r '.environment // empty')
ORGANIZATION=$(echo "$WORKFLOW_INPUTS" | jq -r '.organization // empty')
ENABLE_SECURE_SCAN=$(echo "$WORKFLOW_INPUTS" | jq -r '.enable_secure_scan // empty')

# Validation functions
validate_required_field() {
    local field_name="$1"
    local field_value="$2"
    
    if [[ -z "$field_value" || "$field_value" == "null" ]]; then
        echo "❌ Error: Required field '$field_name' is missing or empty"
        exit 1
    else
        echo "✅ $field_name: $field_value"
    fi
}

validate_optional_field() {
    local field_name="$1"
    local field_value="$2"
    local default_value="$3"
    
    if [[ -z "$field_value" || "$field_value" == "null" ]]; then
        echo "ℹ️  $field_name: Using default ($default_value)"
    else
        echo "✅ $field_name: $field_value"
    fi
}

validate_boolean_field() {
    local field_name="$1"
    local field_value="$2"
    
    if [[ "$field_value" != "true" && "$field_value" != "false" ]]; then
        echo "⚠️  Warning: $field_name should be 'true' or 'false', got: $field_value"
    else
        echo "✅ $field_name: $field_value"
    fi
}

# Validate required fields
echo ""
echo "📋 Validating required fields:"
validate_required_field "service_name" "$SERVICE_NAME"
validate_required_field "environment" "$ENVIRONMENT"
validate_required_field "organization" "$ORGANIZATION"

# Validate service name format
if [[ ! "$SERVICE_NAME" =~ ^[a-z0-9-]+$ ]]; then
    echo "❌ Error: service_name must contain only lowercase letters, numbers, and hyphens"
    exit 1
fi

# Validate environment
if [[ "$ENVIRONMENT" != "staging" && "$ENVIRONMENT" != "prod" && "$ENVIRONMENT" != "development" ]]; then
    echo "⚠️  Warning: environment should typically be 'staging', 'prod', or 'development'"
fi

# Validate security settings
echo ""
echo "🔒 Validating security settings:"
validate_boolean_field "enable_secure_scan" "$ENABLE_SECURE_SCAN"

# Check GitHub context
REPO_NAME=$(echo "$GITHUB_CONTEXT" | jq -r '.repository // empty')
BRANCH_NAME=$(echo "$GITHUB_CONTEXT" | jq -r '.ref_name // empty')

echo ""
echo "📦 Repository context:"
echo "✅ Repository: $REPO_NAME"
echo "✅ Branch: $BRANCH_NAME"

# Validate resource limits if provided
MEMORY_LIMIT=$(echo "$WORKFLOW_INPUTS" | jq -r '.memory_limit // empty')
CPU_LIMIT=$(echo "$WORKFLOW_INPUTS" | jq -r '.cpu_limit // empty')

if [[ -n "$MEMORY_LIMIT" && "$MEMORY_LIMIT" != "null" ]]; then
    if [[ ! "$MEMORY_LIMIT" =~ ^[0-9]+[MG]i?$ ]]; then
        echo "⚠️  Warning: memory_limit format may be invalid: $MEMORY_LIMIT"
        echo "    Expected format: 256Mi, 1Gi, etc."
    fi
fi

if [[ -n "$CPU_LIMIT" && "$CPU_LIMIT" != "null" ]]; then
    if [[ ! "$CPU_LIMIT" =~ ^[0-9]+m?$ ]]; then
        echo "⚠️  Warning: cpu_limit format may be invalid: $CPU_LIMIT"
        echo "    Expected format: 200m, 1000m, 1, etc."
    fi
fi

echo ""
echo "✅ All validations completed successfully!"
echo "🚀 Proceeding with deployment pipeline..."