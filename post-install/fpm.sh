#!/usr/bin/env bash
#
# fpm 安装后脚本
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && cd .. && pwd)"
source "${SCRIPT_DIR}/lib/helpers.sh"

version="$1"
current_user="$(whoami)"

# 独立 pool 配置
cat <<EOF | sudo tee "/etc/php/${version}/fpm/pool.d/php-install.conf" >/dev/null
[php-install]
user = ${current_user}
group = ${current_user}
listen = /run/php/php${version}-fpm-php-install.sock
listen.owner = ${current_user}
listen.group = ${current_user}

pm = dynamic
pm.max_children = 5
pm.start_servers = 2
pm.min_spare_servers = 1
pm.max_spare_servers = 3
EOF

# 管理服务
if command -v systemctl &>/dev/null; then
    sudo systemctl enable "php${version}-fpm"
    sudo systemctl start "php${version}-fpm" || true
fi

echo "fpm pool 已创建: /etc/php/${version}/fpm/pool.d/php-install.conf"
echo "socket 路径: /run/php/php${version}-fpm-php-install.sock"
