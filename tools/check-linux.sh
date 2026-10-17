#!/usr/bin/env bash
set -euo pipefail
root=$(cd -- "$(dirname -- "$0")/.." && pwd -P)
wrapper="$root/linux/fh6-rx580.sh"
set +e
result=$(VKD3D_FEATURE_LEVEL=11_0 bash "$wrapper" bash -c 'printf "%s|%s|%s" "$VKD3D_FEATURE_LEVEL" "$1" "$2"; exit 7' -- 'two words' 'literal $HOME')
status=$?
set -e
[[ $status == 7 && $result == '12_1|two words|literal $HOME' ]]
temp=$(mktemp -d)
trap 'rm -rf -- "$temp"' EXIT
mkdir -p "$temp/game folder"
touch "$temp/game folder/forzahorizon6.exe"
printf 'unknown DLL' > "$temp/game folder/d3d12.dll"
set +e
bash "$root/linux/prepare-game.sh" "$temp/game folder" >/dev/null 2>&1
status=$?
set -e
[[ $status == 2 && -f "$temp/game folder/d3d12.dll" && ! -d "$temp/game folder/.fh6-windows-patch-backups" ]]
FH6_RX580_LOG=1 XDG_STATE_HOME="$temp/state folder" bash "$wrapper" bash -c '[[ -d "$PROTON_LOG_DIR" && $PROTON_LOG == 1 ]]' 2>/dev/null
printf 'Linux wrapper checks passed; no game or GPU test was performed.\n'
