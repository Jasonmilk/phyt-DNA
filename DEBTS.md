# DEBTS · phyt-DNA（本仓自足）

> **为什么本仓要有一本**：此前所有"登记"都写进了 `helix-mind/docs/helixECO/DEBTS.md`（生态总账）。
> 但**未完成的活住在本仓里**时，接班人读本仓就该看到 ⇒ 本文件**自足**（不依赖别的仓）。
> **跨仓条目**：`仓=` 列显式写出（`phyt-DNA` / `helix-mind` / `…`），**同步机制 = 每条的 `revisit-on`**：
> 到期时两本账的同一 id 必须一致（不一致 ⇒ 两本都红）。

**格式硬线（机检）**：每条必须有 `id` · `仓=` · `状态` · `revisit-on` · `恢复命令`。缺一 ⇒ 本条**不成立**（不是"宽松登记"）。

| id | 仓= | 类别 | 登记日 | 状态 | revisit-on | 内容 · **恢复命令** |
|---|---|---|---|---|---|---|
| `d-phyt-p04-selfproof` | phyt-DNA | 未证清单 | 2026-10-13 | ⬜ 待做 | 2026-10-20 | **README 用仓内命令自证四判据**（未做）· 恢复命令：在 README 加一段可粘贴的四判据自证块（`bash tools/validate.sh --timing post` ×4 输入），并实测贴出输出 |
| `d-phyt-p04-gverifiable` | phyt-DNA | 未证清单 | 2026-10-13 | ⬜ 待做 | 2026-10-20 | **G 的恢复命令改得更可验**（未做）· 恢复命令：把"三件套"恢复命令写成**带期望输出**的一行（`grep 核心钩子` 应有 1 行 · `git ls-files \| grep -c '"'` 应为 0 · `git ls-remote --symref origin HEAD` 应有 `refs/heads/v2`） |
| `d-phyt-adopter-pack` | phyt-DNA | 环境依赖 | 2026-10-13 | ⬜ 待做 | 2026-10-27 | **采用者启用包三件套**：① `core.hooksPath` 未启用 ⇒ 钩子不存在（ci-local 已具名提示）② `refs/remotes/origin/HEAD` 不存在 ⇒ 真值源靠 `git ls-remote --symref` ③ `core.quotePath` ⇒ 脚本已显式 `-c core.quotePath=false`。**恢复命令**：新克隆 `bash tools/ci-local.sh --fast \| grep 核心钩子` 应打印 |
| `d-phyt-first-match` | phyt-DNA | 引擎定性 | 2026-10-13 | ⬜ 待做 | 2026-10-20 | **"每门只取首个匹配路径"定性**：现读为**设计限制**（为 K34 单文件 payload 所写）⇒ 决定"批量能否用"。恢复命令：读 `tools/validate.sh` scan 段 + 用"≥2 文件违规"样本比**命中门数** |
| `d-phyt-diff-unlocated` | phyt-DNA | 待定位 | 2026-10-13 | ⬜ 待做 | 2026-10-20 | **批量 vs 逐文件：差异未定位 ⇒ 不采用**（不是"不等价" —— 那句是**把观察当证据**）。恢复命令：逐文件总量求和 vs 批量 `scanned`，定位差在哪一段 |
| `d-phyt-probe-touched` | phyt-DNA | 待做 | 2026-10-13 | ⬛ blocked-by: 引擎契约 | 2026-10-27 | **`--probe-touched`** · **落地验收须含**：批量的**命中门数 = 逐文件版**（否则只是"看起来更快"） |
| `d-phyt-census` | phyt-DNA | 同族普查 | 2026-10-13 | ⬜ 待做 | 2026-10-20 | **一次提交内每工具调用次数表**（钩子 / ci-local / CI 三处）⇒ >1 且非分阶段者列降本候选。恢复命令：统计 `spec-lint` / `validate.sh` / `check-baseline.sh` / `upstream-manifest.sh` / `hook_test.sh` |
| `d-phyt-hint-negative` | phyt-DNA | 未证 | 2026-10-13 | ⬜ 待做 | 2026-10-20 | **⑪① 的负样本**：已启用 ⇒ **不提示**（正样本已证：克隆里真打印）。恢复命令：真仓跑 `bash tools/ci-local.sh --fast 2>&1 \| grep -c 核心钩子` ⇒ 应为 **0** |
| `d-phyt-one-layer` | phyt-DNA | 待裁定 | 2026-10-13 | ⬜ 待做 | 2026-10-27 | **"退回一层"待裁定**（当前差 ≈8s ⇒ 不划算）。恢复命令：先修 step 4 或保持逐文件，再测真实差，由园丁裁定 |
| `d-phyt-phantom-red` | phyt-DNA | 账目一致性 | 2026-10-13 | ⬜ 待做 | 2026-10-20 | **幽灵红**：`check did not run` 此前被记成 `block` ⇒ 应记 **rc=4（不可量）**；+ 修探针夹具（复制判据引用的**所有**受管文件）；+ 历史账**追加 correction**（append-only） |
| `d-phyt-protocol-gate` | phyt-DNA | 新门 | 2026-10-13 | ⬜ 待做 | 2026-10-20 | **新门 `protocol-named-files-must-exist`**：协议里点名的文件必须存在（含"从未存在"形态）。恢复命令：见对应的 ADR（含自守：能检查自己是否被登记） |
| `d-phyt-cold-start` | phyt-DNA | 演习 | 2026-10-13 | ⬜ 待做 | 2026-10-20 | **冷启动分身演习（只读）**——P0 全绿后做一次，与本次读数对照（此后应无 DEBTS 缺失 · 钩子已接） |

## 已结清（保留在案，供对照）

| id | 仓= | 结清日 | 结论 |
|---|---|---|---|
| `d-phyt-phantom-reduction` | phyt-DNA | 2026-10-13 | **幽灵降本**（85s→1s 实为引擎空转）⇒ 双因已修（`core.quotePath` + 静默 `pass`）；批量**不采用**；见 `GROWTH.md` |
| `d-phyt-rc-contract` | phyt-DNA | 2026-10-13 | **rc 契约**落 `ADR-20261011-failure-must-be-named-where-machines-can-read`（0/2/4/其他）+ step 4 四码区分 + ADR↔引擎 机器判据 |
| `d-phyt-probe-fixture` | phyt-DNA | 未做 | 2026-10-13 | ⬜ 待做 | 2026-10-20 | **探针夹具只复制 `$F` 一个文件** ⇒ 判据体若读同目录的别的受管文件（如 `decisions/INDEX.md`）就会"跑不起来"⇒ 记 `unmeasurable`。**恢复命令**：改探针的临时目录为**同形目录**（复制判据引用的所有受管文件），再用一个"读同目录文件"的判据体验证它不再 unmeasurable | Pi |
| `d-phyt-matrix` | phyt-DNA | 未做 | 2026-10-13 | ⬜ 待做 | 2026-10-20 | **rc 四码 × 四调用方矩阵"落在 ADR 里"**（现在只在对话/提交信息里）。**恢复命令**：把矩阵表补进 `ADR-20261011-failure-must-be-named-where-machines-can-read` 的 rc 契约段（含：`DNA.md` 是 **pre** 时段的 rc=2 数据样本这一口径） | Pi |
| `d-phyt-matrix-impl` | phyt-DNA | 未做 | 2026-10-13 | ⬜ 待做 | 2026-10-20 | **把 rc 矩阵落成一条正经门（supersede 冻结体）**：本轮试过，连出三红（新条 spec-lint ×2 + 冻结体重基线反了）⇒ **按止损撤回**。恢复命令：立 `hard: true` 门 + 齐套元数据（三要素须用真 task 行/真 sha）+ 自检判据体 + 夹具；**且在动 `ADR-20261011` 前先跑 `tools/frozen-body.sh --write` 重基线** | Pi |
| `d-phyt-timing-semantics` | phyt-DNA | 未做/分析 | 2026-10-13 | ⬜ 待做 | 2026-10-20 | **不同时段的门：入参语义不同（本轮重大发现）** —— `pre` 门吃的是**工具调用**（`file_path`/`command`），`post` 门吃的是**文件内容**。实测：把 step 4 的 `--timing post` 去掉（想覆盖 pre-only 门）⇒ **一次冤红 7+ 个文件**（`DNA.md`/`VISION.md`/各 ADR）⇒ 按文件扫 pre 门是**范畴错误**。**恢复命令**：`printf '{"tool":"Write","paths":["DNA.md"]}' | ./tools/validate.sh --timing pre`（rc=2）vs `--timing post`（rc=0）⇒ 两者的**入参**分别是工具调用与文件内容。 |

| `d-phyt-coverage` | phyt-DNA | 未做/分析 | 2026-10-13 | 🟨 部分已做 | 2026-10-20 | **配对覆盖断言（A）**：门 × 调用方必须在账本里被真判过 —— **但"判过且绿"不落账**（账本只有违规/跳过/夹具）⇒ 按账本判会**冤红**（实测红 3+ 门）。**改判**：静态可达性（`hard` 门 × `applies-to` 命中 ≥1 受管文件）= **本轮已实现且绿（无死门）**；**未做**：让"绿"也可见（每次运行追加一行 **run-summary**：`kind:scan` + 文件数 + 触达门数）⇒ 那时"真判过"才可从账本读。**恢复命令**：`bash tools/ci-local.sh` 看 `OK（配对覆盖…）`。 |

| `d-phyt-edit-probe-same-batch` | phyt-DNA | 未做/分析 | 2026-10-13 | ⬜ 待做 | 2026-10-20 | **A2 编辑与探针不得同批** ⇒ 机检：probe 步骤前必须 dirty=0 且清单/基线已重生。**现状**：清单/基线**已是机检**（第 0/1 步，本轮抓我两次）；`dirty=0` 那一半**未做**（全量若跑在 dirty 上，读数与物件不同批）。**恢复命令**：全量运行末尾打印 `读数与物件不同批: dirty=N`（具名可 grep），并在 pre-push/CI 上要求 dirty=0。 |

| `d-phyt-git-three` | phyt-DNA | 未做/分析 | 2026-10-13 | 🟨 部分已做 | 2026-10-20 | **E git 三态三断言**：① `git ls-files` 的文件必须在工作区存在（**本轮已实现**：删了没 `add` ⇒ 具名红）② **禁裸 `git checkout -- <file>`**（从**索引**恢复 ⇒ 会把 stage 过的版本搬回工作区；应用 `git checkout HEAD -- <file>`）③ **重基线必须具名**（`frozen-body.sh --write --rebaseline <ADR> "理由"`；`--write` 拒绝静默重记）。**恢复命令**：三条各写反例（②③未做）。 |

| `d-phyt-reuse-check` | phyt-DNA | 未做/分析 | 2026-10-13 | ⬜ 待做 | 2026-10-20 | **G 新机制写一行【复用检查】**：这轮的新机制必须写清"是否在**复用**既有能力"。本轮实例：① `safe_edit.patch(old,new,must_contain_new,expect_old_count)` **早就存在**（我却手搓 replace ⇒ 两次翻车）② 引擎的 `paths` JSON 入参**早就支持批量**（只是批量语义不等价）③ `--rebaseline` **早就有**（我却在改冻结体正文）。**恢复命令**：加机制前先 `grep` 既有工具（`safe_edit.py` / `validate.sh` / `frozen-body.sh`）的同名能力。 |

| `d-phyt-five-class-debt-col` | phyt-DNA | 未做/分析 | 2026-10-13 | ⬜ 待做 | 2026-10-20 | **C 五分类增一栏【受已知债务影响的门（门名 + 债务 id）】** + `DEBTS 标"不能证"却算 proven ⇒ 具名红`。**现状**：五分类（proven/腐化/基线红/待夹具/另器）已有读数；**"受债务影响"这一栏未做**。**恢复命令**：在心跳（第 3 步）里对 `blocked-by` 的债务行逐条点名，并断言它们**不在** proven 计数里。 |
