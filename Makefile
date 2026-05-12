JOBS ?= 8
TESTSUITS_JOBS ?= $(JOBS)
RT_TESTS_JOBS ?= 1
COMPRESS_JOBS ?= $(JOBS)
PACK_JOBS ?= 2
export CARGO_BUILD_JOBS ?= $(JOBS)

STARRY_DIR := $(CURDIR)/starry-next
TESTSUITS_DIR := $(CURDIR)/testsuits-for-oskernel
STARRY_BIN_RV := $(STARRY_DIR)/starry-next_riscv64-qemu-virt.bin
STARRY_ELF_LA := $(STARRY_DIR)/starry-next_loongarch64-qemu-virt.elf

.PHONY: all starry_cargo_config loongarch_musl_alias build-rv build-la sdcard sdcard-pack testdata testdata-config clean FORCE

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
	$(MAKE) -C $(TESTSUITS_DIR) NPROC=$(TESTSUITS_JOBS) RT_TESTS_JOBS=$(RT_TESTS_JOBS) XZ_THREADS=$(COMPRESS_JOBS) GZIP_THREADS=$(COMPRESS_JOBS) PACK_JOBS=$(PACK_JOBS)

sdcard-pack:
	ln -sfn $(TESTSUITS_DIR) /code
	$(MAKE) -C $(TESTSUITS_DIR) pack-sdcard NPROC=$(TESTSUITS_JOBS) RT_TESTS_JOBS=$(RT_TESTS_JOBS) XZ_THREADS=$(COMPRESS_JOBS) GZIP_THREADS=$(COMPRESS_JOBS) PACK_JOBS=$(PACK_JOBS)

testdata: testdata-config
	$(MAKE) -j $(PACK_JOBS) testdata/sdcard-rv.img.gz testdata/sdcard-la.img.gz

testdata-config:
	mkdir -p testdata
	cp autotest-for-oskernel/kernel/judge/judge_*.py testdata/
	cp autotest-for-oskernel/kernel/judge/config.json testdata/
	python3 -c 'import json; from pathlib import Path; p=Path("testdata/config.json"); cfg=json.loads(p.read_text()); cfg["qemu.timeout"]=60; cfg["qemu.no_output_timeout"]=60; p.write_text(json.dumps(cfg, indent=4)+"\n")'

testdata/sdcard-rv.img.gz: FORCE
	@if [ -f "$(TESTSUITS_DIR)/sdcard-rv.img.gz" ]; then \
		cp "$(TESTSUITS_DIR)/sdcard-rv.img.gz" testdata/sdcard-rv.img.gz; \
	elif [ -f sdcard-rv.img ]; then \
		if command -v pigz >/dev/null 2>&1; then pigz -1 -p $(COMPRESS_JOBS) -c sdcard-rv.img > testdata/sdcard-rv.img.gz; \
		else gzip -1 -c sdcard-rv.img > testdata/sdcard-rv.img.gz; fi; \
	else \
		echo "missing sdcard-rv image: run make sdcard or provide sdcard-rv.img"; exit 1; \
	fi

testdata/sdcard-la.img.gz: FORCE
	@if [ -f "$(TESTSUITS_DIR)/sdcard-la.img.gz" ]; then \
		cp "$(TESTSUITS_DIR)/sdcard-la.img.gz" testdata/sdcard-la.img.gz; \
	elif [ -f sdcard-la.img ]; then \
		if command -v pigz >/dev/null 2>&1; then pigz -1 -p $(COMPRESS_JOBS) -c sdcard-la.img > testdata/sdcard-la.img.gz; \
		else gzip -1 -c sdcard-la.img > testdata/sdcard-la.img.gz; fi; \
	else \
		echo "missing sdcard-la image: run make sdcard or provide sdcard-la.img"; exit 1; \
	fi

clean:
	-$(MAKE) -C $(STARRY_DIR) PWD=$(STARRY_DIR) clean
	rm -f kernel-rv kernel-la disk.img disk-la.img
