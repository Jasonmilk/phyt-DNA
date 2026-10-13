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

| `d-phyt-coverage` | phyt-DNA | 未做/分析 | 2026-10-13 | 🟨 部分已做 | 2026-10-20 | **配对覆盖断言（A）**：门 × 调用方必须在账本里被真判过 —— **但"判过且绿"不落账**（账本只有违规/跳过/夹具）⇒ 按账本判会**冤红**（实测红 3+ 门）。**改判**：静态可达性（`hard` 门 × `applies-to` 命中 ≥1 受管文件）= **静态可达性 OK（无死门）**，但**动态覆盖【未证】**（账本此前不记"绿"）⇒ **v2 是一次「降级」**：从"断言每门被真判过"降为"断言每门的 applies-to 能命中受管文件"。**解除降级的唯一路径 = A-5 的 run 摘要**（本轮已实现：`kind:run` 行含 `judged_ids`）；**该断言本身随 ci-local 还原未落地**；**未做**：让"绿"也可见（每次运行追加一行 **run-summary**：`kind:scan` + 文件数 + 触达门数）⇒ 那时"真判过"才可从账本读。**恢复命令**：`bash tools/ci-local.sh` 看 `OK（配对覆盖…）`。 |

| `d-phyt-edit-probe-same-batch` | phyt-DNA | 未做/分析 | 2026-10-13 | ⬜ 待做 | 2026-10-20 | **A2 编辑与探针不得同批** ⇒ 机检：probe 步骤前必须 dirty=0 且清单/基线已重生。**现状**：清单/基线**已是机检**（第 0/1 步，本轮抓我两次）；`dirty=0` 那一半**未做**（全量若跑在 dirty 上，读数与物件不同批）。**恢复命令**：全量运行末尾打印 `读数与物件不同批: dirty=N`（具名可 grep），并在 pre-push/CI 上要求 dirty=0。 |

| `d-phyt-git-three` | phyt-DNA | 未做/分析 | 2026-10-13 | 🟨 部分已做 | 2026-10-20 | **E git 三态三断言**：① `git ls-files` 的文件必须在工作区存在（**未落地**：曾实现，后随 ci-local 一并还原撤销）② **禁裸 `git checkout -- <file>`**（从**索引**恢复 ⇒ 会把 stage 过的版本搬回工作区；应用 `git checkout HEAD -- <file>`）③ **重基线必须具名**（`frozen-body.sh --write --rebaseline <ADR> "理由"`；`--write` 拒绝静默重记）。**恢复命令**：三条各写反例（②③未做）。 |

| `d-phyt-reuse-check` | phyt-DNA | 未做/分析 | 2026-10-13 | ⬜ 待做 | 2026-10-20 | **G 新机制写一行【复用检查】**：这轮的新机制必须写清"是否在**复用**既有能力"。本轮实例：① `safe_edit.patch(old,new,must_contain_new,expect_old_count)` **早就存在**（我却手搓 replace ⇒ 两次翻车）② 引擎的 `paths` JSON 入参**早就支持批量**（只是批量语义不等价）③ `--rebaseline` **早就有**（我却在改冻结体正文）。**恢复命令**：加机制前先 `grep` 既有工具（`safe_edit.py` / `validate.sh` / `frozen-body.sh`）的同名能力。 |

| `d-phyt-five-class-debt-col` | phyt-DNA | 未做/分析 | 2026-10-13 | ⬜ 待做 | 2026-10-20 | **C 五分类增一栏【受已知债务影响的门（门名 + 债务 id）】** + `DEBTS 标"不能证"却算 proven ⇒ 具名红`。**现状**：五分类（proven/腐化/基线红/待夹具/另器）已有读数；**"受债务影响"这一栏未做**。**恢复命令**：在心跳（第 3 步）里对 `blocked-by` 的债务行逐条点名，并断言它们**不在** proven 计数里。 |
| `d-phyt-string-match` | phyt-DNA | **工具脆弱** | 2026-10-13 | ⬜ 待做 | 2026-10-20 | **就地对大文件打补丁三次未落地**（`old` 串差一个全角括号/缩进/空格 ⇒ AssertionError ⇒ 整批不写；`safe_write` 的新锁又当场拦下我一次笔误）。**恢复命令**：改用 `safe_edit.patch(old,new,must_contain_new,expect_old_count)`（它对旧文计数），或**先 repr 取原文**再拼串。 |
| `d-phyt-pre-gap-a` | phyt-DNA | **pre 面缺口/机制** | 2026-10-13 | ⬜ 待做 | 2026-10-20 | **pre 面缺口 (a)：`git commit` 走非工具路径** —— `bash`/`git apply`/`merge`/手工改文件后 `git add` 都不会经过 PreToolUse 执行闸 ⇒ pre 门（危险形状）在这条路径上**没有任何入口**。**revisit-on 2026-10-20**。**恢复命令**：`printf '{"tool_name":"Bash","tool_input":{"command":"rm -rf /tmp/x"}}' | bash examples/claude-code/hooks/pretooluse-gate.sh; echo $?`（应 2）—— 然后自问：若它不经 Write/Bash 工具，谁拦？ |

| `d-phyt-pre-gap-b` | phyt-DNA | **pre 面缺口/机制** | 2026-10-13 | ⬜ 待做 | 2026-10-20 | **pre 面缺口 (b)：未装钩子的克隆（采用者默认）** —— 新克隆 **没有 `core.hooksPath`**（实测）⇒ 连 post 面也不跑，pre 面更无。★ **须写进 README + 采用者启用包**。**revisit-on 2026-10-20**。**恢复命令**：`git clone <仓> /tmp/k && cd /tmp/k && printf '{"tool_name":"Bash","tool_input":{"command":"rm -rf /tmp/x"}}' | bash examples/claude-code/hooks/pretooluse-gate.sh; echo $?`（钩子文件在，但**没人调用它**）。 |

| `d-phyt-pre-gap-c` | phyt-DNA | **pre 面缺口/机制** | 2026-10-13 | ⬜ 待做 | 2026-10-20 | **pre 面缺口 (c)：CI** —— README 自称真门/兜底，但 **CI 只跑 ci-local（= post 面）**，pre 面**不在 CI 里**，且 CI 里也没有 Claude 工具调用可拦。**revisit-on 2026-10-20**。**恢复命令**：读 `.github/workflows/phyt.yml` ⇒ 只有 `tools/ci-local.sh`；再读 `examples/claude-code/hooks/pretooluse-gate.sh` ⇒ 无 CI 入口。 |

| `d-phyt-run-summary` | phyt-DNA | **pre 面缺口/机制** | 2026-10-13 | ⬜ 待做 | 2026-10-20 | **A-5 run 摘要（已实现，消费规则待写进判据）**：每次 ci-local 落一行 `{"kind":"run", caller, timing, files, judged_gates, judged_ids, verdicts}`。**消费端规则**：① **只有 judged-green 计入 proven** · ★**`fail-closed`（坏 payload rc=2）与 `blocked`（真违规）必须分开记，不许混** · ★**"受债务影响"栏（C 并入 A-5 schema）**：标 `blocked-by` / "不能证"的条目**不得计入 proven**，违者**具名红**；② `skipped-by-cache` 必须**具名**且**缓存失效可机检**；③ 其余（未判/异常/输入失效）**不计入**。**revisit-on 2026-10-20**。**恢复命令**：`tail -1 ledger/hits-$(date +%Y).jsonl \| grep '"kind":"run"'`；`grep -c '"kind":"run"' ledger/hits-$(date +%Y).jsonl`。 |

| `d-phyt-phantom-complete` | phyt-DNA | **pre 面缺口/机制** | 2026-10-13 | ⬜ 待做 | 2026-10-20 | **「幽灵完成」门**：**声明改了某文件 ⇒ `git diff --name-only` 必须含该文件**（本轮我声明"已实现"却随还原撤销 ⇒ 假账）。年轮已立族名。**revisit-on 2026-10-20**。**恢复命令**：把声明（提交信息/报告里的文件路径）与 `git diff --name-only HEAD~1` 比对；未落地者具名。 |
| `d-phyt-run-summary-persist` | phyt-DNA | **阻断（A-5 不可信）** | 2026-10-13 | ⛔ blocked-by: 无 | 2026-10-14 | **run 摘要写进去却没活下来**：ci-local 打印 `追加 1 行 run 摘要 · 第 1517 行`，而账本 `wc -l = 1516` 且 `grep -c '"kind":"run"' = 0`；文件 mtime=18:37 但末行 ts=17:00 ⇒ **有东西把追加行回滚了**（疑：提交/恢复循环里账本被重写，未证）。⇒ **A-5 的「judged-green 可读」目前不可信**；① 的 per_gate/elapsed/差额点名**全部被它阻塞**。**恢复命令**：跑一次 `bash tools/ci-local.sh --fast`，立刻 `tail -1 ledger/hits-$(date +%Y).jsonl` 与 `grep -c '"kind":"run"'`；若为 0 ⇒ 在**追加处**打印路径与 `wc -l` 前后值，并查"谁在之后重写了账本"（`git log -p -- ledger/`）。 |

| `d-phyt-per-gate-schema` | phyt-DNA | **A-5 补全** | 2026-10-13 | ⛔ blocked-by: d-phyt-run-summary-persist | 2026-10-14 | **逐门 `per_gate:{id, source_class, verdict}`**，四类显式（含 0）：`judged-green` / `judged-red` / `unmeasurable` / `skipped-by-cache`（**失效条件必须可机检**）/ `skipped-by-timing`；+ **`elapsed_ms`（电表第一栏）** + `caller`/`timing`；**差额点名 + 总数校验**（各分类之和 == 分母）；消费端：**fail-closed（坏 payload rc=2）与 blocked（真违规）分开记**。**已得**：差额点名的**静态**部分 = **4 门不在扫描面**（`applies-to` 全是 `ledger/*.jsonl` ⇒ `.jsonl` 不在 step 4 的扩展名列表里）：`appeals-must-be-parseable` · `ledger-must-be-valid-utf8` · `lesson-must-be-replayed` · `ledger-new-lines-parseable-and-referenced`；另 **2 门 `skipped-by-timing`**（pre）。**恢复命令**：`python3` 比对 `judged_ids` × `applies-to` 命中集（本轮的差额脚本）。 |

## 日落机制（分型 · 2026-10-13 · 每型各带反例）

| 型 | 对象 | **判据（可机检）** | **反例（必须红）** |
|---|---|---|---|
| **计数型** | 年轮（GROWTH） | `live ≤ 阈值` **∧** 被归档条目的 **id/指纹在 live 中不存在** | 「**只复制不删** ⇒ 具名红」（本轮真踩：复制后 5−3=2=归档数 ⇒ 计数门照样通过） |
| **状态型** | DEBTS 条目 · 图纸 promote · skip 结案 | 状态翻转**必须绑本体证据**（见下表"本体判据"栏被满足） | 「**只翻状态** ⇒ 红」·「**只改 `hard:true`** ⇒ 红」·「**只写一行关闭行** ⇒ 红」 |
| **时间型** | `revisit-on` / `expires-on` | 到期日可解析 **∧** 到期时**必须给出本体证据或续期理由** | 「到期了只改日期 ⇒ 红」 |

### schema 增栏：【本体判据】—— 每条待办都要能回答"**什么叫真解决（可机检）**"

> 缺此栏 ⇒ 该条**不成立**（登记即无效）。栏内必须是**命令**或**命令可判的断言**，不是形容词。
| `d-phyt-a6-counterexample` | phyt-DNA | 未做/登记 | 2026-10-13 | ⬜ 待做 | 2026-10-14 | **A-6 之外的具名反例**（DS④ + 终止条件三条）：反例必须**不由 A-6 自己的代码路径产生**、有**独立收据**、**真场景**（如 `PHYT_LEDGER` 指向只读路径 ⇒ append 真失败）。**本体判据**：`PHYT_LEDGER=/nonexistent-ro bash tools/ci-local.sh --fast` ⇒ 该次运行**必须红**且在 stdout 点名"读数无出处"，收据落在 DEBTS/观测层。**满足三条即停止递归**。 |

| `d-phyt-ledger-gates-unenforced` | phyt-DNA | 未做/登记 | 2026-10-13 | ⬜ 待做 | 2026-10-14 | **4 门账本面门标 unenforced**：`appeals-must-be-parseable` · `ledger-must-be-valid-utf8` · `lesson-must-be-replayed` · `ledger-new-lines-parseable-and-referenced` —— 其 `applies-to` 全是 `ledger/*.jsonl`，而 step 4 只扫 `*.md/*.py/*.sh/*.yml` ⇒ **无 caller 覆盖**。**本体判据**：`grep -c '"kind":"run"' ledger/hits-$(date +%Y).jsonl` 的行里，这 4 个 id **不出现在 `per_gate.judged-green`** ⇒ 它们**不得计入 proven**（分母里单列）。 |

| `d-phyt-growth-counttype` | phyt-DNA | 未做/登记 | 2026-10-13 | ⬜ 待做 | 2026-10-14 | **日落·计数型（本批只做这一型）**：GROWTH 判据改为 `live ≤ 阈值 ∧ 被归档条目 id/指纹在 live 中不存在`。**本体判据**：注入"把归档里的 `## 年轮 · X` 标题复制回 GROWTH" ⇒ **必须红**（现行门只数条数 ⇒ 5−3=2=归档数 **照样过**，本轮真踩）；反例（只 touch）⇒ 必须绿。 |

| `d-phyt-sunset-rest` | phyt-DNA | 未做/登记 | 2026-10-13 | ⬜ 待做 | 2026-10-14 | **日落·其余四处（各自独立登记，不压批）**：DEBTS 结案 · 图纸 promote · skip 结案 · 时间型 revisit-on。**本体判据（各自）**：结案行必须引**本体证据**（真 task 行/真 sha/真命令输出）；promote 必须**新立门并三态齐**；skip 结案必须**由真实事故或具名豁免**；revisit-on 到期必须**给本体证据或具名续期理由**，只改日期 ⇒ 红。 |
| `d-phyt-a6-counterexample` | phyt-DNA | **已做（待人工复核）** | 2026-10-13 | 🟨 待裁定 | 2026-10-14 | **A-6 之外的收据（可复现 · 独立判定者不调用 A-6 的代码路径）**｜① **执行者 ≠ 判定者**：判定者 = `python3` 直读账本（不经过 ci-local 的 bash 断言）。② **正样本**：`python3 -c "…按行号取 run 行…"` ⇒ `PASS（值有意义 · elapsed_ms=76000）`；实测 **末行不是 run 行** ⇒ 这正是把 A-6 从 `tail -1` 改为 `sed -n "${_led1}p"` 的原因（**全量模式 5a/5 会在 run 行之后追加 ⇒ tail -1 会冤红**）。③ **反例 A（真场景）**：`PHYT_LEDGER=/nonexistent-dir-xyz bash -c '_led="$PHYT_LEDGER/hits-$(date +%Y).jsonl"; : >> "$_led" 2>/dev/null || echo RED'` ⇒ 打印 **★ RED: 账本不可写/不存在 ⇒ 读数无出处** ✅；**对照**（可写路径）⇒ 不响 ✅。   ★ 附修：原守卫 `wc -l < f \| tr -d " "` 的**管道退出码被 `tr` 吃掉** ⇒ 守卫不响（实测只读路径下照读 0 行）⇒ 改为真 `: >>` 探测。④ **反例 B（值无意义）**：`per_gate={}` / 缺 `skipped-by-cache` / `elapsed_ms=0` 三支 ⇒ 判定者均 **False**，A-6 均红 ✅。**本体判据（绑定快照锚点）**：同一账本快照（sha1 + 行号 N）下，任意读者用上述命令复现**同一张表**；判据不是"我点过名了"。| Pi |
