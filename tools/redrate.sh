#!/usr/bin/env bash
# redrate.sh —— 把"记得去测"变成"跑一下脚本"。红率（N≥20，并行 + 串行双模式）才是证据。
#
# 为什么它是引擎级（phyt-DNA/tools/）而不是某仓私有：**"去测量"本身是一件共享工具**，
# 而"记得去测"正是这套生态从第一天就在消灭的东西（人类 2026-10-09：不能 100% 相信工具，
# 但更不该依赖"人的记性"）。⇒ 与 validate.sh / xray.sh 同一层，同一套声明式路径。
#
# 用法：
#   bash redrate.sh 20 --cd <dir> -- cargo test --all-features --no-fail-fast
#   bash redrate.sh 20 --cd <dir> --both -- cargo test --test foo      # 并行 + 串行（--test-threads=1）各 N 次
#
# 判读（写死，避免"绿了"被当作结论）：
#   红率 0/N（两种模式）  ⇒ 该判据【能绿】；仍须另有【能红】的证明（变异/夹具）
#   红率 >0              ⇒ 该判据【未闭合】；输出会给出是哪几次、哪几个测试
set -uo pipefail
N=20; CD="."; BOTH=0
while [ $# -gt 0 ]; do
  case "$1" in
    --cd) CD="$2"; shift 2;;
    --both) BOTH=1; shift;;
    --) shift; break;;
    *) [ -z "${N_SET:-}" ] && { N="$1"; N_SET=1; shift; } || break;;
  esac
done
CMD=("$@"); [ ${#CMD[@]} -gt 0 ] || { echo "用法: redrate.sh <N> --cd <dir> [--both] -- <command...>"; exit 2; }
run_once(){ # $1 = 模式标签（并/串）
  local mode="$1"; shift
  ( cd "$CD" && "$@" ) 2>&1
}
report(){ # $1 标签 $2 模式 $3.. 命令
  local label="$1" mode="$2"; shift 2
  local red=0 names="" i out rc
  for i in $(seq 1 "$N"); do
    # ★ 判"红"的【主信号是退出码】，不是输出形状。
    #   为什么（实测 2026-10-09）：第一版只认 cargo test 形状（`^test .* FAILED|error[|^error:`），
    #   于是命令**根本不存在**时报 0/N【能绿】—— 对一个"跑任意命令"的工具来说，这是最坏的谎：
    #   它撒的谎与"一切正常"长得一模一样（静音仪器家族的又一员）。
    #   退出码是通用信号；输出形状只作**辅助**（用于点名是哪个测试红）。
    out=$(run_once "$mode" "$@"); rc=$?
    if [ "$rc" != 0 ]; then
      red=$((red+1))
      names="$names $(echo "$out" | grep -E '^test .* FAILED' | awk '{print $2}' | tr '\n' ',')"
    fi
  done
  if [ "$red" = 0 ]; then
    printf '  %-28s 红率 0/%s  ⇒ 【能绿】\n' "$label" "$N"
  else
    printf '  %-28s 红率 %s/%s  ⇒ ★【未闭合】\n' "$label" "$red" "$N"
    printf '      出现的测试：%s\n' "$(echo "$names" | tr ' ' '\n' | sed '/^$/d' | sort | uniq -c | sort -rn | head -5 | tr '\n' ' ')"
  fi
}
echo "redrate: N=$N · cwd=$CD · 命令=${CMD[*]}"
report "并行（默认）" "parallel" "${CMD[@]}"
if [ "$BOTH" = 1 ]; then
  report "串行（--test-threads=1）" "serial" "${CMD[@]}" -- --test-threads=1
fi
echo "★ 读法：0/N 只能证明【能绿】；【能红】必须另有证明（变异/夹具）。两个都要有，判据才闭合。"
