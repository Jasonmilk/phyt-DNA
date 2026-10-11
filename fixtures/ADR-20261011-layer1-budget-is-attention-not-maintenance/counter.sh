#!/usr/bin/env bash
# counter.sh — THE NEGATIVE FIXTURE: a CONTENT-PRESERVING change must not change the verdict.
#
# `inject.sh` proves "the bad thing goes red"; it cannot prove "the good thing stays green":
# inject.sh writes bytes, which changes content AND mtime, so a criterion that read a clock would
# still go red and its regression would go unnoticed. This fixture changes ONLY the mtime.
# 判据是"结论变没变"，不是"是不是红" —— 本闸门可能因自身原因已红（例如 PLAN 自己另有 150 行上限）。
touch "$F"
