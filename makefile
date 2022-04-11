SHELL=/bin/sh

GIT=git
GIT_SUBMODULES=$(shell sed -nE 's/path = +(.+)/\1\/.git/ p' .gitmodules | paste -s -)

VAD_PACKAGE_NAME=virt-prom-exporter.vad
VAD_STICKER_NAME=virt-prom-exporter-vad-sticker.xml
VAD_PACKER=$(CURDIR)/vadpacker/vadpacker.py

RELEASE_DIR=$(CURDIR)/release

all: $(VAD_PACKAGE)

$(VAD_PACKAGE): submodules release_dir
	$(VAD_PACKER) --var="VERSION=1.0" --var="ISDAV=1" --var="BASE_PATH=/DAV/VAD" -o $(RELEASE_DIR)/$(VAD_PACKAGE_name) $(CURDIR)/$(VAD_STICKER_NAME)

.PHONY: submodules

submodules: $(GIT_SUBMODULES)

$(GIT_SUBMODULES): %/.git: .gitmodules
	$(GIT) submodule init
	$(GIT) submodule update $*
	@touch $@

.PHONY: clean

clean:
	-rm test/virt-prom-exporter-test-db*
	-rm -rf $(RELEASE_DIR)

.PHONY: release_dir

release_dir: $(RELEASE_DIR)

$(RELEASE_DIR):
	-mkdir $(RELEASE_DIR)

