# Repository Guidelines

## Project Structure & Module Organization
- `kernel/starry-next/`: main kernel tree. Syscalls are under `src/syscall_imp/`; loader and runtime boot logic live in `src/mm.rs` and `src/main.rs`; ArceOS modules are under `arceos/`.
- `tools/`: build and regression entrypoints, especially `run_full_local_suite.py`.
- `dev/full-suite/`: local reports, staged rootfs trees, and raw logs used for official-style validation.
- `testsuits-for-oskernel-pre-2025/`: upstream workloads such as LTP, rt-tests, busybox, libc-test, and lmbench.
- `docs/`: competition rules, local suite notes, and current problem statements.

## Goals & Prioritization
1. Short-term goal: First solve all shard-restart points or >3 minute blocking points that prevent later LTP coverage from being reached or scored correctly. 
2. Medium-term goal: After the current blocker families stop causing restarts/collapse, reduce whole-arch LTP runtime so that a dedicated local LTP run for one architecture finishes within 12 minutes without hanging at a fixed point; optimize the currently slow cross-arch groups first and similar heartbeat-heavy points.
3. Long-term goal: While preserving the LTP gains above, keep non-LTP behavior stable and correct, ensure single non-LTP cases stay within 90 seconds, keep a full `--skip-ltp` architecture run within 10 minutes, and validate important fixes again with online-style single-boot reproduction when the issue depends on accumulated state.

## Problem Statement & Current Blockers

- Latest local checked artifacts are `logs/local_score.txt`, `logs/local_Riscv输出.txt`, and `logs/local_LoongArch输出.txt`. Current local dedicated-LTP scores are `glibc-la 768/1231` and `glibc-rv 761/1230`. `logs/local_score.txt` also shows restart pressure is still high: RV restarted on 9/10 shards, LA on 6/10 shards, so local scoring is still being limited by restart-driven coverage loss rather than only ordinary testcase failures.

- Local shard-restart / hang / crash points:
  - RV: `copy_file_range02`, `statx04`, `fork13`, `timerfd_settime02`, `copy_file_range01`, `futex_wait05`, `msgstress01`, `futex_cmp_requeue01`, and `copy_file_range03` trigger worker kill + shard restart; `statx03` also finishes and then the worker stalls before switching. The clearest shared family is the fs-copy / metadata path: before the `copy_file_range*` restarts, `tst_fill_fs.c` reports `fsync(4) failed: EIO`, and later `statx03/04` also become restart points, so the ext-image / writeback / metadata state is likely being corrupted and then poisoning later VFS queries. The other family is scheduler / process-lifecycle stress: `fork13`, `timerfd_settime02`, `msgstress01`, and futex requeue/wait points all die after entering the testcase, which points to wakeup, timer, or wait-queue teardown stalls rather than simple wrong return codes.
  - LA: `readlink03`, `ptrace05`, `fork13`, `copy_file_range01`, `readlink01`, and `poll02` trigger restarts; the terminal bad crash is `statvfs01`, which panics in `axfs_vfs::structs` after `statfs02` already returned the wrong errno. LA restart points cluster into two families: pathname / dentry handling (`readlink03`, `readlink01`, `statfs02`, `statvfs01`) and task-state teardown (`ptrace05`, `fork13`, `poll02`). `readv01` also finishes and then the worker stalls before the next case, which again suggests cleanup-state leakage after testcase exit.

- Local slow points over 2 minutes:
  - Confirmed by heartbeat count, only `timerfd_settime02` on LA exceeds 2 minutes in the latest run (`5` heartbeats, i.e. >120s). This still looks timer-runtime-driven rather than pure shell overhead, because the worker stays alive inside the testcase instead of dying immediately.
  - RV has no confirmed `>=4`-heartbeat point in this latest run, but `fork13` (`3` heartbeats), `msgstress01` (`2`), `epoll01` (`2`), and `select02` (`2`) remain near-threshold and several of them restart before they can finish cleanly, so they are still practical slow/blocking families.

- Local bad points that spoil later coverage:
  - RV `copy_file_range*` is currently the most damaging family: the preceding `fsync ... EIO` shows a real fs/writeback fault, and the same shard later loses `statx03/04`, so this is not an isolated testcase mismatch.
  - Cross-arch mount/path cleanup remains dirty: repeated `pivot_root01` `EBUSY` and `rmdir02` `EACCES`/`EBUSY` evidence show mount or path state is not being cleaned, which can contaminate later fs/path cases.
  - LA `readlink03` already shows systematic errno confusion (`EINVAL/ENOENT/ENOTDIR/ELOOP` mismatches), and the later `statfs02 -> statvfs01` panic confirms this VFS pathname / dentry bug can escalate from wrong results into a shard-killing crash.

## Development Principles & Testing Guidelines

- Principles of development
  - All fixes must be real kernel or runtime functionality fixes.
  - Try to do kernel optimizations at the ArceOS or starry-next level instead of surface optimizations specific to tests.
  - Do not add script-side special-casing for individual tests.
  - Do not fake outputs, suppress failures, or implement false-success behavior.
  - Treat `tools/run_full_local_suite.py` as the source of truth for local evaluation behavior; docs may lag behind code.
  - Keep LTP target-validation aligned with online behavior: use `LTP_RUNTIME_MUL=1`, keep pure dedicated `ltp-*` defaults at `DEDICATED_LTP_RUNTIME_MUL=1.0`, and treat any `--ltp-runtime-mul < 1` run as debug-only rather than proof that a blocker or runtime goal is fixed.
  - Treat `tools/run_full_local_suite.py` cache/wrapper/rootfs-refresh fixes as local reproduction infrastructure fixes unless proven otherwise. They may improve local fidelity, but they do not count toward online kernel/runtime goals by themselves.

- Canonical local runner
  - Main entrypoint: `python3 tools/run_full_local_suite.py`.
  - Default report path is `dev/full-suite/score.txt`; each run is also synchronized to `logs/local_score.txt`, `logs/local_Riscv输出.txt`, and `logs/local_LoongArch输出.txt`.
  - `--subset` selects exact samples from the hard-coded sample list; `--skip-ltp` removes all four `ltp-*` samples from the selected set.
  - `--ltp-case` and `--ltp-start-case` are only for LTP and cannot be combined with each other or with `--skip-ltp`.
  - `--quick-point-retest` is the preferred fast debug mode for single-point repair: it rebuilds only the needed kernel(s), reuses cached rootfs/base images, and reuses shared official rootfs state when possible.
  - `--rebuild-rootfs` forces rootfs rebuild; use it only when runtime files/rootfs contents may be stale.
  - `--resume-log <path>` appends a transcript and skips samples already completed in that transcript.
  - Do not use periodic runtime-weight refresh in routine development runs; keep the existing shard weights and rely on the current run's printed single-boot estimate for time evaluation.

- Actual watchdog and timeout behavior
  - Default `--timeout` is `3600s`, but pure official LTP-only arch runs do not use this per-arch timeout; they instead rely on log-progress watchdogs and test/competition behavior.
  - Normal log silence is treated as a stall after `90s`; sharded LTP workers use a stricter `60s` silent-idle timeout.
  - If a fatal pattern such as panic/Oops/watchdog timeout appears, the runner kills the process after `15s` of no further log progress.
  - LTP heartbeat lines are emitted every `30s`; in raw local logs, `>=4` heartbeats means the case exceeded 2 minutes.
  - In sharded LTP mode, a stalled case is marked failed and the shard is restarted from the next remaining case; this is useful for coverage and blocker isolation, but it is not the same as a one-shot official online boot.

- Local time budgets and pass criteria
  - Single LTP case / aggregation-point debug run: target `< 2 min`; treat `> 2 min` as a slow-point warning and `> 3 min` as a blocker that must be optimized or fixed.
  - Local raw-log heuristic: `4` heartbeats (`~120s`) means “too slow”; `6` heartbeats (`~180s`) means “beyond short-term budget”.
  - Whole dedicated LTP run for one architecture, such as `--subset ltp-glibc-rv` or `--subset ltp-glibc-la`: target `< 20 min` and no fixed-point hang/restart spiral.
  - Single non-LTP sample: target `< 150s`.
  - Full one-architecture non-LTP regression run, such as an architecture-specific `--skip-ltp` check: target `< 10 min`.

- Goal-oriented validation
  - Short-term goal validation: after each blocker fix, run only the repaired LTP point with `python3 tools/run_full_local_suite.py --subset ltp-glibc-rv --ltp-case <case> --quick-point-retest` (replace variant as needed). Use this stage to eliminate shard restart points, collapse points, and `>3 min` blockers first.
  - Short-term exit condition: the repaired point no longer stalls/restarts, and its runtime is pulled below the `3 min` blocker line.
  - Short-term regression guard: if a short-term fix makes the target point pass but causes additional failures in nearby points, in the same blocker family, or in previously stable non-LTP behavior, do not count the short-term goal as achieved yet. Before widening scope, re-run the nearest affected LTP points and then run one `python3 tools/run_full_local_suite.py --skip-ltp --timeout 600` regression check if the touched code is shared kernel/runtime infrastructure.
  - Medium-term goal validation: once the current blocker family is stable, keep optimizing the slowest LTP groups with single-point retests first; only when the slow families look healthy run one dedicated whole-arch LTP check such as `python3 tools/run_full_local_suite.py --subset ltp-glibc-rv --ltp-runtime-mul 1` or `--subset ltp-glibc-la --ltp-runtime-mul 1`.
  - Medium-term exit condition: the whole local LTP run for one architecture finishes within `20 min` without getting trapped at a fixed point.
  - Online-related blocker revalidation: for blockers that are intended to match online behavior, re-run them with `--ltp-runtime-mul 1`, `--ltp-shards 1`, and `--online-repro` (or an equivalent single-boot flow) before claiming the blocker family is fixed.
  - Long-term goal validation: after medium-term LTP goals hold, run `python3 tools/run_full_local_suite.py --skip-ltp` to protect non-LTP behavior, then use `--online-repro` for fixes that depend on single-boot accumulation, ordering, or memory pressure.
  - Long-term exit condition: non-LTP behavior remains correct, single non-LTP samples stay within `150s`, and a full non-LTP architecture run stays within `10 min`.

- Recommended test modes
  - Single LTP point repair: `python3 tools/run_full_local_suite.py --subset ltp-glibc-rv --ltp-case <case> --quick-point-retest --timeout 180` (replace variant as needed). Pass criterion: no stall/restart and runtime `< 180s`; preferred target is `< 120s`.
  - Daily sharded LTP fast run: `timeout 1200s python3 tools/run_full_local_suite.py --subset ltp-glibc-rv --ltp-runtime-mul 1 --ltp-shards 10` (replace variant as needed). Pass criterion: use the printed `parallel=` time only as development efficiency, and use the printed `single-boot≈` estimate to judge online-equivalent total runtime.
  - Full local LTP coverage/runtime check for one arch: `timeout 1200s python3 tools/run_full_local_suite.py --subset ltp-glibc-rv` or `timeout 1200s python3 tools/run_full_local_suite.py --subset ltp-glibc-la`. Pass criterion: the run finishes within `20 min` and does not get trapped at a fixed restart/hang point. Because pure dedicated `ltp-*` runs do not use the runner's per-arch `--timeout`, use host-side `timeout 1200s` when you want to enforce the 20-minute budget strictly.
  - Non-LTP regression preservation: `python3 tools/run_full_local_suite.py --skip-ltp --timeout 600`. Pass criterion: one full non-LTP architecture flow stays within `10 min`, and single non-LTP samples should stay within `150s`.
  - Online-style reproduction: add `--online-repro` to the relevant command to disable later-group retry and keep the single-boot official execution flow. Use this before claiming fixes for accumulation-sensitive issues such as memory pressure, ordering, or late-group collapse.

- Regression handling and rollback
  - Before widening test scope, compare the new run against the last known-good `logs/local_score.txt`, `logs/local_Riscv输出.txt`, and `logs/local_LoongArch输出.txt`.
  - If a short-term change fixes the original blocker but introduces extra failures elsewhere, treat that as an incomplete or bad fix rather than a success. The required response is: stop widening the test scope, identify the smallest changed subsystem that could explain the new failures, and either revert the whole change or split it until the original blocker improvement can be kept without the new regressions.
  - If a short-term retest fixes one point but introduces new shard restarts, new fatal stalls, or obvious score/runtime regressions in nearby points, roll back that change before moving to broader tests.
  - If the extra failures appear in non-LTP samples after an LTP-oriented fix, prioritize rollback unless the change is immediately necessary and the regression has an obvious, tightly scoped follow-up fix. Do not leave the tree in a state where the short-term LTP gain depends on new non-LTP breakage.
  - If a medium-term optimization makes the full LTP run slower, introduces new restart cascades, or breaks a previously fixed blocker family, revert or split the patch and re-test the smaller change.
  - If a long-term/non-LTP validation adds errors that were not present before the LTP fix, treat that as collateral damage and roll back to the last stable state.
  - Prefer small, reviewable commits or patch chunks while iterating, so rollback is surgical; do not stack multiple speculative kernel changes before validating the current goal.

- Git-based iteration discipline
  - Goals are usually reached incrementally, not in one patch; use Git proactively so partially trusted progress is preserved and bad experiments are easy to discard.
  - Before starting a risky change, check `git status`, inspect the active diff, and make sure the workspace baseline is understood.
  - Once a small change is locally validated and believed to be trustworthy, commit it promptly with a narrow scope instead of continuing to stack unrelated edits on top of it.
  - Prefer one commit per logical repair step, for example: one commit for an RV fs-path fix, one commit for an LA fork/exec fix, one commit for a pure cleanup or follow-up adjustment.
  - Do not mix speculative experiments, refactors, and validated fixes in the same commit.
  - If a later experiment regresses behavior, first try to roll back only the newest untrusted commit or patch chunk, keeping earlier trusted commits intact.
  - When debugging a blocker family over multiple rounds, use `git log --oneline`, `git diff`, and `git show` to compare the current state against the last known-good tested commit.
  - If needed, create a temporary checkpoint commit before a larger experiment, then amend, drop, or revert it after the result becomes clear.
  - The practical rule is: validated progress should become a commit; unvalidated speculation should stay easy to throw away.

- Regular inspection
  - Clean `dev/full-suite` and related caches regularly, but do not delete rootfs/base-image caches blindly during active debugging.
  - Check for leftover QEMU/test processes before rerunning; the runner normally kills its own process groups, but interrupted sessions can leave stragglers.
