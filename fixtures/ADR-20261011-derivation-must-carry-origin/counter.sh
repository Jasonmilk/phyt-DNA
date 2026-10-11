#!/usr/bin/env bash
# counter.sh — THE NEGATIVE FIXTURE: a CONTENT-PRESERVING change must not change the verdict.
# 判据是"结论变没变"，不是"是不是红"：本闸门可能因别的原因红（例如被审文件本就是 hard:false）。
touch "$F"
