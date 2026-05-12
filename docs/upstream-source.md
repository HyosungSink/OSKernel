# Upstream Source Notes

This project uses StarryOS / starry-next as a Git submodule:

- Repository: https://gitlab.eduxiji.net/Azure_stars/starry-next.git
- Branch: `pre2025test`
- Imported commit: `adc11f5`
- Submodule path: `starry-next`
- Initial setup date: 2026-05-12

The imported code is derived from StarryOS, a monolithic kernel based on ArceOS. The upstream tree already contains ArceOS and vendored dependencies used by the competition adaptation.

Local changes made during the initial PoC:

- The repository root provides the contest-facing `Makefile`.
- The root `Makefile` delegates builds to `starry-next` and copies the RISC-V raw binary and LoongArch ELF outputs to `kernel-rv` and `kernel-la`.
- The root `Makefile` creates the LoongArch musl `cc` alias from the toolchain found in `PATH`, matching the current `zhouzhouyi/os-contest:20260104` container layout.
- The root `Makefile` regenerates `starry-next/.cargo/config.toml` from `cargo-config/starry-next.config.toml`, because the contest clone process filters hidden directories.
