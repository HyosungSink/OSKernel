JOBS ?= 16
TESTSUITS_JOBS ?= $(JOBS)
export CARGO_BUILD_JOBS ?= $(JOBS)

STARRY_DIR := $(CURDIR)/starry-next
TESTSUITS_DIR := $(CURDIR)/testsuits-for-oskernel
STARRY_BIN_RV := $(STARRY_DIR)/starry-next_riscv64-qemu-virt.bin
STARRY_ELF_LA := $(STARRY_DIR)/starry-next_loongarch64-qemu-virt.elf

.PHONY: all starry_cargo_config loongarch_musl_alias build-rv build-la sdcard clean

all: build-rv build-la

starry_cargo_config:
	@mkdir -p $(STARRY_DIR)/.cargo
	@sed 's|@STARRY_ROOT@|$(STARRY_DIR)|g' cargo-config/starry-next.config.toml > $(STARRY_DIR)/.cargo/config.toml

loongarch_musl_alias:
	@if ! command -v loongarch64-linux-musl-cc >/dev/null 2>&1; then \
		gcc_path="$$(command -v loongarch64-linux-musl-gcc)"; \
		if [ -n "$$gcc_path" ]; then \
			echo "loongarch64-linux-musl-cc not found, creating symbolic link beside $$gcc_path"; \
			ln -sf "$$(basename "$$gcc_path")" "$$(dirname "$$gcc_path")/loongarch64-linux-musl-cc"; \
		else \
			echo "loongarch64-linux-musl-gcc not found in PATH"; \
			exit 1; \
		fi; \
	fi

build-rv: starry_cargo_config
	$(MAKE) -j$(JOBS) -C $(STARRY_DIR) PWD=$(STARRY_DIR) test_build ARCH=riscv64 AX_TESTCASE=oscomp BUS=mmio FEATURES=lwext4_rs
	cp $(STARRY_BIN_RV) kernel-rv
	rm -f $(STARRY_DIR)/kernel-rv

build-la: starry_cargo_config loongarch_musl_alias
	$(MAKE) -j$(JOBS) -C $(STARRY_DIR) PWD=$(STARRY_DIR) test_build ARCH=loongarch64 AX_TESTCASE=oscomp FEATURES=lwext4_rs
	cp $(STARRY_ELF_LA) kernel-la
	rm -f $(STARRY_DIR)/kernel-la

sdcard:
	ln -sfn $(TESTSUITS_DIR) /code
	ln -sfn /opt/riscv64-lp64d--musl--bleeding-edge-2024.02-1 /opt/riscv64--musl--bleeding-edge-2020.08-1
	$(MAKE) -C $(TESTSUITS_DIR) NPROC=$(TESTSUITS_JOBS)

clean:
	-$(MAKE) -C $(STARRY_DIR) PWD=$(STARRY_DIR) clean
	rm -f kernel-rv kernel-la disk.img disk-la.img
