#!/usr/bin/env bash
#
# php-install 共享辅助函数
# 安装后脚本可 source 此文件获取常用功能
#

PHPENV_ROOT="${PHPENV_ROOT:-$HOME/.phpenv}"

# 获取指定 PHP 版本下已安装的所有 SAPI 列表（每行一个）
php_install_sapis() {
    local version="$1"
    local php_etc="/etc/php/${version}"
    if [[ ! -d "$php_etc" ]]; then
        return 0
    fi
    local saved_nullglob
    saved_nullglob=$(shopt -p nullglob 2>/dev/null || true)
    shopt -s nullglob
    local dirs=("$php_etc"/*/)
    eval "$saved_nullglob" 2>/dev/null || shopt -u nullglob
    for dir in "${dirs[@]}"; do
        if [[ -d "${dir}conf.d" ]]; then
            basename "$dir"
        fi
    done
}

# 向指定 SAPI 的 conf.d 写入配置文件（带 sudo）
# 用法: php_install_write_conf <version> <sapi> <pkg> <content>
php_install_write_conf() {
    local version="$1"
    local sapi="$2"
    local pkg="$3"
    local content="$4"
    local target="/etc/php/${version}/${sapi}/conf.d/99-php-install-${pkg}.ini"

    printf '%s' "$content" | sudo tee "$target" >/dev/null
}

# 向指定版本的所有已安装 SAPI 写入相同配置
# 用法: php_install_configure <version> <pkg> <content>
php_install_configure() {
    local version="$1"
    local pkg="$2"
    local content="$3"

    while IFS= read -r sapi; do
        php_install_write_conf "$version" "$sapi" "$pkg" "$content"
    done < <(php_install_sapis "$version")
}

# 注册 phpenv 版本（符号链接所有以版本号为后缀的二进制）
# 用法: php_install_phpenv_register <version>
php_install_phpenv_register() {
    local version="$1"
    local version_dir="${PHPENV_ROOT}/versions/${version}"
    local bin_dir="${version_dir}/bin"

    if [[ -L "${bin_dir}/php" ]]; then
        echo "phpenv 版本 ${version} 已注册，跳过"
        return 0
    fi

    mkdir -p "$bin_dir"

    for bin in /usr/bin/*"${version}"; do
        if [[ -x "$bin" ]]; then
            local name
            name="$(basename "$bin" "${version}")"
            ln -sf "$bin" "${bin_dir}/${name}"
        fi
    done

    # 处理 php 本身（ondrej PPA 中通常是 /usr/bin/php8.3，已经在上面的循环中处理为 php）
    # 但为了兼容性，再确保 php 链接存在
    if [[ ! -L "${bin_dir}/php" && -x "/usr/bin/php${version}" ]]; then
        ln -sf "/usr/bin/php${version}" "${bin_dir}/php"
    fi

    echo "已注册 phpenv 版本: ${version}"
}
