#!/usr/bin/env bash

set -euo pipefail

env_file="$1"
ssm_path="$2"

if [[ ! -f "$env_file" ]]; then
    echo "Error: file not found -> $env_file"
    exit 1
fi

if [[ -z "$ssm_path" ]]; then
    echo "Error: SSM path is required"
    exit 1
fi


# =========================
# Phase 1: Read env file
# =========================
declare -a KEYS VALUES

while IFS='=' read -r key value; do
    [[ -z "$key" ]] && continue

    KEYS+=("$key")
    VALUES+=("$value")
done < "$env_file"


# =========================
# Phase 2: Prompt + write SSM
# =========================
for i in "${!KEYS[@]}"; do
    key="${KEYS[$i]}"
    value="${VALUES[$i]}"

    read -rp "Should '$key' be stored as secret? (y/n): " yn

    type="String"

    if [[ "$yn" =~ ^[Yy]$ ]]; then
        type="SecureString"
    fi

    aws ssm put-parameter \
    --name "${ssm_path}/${key}" \
    --value "$value" \
    --type "$type" \
    --overwrite
done
