#!/usr/bin/env bash
# counter.sh — THE NEGATIVE FIXTURE: a CONTENT-PRESERVING change must not change the verdict.
#
# `inject.sh` proves "the bad thing goes red". It cannot prove "the good thing stays green":
# inject.sh writes bytes, which changes content AND mtime, so a criterion that reads a clock would
# still go red and its regression would go unnoticed. This fixture changes ONLY the mtime.
# The criterion compared is "did the conclusion CHANGE", not "is it red" — this gate may already be
# red for its own reasons (e.g. PLAN.md is over its own 150-line cap).
set -eu
: "${F:?fixture needs $F (the file under test)}"
cp "$F" /tmp/_counter_backup 2>/dev/null || true
if touch -t 202001010000 "$F" 2>/dev/null; then :; else touch "$F"; fi
