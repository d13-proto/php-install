# php-install

基于 apt 的 PHP 多版本安装工具，支持 phpenv 集成。

## 特性

- **多版本共存**：利用 ondrej/php PPA 安装多个 PHP 版本
- **phpenv 集成**：自动注册到 `~/.phpenv/versions/`
- **分安装后脚本**：每个包独立配置脚本，按需扩展
- **幂等安装**：重复运行安全，已存在则跳过

## 依赖

- Ubuntu / Debian（apt）
- 已安装 [phpenv](https://github.com/phpenv/phpenv)
- sudo 权限

## 安装

### 系统级（推荐）

```bash
git clone <仓库地址> /tmp/php-install
cd /tmp/php-install
sudo make install
```

安装到 `/usr/local/lib/php-install/` 和 `/usr/local/bin/php-install`。

### 用户级

```bash
git clone <仓库地址> /tmp/php-install
cd /tmp/php-install
make install PREFIX=$HOME/.local
```

确保 `~/.local/bin` 在 `$PATH` 中。

### 临时使用

```bash
git clone <仓库地址> ~/php-install
~/php-install/php-install 8.3
```

## 用法

```bash
# 安装默认包 + 执行安装后脚本
php-install 8.3

# 默认包 + 额外包
php-install 8.3 apache2

# 多个额外包
php-install 8.3 apache2 grpc

# 仅执行安装后脚本（跳过 apt 安装，用于 dpkg 升级后恢复配置）
php-install --no-install 8.3
```

安装后切换版本：
```bash
phpenv global 8.3
php -v
```

**fpm 使用**：工具创建独立 pool `php-install.conf`（监听 `php-install.sock`），不修改 dpkg 管理的 `www.conf`。Web 服务器需指向此 socket：
```nginx
fastcgi_pass unix:/run/php/php8.3-fpm-php-install.sock;
```

## 目录结构

```
php-install/
├── Makefile                 # 安装/卸载
├── php-install              # 主入口脚本
├── lib/
│   └── helpers.sh           # 共享辅助函数
├── post-install/
│   ├── cli.sh               # phpenv 注册
│   ├── fpm.sh               # 独立 fpm pool + systemctl
│   ├── xdebug.sh            # xdebug 调试配置
│   ├── swoole.sh            # swoole 配置
│   └── apache2.sh           # apache2 模块配置
├── README.md
└── CONTEXT.md
```

## 安装后脚本

`post-install/` 目录下的脚本负责**配置写入**，不处理 apt 安装。

脚本接收一个位置参数：PHP 版本号（如 `8.3`）。

### 添加自定义脚本

创建 `post-install/<包名>.sh`：

```bash
#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && cd .. && pwd)"
source "${SCRIPT_DIR}/lib/helpers.sh"

version="$1"

# 向所有已安装 SAPI 写入配置
php_install_configure "$version" "myext" "
; php-install 配置

myext.enable=1
"
```

### 辅助函数

`lib/helpers.sh` 提供：

| 函数 | 说明 |
|------|------|
| `php_install_sapis <version>` | 返回该版本下所有已安装 SAPI |
| `php_install_write_conf <version> <sapi> <pkg> <content>` | 向指定 SAPI 的 conf.d 写入 |
| `php_install_configure <version> <pkg> <content>` | 向所有 SAPI 写入相同配置 |
| `php_install_phpenv_register <version>` | 注册 phpenv 版本 |

## 配置原则

- **不碰 `php.ini` 和 `mods-available/`**：只向 SAPI 的 `conf.d/` 写入 `99-php-install-*.ini`，兼容 `phpenmod`
- **覆盖重写**：安装后脚本每次运行都完整重写自己的配置文件，天然幂等
- **不重复声明扩展加载**：apt 已负责 `extension=xxx.so` / `zend_extension=xxx.so`，安装后脚本仅覆盖自定义参数
- **静默跳过**：仓库中没有对应脚本的包，仅安装 apt 包，不提示、不报错
