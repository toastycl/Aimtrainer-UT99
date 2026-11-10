#!/bin/sh
base=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
exec python3 "$base/tools/start_aimtrainer.py" --ut-root "$base"
