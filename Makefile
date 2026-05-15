PREFIX ?= /usr/local
BINDIR  = $(PREFIX)/bin
LIBDIR  = $(PREFIX)/lib/php-install

.PHONY: install uninstall

install:
	@echo "安装 php-install 到 $(PREFIX)..."
	@mkdir -p $(LIBDIR)/lib
	@mkdir -p $(LIBDIR)/post-install
	@mkdir -p $(BINDIR)
	@cp -r lib/* $(LIBDIR)/lib/
	@cp -r post-install/* $(LIBDIR)/post-install/
	@cp php-install $(LIBDIR)/
	@chmod +x $(LIBDIR)/php-install $(LIBDIR)/post-install/*.sh
	@ln -sf $(LIBDIR)/php-install $(BINDIR)/php-install
	@echo "完成。运行: php-install --help"

uninstall:
	@echo "卸载 php-install..."
	@rm -f $(BINDIR)/php-install
	@rm -rf $(LIBDIR)
	@echo "完成。"
