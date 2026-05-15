#!/usr/bin/env bash
#
# opcache 安装后脚本
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && cd .. && pwd)"
source "${SCRIPT_DIR}/lib/helpers.sh"

version="$1"

php_install_configure "$version" "opcache" "
; php-install 配置

opcache.jit = disable
opcache.enable_cli = 1
opcache.revalidate_freq = 0
opcache.memory_consumption = 256
opcache.interned_strings_buffer = 64
opcache.max_accelerated_files = 80000
"
