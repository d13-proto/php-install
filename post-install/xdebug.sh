#!/usr/bin/env bash
#
# xdebug 安装后脚本
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && cd .. && pwd)"
source "${SCRIPT_DIR}/lib/helpers.sh"

version="$1"

php_install_configure "$version" "xdebug" "
; php-install 配置

xdebug.mode = debug,develop,profile,coverage
xdebug.start_with_request = trigger
xdebug.discover_client_host = true
xdebug.max_nesting_level = 512
"
