---
id: ADR-20261025-meter-must-be-on-duty
seq: 9029
status: accepted
hard: true
applies-to: ["ledger/hits-*.jsonl"]
effective-from: 2026-10-25
timing: post
redtest: "bash tools/validate.sh --probe ADR-20261025-meter-must-be-on-duty"
revisit-on: 2027-04-25
expires-on: null
owner: "@jason"
origin: "真实经历（2026-10-25 沙盒取证）：`SPEC.md` 早立了公式——值：经济门槛 f（年复发频率）× C > 年维护成本，仪表盘三判据；但 `SPEC.md:139` 自认 `last-hit` **无人回写** ⇒ f×C 至今是「穿公式外衣的定性判断」；`elapsed_ms` 虽在 kind:run 行里却无读数入口（`d-phyt-denominator` 已降级且逾期）。实测：70 条 run 行里 **44 条总额不自洽**（分类之和 ≠ judged_gates）⇒ 分类不可信，**而无人报警**。事件=电表上工（审查 JM-Zen ⑥⑨⑫ 三条新增判据塌缩为同一件事：给已写好的公式接输入）· 证据行=ledger/hits-2026.jsonl:2545 · 提交=6b5fdf3"
risk: normal
probe: yes
check: |
  # 只审【最新一条 kind:run 行】—— 它是【上一次】运行写的（run 行在 step 4 结尾才落账）。
  # ★ 为什么只审最后一行（不审全量）：历史行里 44/70 不自洽（A-5 修复前的遗产），
  #   而账本 **append-only，不能改旧行** ⇒ 全量审 = 上线即红一片 = 砸门 = 训练人忽略红灯
  #   （sync-upstream.sh 注释里自己警告过的警报疲劳）。法只管它管得住的那一层。
  # ★ 为什么不按日期过滤：按 ts ≥ 生效日 过滤 ⇒ 当天没人跑 ci-local 时**零行命中 ⇒ 空转**，
  #   空转是最隐蔽的假绿（GROWTH 判据形态②）。审"最新一行"永远有对象，不会空转。
  # ⚠️ 块内容【必须每行都以空格开头】：check_of 的 awk 遇顶格行即判定"块已结束" ⇒ check 被截断。
  [ -f "$F" ] || { echo "输入失效: $F 不存在（静默失败=伪证）"; }
  bad=$(python3 -c '
  import io, json, sys
  p = sys.argv[1]
  last = None
  for l in io.open(p, encoding="utf-8", errors="replace"):
      try: d = json.loads(l)
      except Exception: continue
      if isinstance(d, dict) and d.get("kind") == "run": last = d
  if last is None:
      # 没有任何 run 行 ⇒ 本次无对象可判（判不了 ≠ 判出违规）⇒ 具名跳过，不记绿也不记红
      sys.stderr.write("具名跳过：账本里没有 kind:run 行（电表尚未运行过）\n"); sys.exit(4)
  out = []
  # ① T_gate 栏：elapsed_ms 必须是正整数（缺了 = 电表第一栏空转）
  e = last.get("elapsed_ms")
  if not isinstance(e, int) or e <= 0:
      out.append("① T_gate 栏缺失：elapsed_ms 非正整数（%r）⇒ 电表第一栏空转" % (e,))
  pg = last.get("per_gate")
  keys = ("judged-green", "judged-red", "unmeasurable", "skipped-by-timing", "skipped-by-cache")
  # ② 五类必须齐（含 0 也必须显式写出空串）
  if not isinstance(pg, dict):
      out.append("② 缺 per_gate ⇒ 五类分类无处可读（覆盖率只能靠猜）")
  else:
      miss = [k for k in keys if k not in pg]
      if miss:
          out.append("② per_gate 缺类 %s（**含 0 也必须显式写出空串**）" % ",".join(miss))
  # ③ 判定总量自洽：judged_gates == |green ∪ red ∪ unmeasurable|
  #   ★ 2026-10-25 修（死锁修复）：原写「三类的**和**」—— 但 ci-local 写入的 judged_gates 是
  #     judged-green 的**并集计数**，而同一门对不同文件可能一绿一红 ⇒ **求和会重复计** ⇒
  #     一条完全合法的"真违规后"run 行就会让本门**基线红** ⇒ 下次运行审到它继续红 ⇒
  #     **钩子拒提交 ⇒ 宿主连"修它"都提交不了（死锁）**。口径必须与写入方一致：**并集，不求和**。
  if isinstance(pg, dict):
      uni = set()
      for k in keys[:3]:
          uni.update((pg.get(k) or "").split())
      if len(uni) != last.get("judged_gates", 0):
          out.append("③ 判定总量不自洽：judged_gates=%s 但 |green∪red∪unmeasurable|=%s ⇒ 分类不可信" % (last.get("judged_gates"), len(uni)))
  if out:
      print("电表未上工（最新一次运行的读数不自洽）: " + "；".join(out))
  ' "$F"); rc=$?
  [ "$rc" = 4 ] && exit 4
  [ -n "$bad" ] && echo "${bad}"
last-hit: null
hit-count: 0
supersedes: null
---

# 电表必须上工：最新一次运行的读数必须自洽

## 为什么

`SPEC.md` 早就把公式立好了：

> 值 经济门槛 → **f（年复发频率，次/年）× C（单次代价）> 年维护成本**
> 仪表盘判据：`hits/任务` · `override_rate` 按原因分类 · 心跳红率 + 新增结晶数

但 `SPEC.md:139` 自己承认：

> **`last-hit` 字段存在但无人回写** ⇒ `f × C` 门槛目前是**穿公式外衣的定性判断**

⇒ 三处缺口（f / T_gate / 分类可信度）根子是同一个：**仪器没上工**。

而实证更糟：

```
70 条 kind:run 行中，44 条【总额不自洽】
（judged_gates ≠ judged-green + judged-red + unmeasurable）
```

**分类不可信，且无人报警** —— 因为没有任何一道门在守这件事。

⇒ 按 Ω：**没上工的判据是装饰品**。本门的职责不是新增判据，
是**让既有公式的输入变得可校验**。

## 判据（三条，都针对【最新一条】run 行）

| # | 断言 | 对应的电表栏 |
|---|---|---|
| ① | `elapsed_ms` 必须是正整数 | **T_gate**（缺了就是空转） |
| ② | `per_gate` 五类必须齐（**含 0 也要显式空串**） | 覆盖率分类 |
| ③ | `judged_gates` == **判定三类的并集**（green ∪ red ∪ unmeasurable） | **分类可信度** |

## 为什么只审【最新一条】

- **不审全量**：历史 44/70 不自洽，而账本 append-only，**不能改旧行** ⇒ 全量审 = 上线即红一片 ⇒ 砸门 ⇒ 训练人忽略红灯（`sync-upstream.sh` 注释自己警告过的警报疲劳）。
- **不按日期过滤**：`ts ≥ 生效日` 会在"当天没人跑 ci-local"时**零行命中 ⇒ 空转**，而空转是最隐蔽的假绿（GROWTH 判据形态②）。审最新一行**永远有对象**。
- **没有 run 行 ⇒ 具名跳过**（rc=4），不记绿也不记红：**判不了 ≠ 判出违规**。

## f 的真值源（定死，消除双真源）

`SPEC.md:139` 给了两条路：**实现回写** 或 **定 f 真值源 = ledger 事件计数**。
本门选**第二条**：

- **f 真值源 = ledger**（`kind:task` 口径，与 `ledger/README.md` 的"生产指标只算 task"同源）；
- ADR 里的 `last-hit` / `hit-count` 降为它的**投影**，由 `bash tools/meter.sh --writeback`
  机械生成，**禁手编**（与派生视图禁手编同源）。

⇒ 否则这两个字段就是"外挂的状态没有真值源，就会死"（DNA 唯一真源）。

## 电表读数怎么读

```bash
bash tools/meter.sh            # 三栏：f · T_gate · 分类可信度
bash tools/meter.sh --json     # 给 CI / 看板消费
bash tools/meter.sh --writeback  # last-hit / hit-count 投影回写（显式调用）
```

**仪器纪律**：只给数，不判读（判读归园丁——守卫不自签，仪器不给自己签发结论）；
**样本不足必须具名**，不虚标（读数不成立 ≠ 读数为 0）。

## 边界与具名局限

### ★ f 的宿命：母仓天然无生产样本（必须具名，否则会被误读）

`ledger/README.md:6` 定死：**生产指标只算 `kind: task`**（探针/扫描/自检/模拟不计入）。
而母仓自己**不跑业务** ⇒ 实测：全仓 `kind:task` 仅 5 行、`block` 0 行
（全仓 11 条 block 全是 `probe` —— 夹具造的红，不是生产命中）。

⇒ **f 的读数只能来自宿主**（`VISION.md` 第九节：读数在宿主先成立，反哺才回母仓）。
⇒ 本仓电表显示的 `f=?` 是**【母仓无样本】**，**不是 f=0**。

**为什么这句话必须写进来**：不写 ⇒ 有人会读成"f = 0 ⇒ 这些门不值得守"，
那是**把"没测过"伪装成"测过且为零"**——装饰品的最新一种形态。
仪器纪律写死了：**样本不足必须具名，不虚标**（读数不成立 ≠ 读数为 0）。

### 扫描面局限：spec-lint 看不见 Python 的 `os.replace`

`tools/meter.sh --writeback` 用 Python `os.replace()` 做原子替换（先写 `.tmp` 再替换）。
而 `spec-lint.sh` 的"未声明写回"闸门模式只认
`cp|mv|tee|sed -i|rsync|git checkout` ⇒ **扫不到它**。

- 现状：meter.sh 写了"有意回写（理由：…）"注释（给人读），但**闸门本身看不见这次写回**。
- 补偿控制：`--writeback` 是**显式调用**（引擎从不自动写真件）；且它只改
  `last-hit`/`hit-count` 两个 **frozen-body 白名单键** ⇒ 冻结体门仍绿（实测 OK）。
- 真覆盖需解析器（与 `d-phyt-comment-sweep` 同族，DEBTS 已具名登记）。

- 只审 `kind: run` 的最新一条；逃生门/问句的日落由 `ci-local` ①补 审计，不归本门。
- **不校验 per_gate 内容是否正确**（那需要独立链，见 `docs/observations/a6-two-chains.sh`）；本门只校验**形状与总额**。
- 判据只读不写。

## 红测

`fixtures/<id>/inject.sh` 追加一条**缺 elapsed_ms / 五类不齐 / 总额不符**的 run 行 ⇒ 必须红；
`counter.sh` 只 touch ⇒ 必须不红。
