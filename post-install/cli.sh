#!/usr/bin/env bash
#
# cli 安装后脚本
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && cd .. && pwd)"
source "${SCRIPT_DIR}/lib/helpers.sh"

version="$1"

# 写入 cli 配置
php_install_write_conf "$version" "cli" "cli" "
; php-install 配置

; 开启错误显示
display_errors = On
display_startup_errors = On
; 报告所有级别的错误、警告和提示
error_reporting = E_ALL

; 不限制内存和执行时间
memory_limit = -1
max_execution_time = 0
"

# 检查 phpenv 是否已安装
if [[ ! -d "$PHPENV_ROOT" ]]; then
    echo "警告: 未找到 phpenv 目录 ${PHPENV_ROOT}，跳过版本注册"
    echo "请确保已安装 phpenv: https://github.com/phpenv/phpenv"
    exit 0
fi

# 注册到 phpenv
php_install_phpenv_register "$version"
