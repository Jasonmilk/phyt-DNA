#!/usr/bin/env bash
# 注入（红侧）：把被测 ADR 的 supersedes 指向一条【仍 accepted】的 ADR ⇒ 必须红（"只做一半"的形状）
# 构造：当场造一条 accepted 的被取代者，并让 $F 取代它。
d=$(dirname "$F")
printf -- '---\nid: ADR-99999999-injected-predecessor\nstatus: accepted\nhard: false\napplies-to: ["*"]\ntiming: post\ncheck: |\n  true\n---\n' > "$d/ADR-99999999-injected-predecessor.md"
sed -i.bak -E 's/^supersedes: .*/supersedes: ADR-99999999-injected-predecessor/' "$F" && rm -f "$F.bak"
