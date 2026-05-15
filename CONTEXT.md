# php-install 领域上下文

## 术语表

### PHP 版本（PHP Version）
通过 apt 源安装的特定 PHP 主版本，如 8.2、8.3、8.4。在 phpenv 中以 `8.3` 等标识注册。

### phpenv 外接（External phpenv）
工具不安装或管理 phpenv 本身，假设用户已自行安装并配置好 `PATH`。工具只负责将 apt 安装的 PHP 版本链接/注册到 phpenv 的目录结构中。

### 包（Package）
通过 apt 安装的 PHP 相关单元，包括 SAPI（如 `cli`、`fpm`）和扩展（如 `curl`、`bcmath`、`redis`）。包名对应 apt 包名的后缀部分，即 `php<version>-<pkg>`。

### 默认包（Default Packages）
不带包名时自动安装的一组包：`common`、`cli`、`fpm`、`bcmath`、`curl`、`intl`、`mbstring`、`memcached`、`mysql`、`pgsql`、`redis`、`swoole`、`xdebug`、`xml`、`zip`。带包名时在默认包基础上追加指定包。

### 系统级配置（System-Level Configuration）
工具直接操作 `/etc/php/<version>/` 下的配置文件，不维护独立的 phpenv 配置空间。

### 版本注册（Version Registration）
以 `8.3` 等主版本号直接命名，在 `~/.phpenv/versions/8.3/bin/php` 创建指向 `/usr/bin/php8.3` 的符号链接。注册时自动探测 `/usr/bin/` 中所有以版本号为后缀的二进制（如 `phpize8.3`、`php-config8.3`），一并创建符号链接。注册逻辑由 `cli` 的安装后脚本负责执行。

### 安装后脚本（Post-Install Script）
纯配置脚本，不负责安装包本身。工具统一通过 apt 安装包后，调用对应脚本执行配置写入。脚本仅向 SAPI 的 `conf.d/` 目录写入实际文件 `99-php-install-<pkg>.ini`，不修改 `php.ini` 或 `mods-available/` 下的文件，确保与 dpkg 和 `phpenmod` 兼容。文件以覆盖重写方式写入，天然幂等。SAPI 安装后脚本（如 `fpm`）可包含 `systemctl enable/start` 调用。`fpm` 脚本创建独立 pool 配置文件，不修改 dpkg 管理的 `www.conf`。

### 静默跳过（Silent Skip）
用户请求的包在仓库中没有对应的安装后脚本时，工具仅安装 apt 包，静默跳过配置步骤。

### 幂等性（Idempotency）
版本注册时目标已存在仅提示并跳过。安装后脚本通过覆盖重写自身管理的 `conf.d/99-*` 文件实现幂等，不依赖外部状态文件。apt 安装本身幂等。
