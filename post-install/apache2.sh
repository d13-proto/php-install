#!/usr/bin/env bash
#
# apache2 安装后脚本
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && cd .. && pwd)"
source "${SCRIPT_DIR}/lib/helpers.sh"

version="$1"

# 启用 apache2 模块（a2enmod 需要 sudo）
if command -v a2enmod &>/dev/null; then
    sudo a2enmod "php${version}" || true
fi

# 重启 apache2
if command -v systemctl &>/dev/null; then
    sudo systemctl restart apache2 || true
fi
