# fixtures/<gate-id>/ · 心跳的反例

## 唯一文件：`inject.sh`

作用：造一个**真实的违规样例**，供心跳检出。
- 必须**接受环境变量 `$F`**（与 `applies-to` 同源）—— 否则注入目标 ≠ 检测目标
- 必须**注入到隔离文件**，绝不污染真实资产（ADR-0009）

```bash
#!/usr/bin/env bash
# 好：隔离注入
printf '违规内容\n' > tools/_probe_dummy.sh

# 坏：污染真实引擎
printf 'git checkout -- .\n' >> tools/validate.sh   # ← ADR-0009 禁止
```

## 铁律
1. 注入的缺陷必须**真的越过阈值**（否则心跳恒 NOT RED）
2. 注入目标必须与 `applies-to` 展开的路径**一致**
3. **不得**出现 `git checkout -- .` / `git clean -fd` / `git stash`
