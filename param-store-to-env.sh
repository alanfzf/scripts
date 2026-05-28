#!/usr/bin/env bash

set -euo pipefail

ssm_path="$1"

aws ssm get-parameters-by-path \
  --path "$ssm_path" \
  --recursive \
  --with-decryption \
  --output json \
| jq -r '.Parameters[] | "\(.Name | split("/") | last)=\(.Value)"' \
> env
