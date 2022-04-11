SHELL=/bin/sh

VAD_PACKAGE_NAME=virt-prom-exporter.vad
VAD_STICKER_NAME=virt-prom-exporter-vad-sticker.xml
VAD_PACKER=$(CURDIR)/vadpacker/vadpacker.py

RELEASE_DIR=$(CURDIR)/release

all: $(VAD_PACKAGE_NAME)

$(VAD_PACKAGE_NAME): submodules release_dir
	$(VAD_PACKER) --var="VERSION=1.0" --var="ISDAV=1" --var="BASE_PATH=/DAV/VAD" -o $(RELEASE_DIR)/$(VAD_PACKAGE_NAME) $(CURDIR)/$(VAD_STICKER_NAME)

.PHONY: submodules
submodules:
	git submodule update --init

.PHONY: clean
clean:
	-rm test/virt-prom-exporter-test-db*
	-rm -rf $(RELEASE_DIR)

.PHONY: release_dir
release_dir: $(RELEASE_DIR)
$(RELEASE_DIR):
	-mkdir -p $(RELEASE_DIR)

