# 相关的硬件/OS相关的实例/教程的参考信息

## https://github.com/oscomp/ 上的一些OS参考例子

### C-based OS
  - https://github.com/oscomp/RT-Thread

### Rust-based OS
  - https://github.com/oscomp/ByteOS
  - https://github.com/oscomp/DragonOS
  - https://github.com/oscomp/asterinas
  - https://github.com/oscomp/starry-next

## 与操作系统相对无关的内核核心组件

### 硬件抽象层相关组件
- [C-based 多种HAL](https://github.com/RT-Thread/rt-thread/tree/master)：rtthread内核为参考例子
  - [RISC-V64/32](https://github.com/RT-Thread/rt-thread/tree/master/libcpu/risc-v)
  - [LoongArch64](https://freeflyingsheep.github.io/posts/rt-thread/loongarch64/)
  - [LoongArch32](https://freeflyingsheep.github.io/posts/rt-thread/loongarch32/)
  - [ARM aarch64](https://github.com/RT-Thread/rt-thread/tree/master/libcpu/aarch64)
  - [arm32](https://github.com/RT-Thread/rt-thread/tree/master/libcpu/arm)

- [Rust-based axHAL](https://github.com/oscomp/arceos/tree/main/modules/axhal) : 支持RISC-V64, LoongArch64, x86-64, ARM aarch64
  - [starry-next宏内核参考例子](https://github.com/oscomp/starry-next) ：对 2025 年 OS 比赛已经初步完成了环境适配，能够运行 riscv64 和 loongarch64 的大部分 basic 测例，并可以支持在OS内核赛道比赛平台上进行评测。
  - [可在OS比赛平台上运行的改造代码仓库](https://gitlab.eduxiji.net/Azure_stars/starry-next/-/tree/pre2025test)（相比于 github 仓库进行了一些环境配置的改变）
  - [starry-next 内核使用说明](https://azure-stars.github.io/Starry-Tutorial-Book/ch01-00.html)
  - [如何在 OS 比赛平台上测试 Starry 的说明](https://azure-stars.github.io/Starry-Tutorial-Book/ch01-00.html)
  - [starry-next所基于的arceos unikernel参考内核](https://github.com/oscomp/arceos)

- [Rust-based PolyHAL](https://github.com/Byte-OS/polyhal) 与OS无关且支持x64/aarch64/riscv64/loongarch64，以及星光二代开发板和龙芯2k1000的处理器抽象层Crates
  - [使用此库的ByteOS](https://github.com/Byte-OS/ByteOS)

### 文件系统相关组件

#### ext4文件系统参考实现
- [C-based lwext4库](https://github.com/gkostka/lwext4)
  - [这个C库的起源来自 helenOS](http://helenos.org/)
  - [修改并使用此C库的RT-Thread OS](https://packages.rt-thread.org/en/detail.html?package=lwext4)

- [封装了C-based lwext4的Rust-based ext4 Crate](https://github.com/rcore-os/lwext4_rust/tree/main)
  - [使用此库的StarryOS](https://github.com/Starry-OS/Starry)
  - [使用此库的ByteOS](https://github.com/Byte-OS/ByteOS)
- [Rust-based ext4 Crate](https://github.com/yuoo655/ext4_rs)
  - [使用此库的StarryOS](https://github.com/Starry-OS/Starry)

- [Another Rust-based ext4 Crate](https://github.com/PKTH-Jx/another_ext4)
  - [使用此库的StarryOS](https://github.com/Starry-OS/Starry)

### TCP/IP协议栈相关组件
- C based
  - [lwip](https://github.com/lwip-tcpip/lwip)
  - [CycloneTCP](https://github.com/Oryx-Embedded/CycloneTCP)

- Rust based
  - [Rust-based tcpip stack: smoltcp](https://github.com/rcore-os/smoltcp)
  - [Rust封装C-based tcpip stack:lwip](https://github.com/Centaurus99/arceos-lwip)

### 可用于QEMU的设备驱动相关组件
- [virtio drivers](https://github.com/rcore-os/virtio-drivers): Block, NIC, GPU, Input, Console ... Drivers

### 各种可用于内核开发的crates
- [Kernel crates that can be used in multiple Rust OSes](https://github.com/kern-crates)

注：比赛测试用例所在文件系统格式为Ext4， 上面提供的C和Rust的Ext4库与具体OS无关，经过适配后，可集成到各种OS中。


## RISC-V相关参考信息

### RISC-V 相关文档

- [RISC-V 硬件中文手册](https://github.com/oscomp/books/blob/main/RISC-V-Reader-Chinese-v2p12017.pdf)


### 可以在基于QEMU(RV64)上运行的开源OS：
- [asterinas kernel](https://github.com/asterinas/asterinas) Asterinas is a secure, fast, and general-purpose OS kernel, written in Rust and providing Linux-compatible ABI. Support x86_64 & RISC-V64
- [DragonOS kernel](https://github.com/DragonOS-Community/DragonOS/tree/master/kernel/src/arch) DragonOS已经实现了约1/4的Linux接口，支持x86_64 & RISC-V64
- [nommu linux 0.11](https://github.com/lizhirui/K210-Linux0.11)
- [C lang based xv6 kernel](https://github.com/SKTT1Ryze/xv6-k210)
- [Rust lang based xv6 kernel(uncompleted)](https://github.com/Jaic1/xv6-riscv-rust)
- [Rust based rcore tutorial kernel](https://github.com/wyfcyx/rCore-Tutorial/tree/multicore)
- [C lang based uCore kernel](https://github.com/NKU-EmbeddedSystem/riscv64-ucore)
- [RT-Thread/K210 with SMP](https://github.com/RT-Thread/rt-thread/tree/master/bsp/k210)
- [rCore-Tutorial-v3](https://github.com/rcore-os/rCore-Tutorial-v3)
  - [一步一步写rCore-Tutorial v3 OS Kernel的实验指导书](https://github.com/rcore-os/rCore-Tutorial-Book-v3) 

### 与OS无关的kernel components

这是部分与OS无关的kernel components，有一些不一定特别完善，供参考、引用或改进

- [PolyHAL](https://github.com/Byte-OS/polyhal) 与OS无关且支持x64/aarch64/riscv64/loongarch64，以及星光二代开发板和龙芯2k1000的处理器抽象层Crates.
- [基于C的ext4 crate](https://github.com/rcore-os/lwext4_rust)
- [基于Rust的ext4 crate](https://github.com/yuoo655/ext4_rs)
- [Rust-based tcpip stack: smoltcp](https://github.com/rcore-os/smoltcp)
- [C-based tcpip stack:lwip](https://github.com/Centaurus99/arceos-lwip)
- [virtio drivers](https://github.com/rcore-os/virtio-drivers): Block, NIC, GPU, Input, Console ... Drivers
- [e1000 NIC driver](https://github.com/rcore-os/e1000-driver)
- [Cadence Macb ethernet driver on Sifive fu740 board](https://github.com/rcore-os/cadence-macb-driver)
- [RISC-V星光二代开发板的网卡驱动](https://github.com/yuoo655/visionfive2_net_driver)
- [RISC-V星光二代开发板的SD卡驱动](https://github.com/os-module/visionfive2-sd) 
- [nvme driver](https://github.com/rcore-os/nvme_driver)
- [isomorphic_drivers](https://github.com/rcore-os/isomorphic_drivers)
- [os scheduler](https://github.com/131131yhx/arceos)
- [os memory malloc subsystem](https://github.com/rcore-os/mem_malloc_subsystem)

### 开发OS过程中形成的kernel components
- [开发宏内核 ByteOS形成的crates](https://github.com/Byte-OS/.github/blob/main/README.md)
 
### 固件（Firmware）：Bootloader/BIOS/UEFI/OpenSBI等相关
- 符合OpenSBI接口的开源固件
  - [Rust based SBI](https://github.com/luojia65/rustsbi)


## LoongArch相关参考信息

### LoongArch架构通用文档

- [龙芯架构参考手册](https://github.com/LoongsonLab/oscomp-documents/blob/main/pdf/%E9%BE%99%E8%8A%AF%E6%9E%B6%E6%9E%84%E5%8F%82%E8%80%83%E6%89%8B%E5%86%8C%E5%8D%B7%E4%B8%80.pdf)
- [《计算机体系结构基础(第三版)》](https://github.com/LoongsonLab/oscomp-documents/blob/main/pdf/%E8%AE%A1%E7%AE%97%E6%9C%BA%E4%BD%93%E7%B3%BB%E7%BB%93%E6%9E%84%E5%9F%BA%E7%A1%80(LoongArch)-3rd.pdf)
- [LoongArch 系统调用(syscall)ABI](https://github.com/LoongsonLab/oscomp-documents/blob/main/pdf/LoongArch%20%E7%B3%BB%E7%BB%9F%E8%B0%83%E7%94%A8(syscall)ABI.pdf)
- [LoongArch-工具链约定](https://github.com/LoongsonLab/oscomp-documents/blob/main/pdf/LoongArch-%E5%B7%A5%E5%85%B7%E9%93%BE%E7%BA%A6%E5%AE%9A.pdf)
- [LoongArch ELF ABI(中文版)](https://github.com/LoongsonLab/oscomp-documents/blob/main/pdf/LoongArch-ELF-ABI-CN.pdf)
- 更多龙架构相关文档，可以参考[龙芯开源社区](http://loongnix.cn)，[龙芯中科公司官网](https://loongson.cn/)，[龙芯在github的官方账号](https://github.com/loongson)以及[龙芯实验室为大赛设置的文档仓库](https://github.com/LoongsonLab/oscomp-documents)


### LoongArch上可以运行的参考OS
- [Starry OS](https://github.com/LoongsonLab/StarryOS-LoongArch.git)。StarryOS LoongArch版会持续更新。
- [uCore](https://github.com/cyyself/ucore-loongarch32).  [实验指导书](https://cyyself.github.io/ucore_la32_docs)
- [rCore](https://github.com/Godones/rCoreloongArch). 2022年全国大学生操作系统大赛-功能挑战赛二等奖。
- [MaQueOS](https://gitee.com/dslab-lzu/maqueos). 本项目是用于兰州大学的教学操作系统，兰州大学相关团队为其编写了教材《MaQueOS：基于龙芯LoongArch架构的教学版操作系统》。
- [Yocto](https://www.yoctoproject.org/). Yocto是用于定制嵌入式Linux系统的主流工具之一，它已经支持LoongArch.
- [seL4](https://github.com/tyyteam/la-seL4). 2022年全国大学生操作系统大赛-功能挑战赛一等奖。
- [NuttX](https://github.com/LA-NuttX). NuttX是完全兼容Posix和ANSI标准的嵌入式实时系统，有着轻量级、定制化的特点，已被广泛应用在成熟的商业系统或软件中，如小米Vela系统、三星Tizen RT系统、px4飞行控制软件。

###  LoongArch上可以运行的内核模块
- [与OS无关且支持x64/aarch64/riscv64/loongarch64，以及星光二代开发板和龙芯2k1000的处理器抽象层Crates: PolyHAL](https://github.com/Byte-OS/polyhal)
