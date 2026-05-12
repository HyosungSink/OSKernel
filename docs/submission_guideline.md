# 提交说明

本次大赛允许使用 C/C++ 或 Rust 语言开发操作系统内核。

## 1. 提交要求

- 项目根目录必须包含 `Makefile`。
- 评测时会自动执行 `make all`。
- `Makefile` 中的 `all` 目标应完成以下内容：
  - 编译操作系统内核
  - 生成 ELF 格式的 `kernel-rv` 和 `kernel-la` 两个文件，这两个文件作为评测时的内核镜像。
- 如系统需要辅助文件（例如 `rootfs`），可在编译时生成 `disk.img`。
- `disk.img` 会在 QEMU 运行时挂载。`disk.img` 为可选项，不强制要求提交。

## 2. 测评方式

### 2.1 测评环境

- 初赛阶段评测使用 QEMU 虚拟环境。
- QEMU 启动时会使用 `-drive file=...` 参数挂载磁盘镜像。
- 该磁盘镜像为 EXT4 文件系统，且没有分区表。

### 2.2 测试点要求

- 磁盘镜像根目录中包含若干预先编译好的 ELF 可执行文件和测试脚本。
- 测试脚本命名格式为：`xxxxx_testcode.sh`。
- 您的操作系统启动后需要：
  1. 扫描磁盘镜像根目录
  2. 依次运行每一个测试点
  3. 将运行结果输出到屏幕
- 评测系统根据屏幕输出内容进行评分。

### 2.3 可选执行与输出格式

- 可以根据系统完成度选择跳过部分测试点。
- 未运行的测试点将不计分。
- 如果不通过脚本自动运行测试点，仍需按脚本格式输出测试前后提示信息，例如：`#### OS COMP TEST GROUP START basic ####`，否则可能影响评分结果。

### 2.4 执行规则

- 测试点顺序与评分无关。
- 测试点只能串行运行，不能同时并行执行多个测试点。
### 2.5 运行结束处理

- 当操作系统执行完所有测试点后，需主动调用关机命令。
- 评测机会在检测到 QEMU 进程退出或达到最长限制时间后进行打分。

## 3. QEMU 启动命令

### 3.1 RISC-V QEMU 命令

以下命令为完整示例：

```bash
qemu-system-riscv64 -machine virt -kernel {os_file} -m {mem} -nographic -smp {smp} -bios default \
                    -drive file={fs},if=none,format=raw,id=x0 \
                    -device virtio-blk-device,drive=x0,bus=virtio-mmio-bus.0 \
                    -no-reboot -device virtio-net-device,netdev=net -netdev user,id=net \
                    -rtc base=utc \
                    -drive file=disk.img,if=none,format=raw,id=x1 -device virtio-blk-device,drive=x1,bus=virtio-mmio-bus.1
```

参数说明：

- `{os_file}`：生成的 `kernel-rv` 文件
- `{fs}`：包含测试点的磁盘镜像
- `disk.img`：可选的辅助磁盘镜像，如果未生成该文件，则启动命令中不包含它

### 3.2 LoongArch QEMU 命令

以下命令为完整示例：

```bash
qemu-system-loongarch64 -kernel {os_file} -m {mem} -nographic -smp {smp} \
                        -drive file={fs},if=none,format=raw,id=x0 \
                        -device virtio-blk-pci,drive=x0,bus=virtio-mmio-bus.0 -no-reboot \
                        -device virtio-net-pci,netdev=net0 \
                        -netdev user,id=net0,hostfwd=tcp::5555-:5555,hostfwd=udp::5555-:5555 \
                        -rtc base=utc \
                        -drive file=disk-la.img,if=none,format=raw,id=x1 -device virtio-blk-pci,drive=x1,bus=virtio-mmio-bus.1
```

### 3.3 QEMU 版本示例

```bash
root@f8eccecd6f32:/# qemu-system-riscv64 --version
QEMU emulator version 9.2.1
Copyright (c) 2003-2024 Fabrice Bellard and the QEMU Project developers
root@f8eccecd6f32:/# qemu-system-loongarch64 --version
QEMU emulator version 9.2.1
Copyright (c) 2003-2024 Fabrice Bellard and the QEMU Project developers
```

## 4. 第三方依赖与隐藏文件

- 如果项目需要引用第三方工具或库，请提交源码并与内核一同编译。
- 不要直接提交二进制依赖文件。
- 评测系统在 clone 项目时会过滤掉所有隐藏文件和隐藏目录。
- 如果构建依赖隐藏目录，例如 `.cargo`，可以在提交时使用其他目录名，并在 `Makefile` 中重命名为 `.cargo`。

## 5. 评测超时可能原因

出现“评测时间过长”提示的可能原因包括：

1. 未将所需第三方包提交到项目中，导致编译时在线下载依赖耗时过长。
2. 系统运行结束后没有及时关闭 QEMU。
3. 提交代码存在 BUG，导致运行速度过慢。

## 6. 评测环境说明

- Dockerfile 和相关工具链：
  - https://github.com/zhouzhouyi-hub/os-contest-image/
- 镜像下载命令：
  - `docker pull zhouzhouyi/os-contest:20260104`

## 7. 测试用例与说明

- 测试用例下载地址：
  - https://github.com/oscomp/testsuits-for-oskernel/blob/pre-2025/
