#!/usr/bin/env bash
#
# swoole 安装后脚本
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && cd .. && pwd)"
source "${SCRIPT_DIR}/lib/helpers.sh"

version="$1"

php_install_configure "$version" "swoole" "
; php-install 配置

swoole.use_shortname=On
"
