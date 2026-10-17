#!/usr/bin/env bash
# FH6 Polaris feature-level compatibility profile for Proton / VKD3D-Proton.
set -euo pipefail

if (( $# == 0 )) || [[ ${1-} == --help ]]; then
    printf '%s\n' \
        'Steam launch options (replace the path):' \
        'bash "/home/YOU/FH6-Polaris-Linux-v0.1.0/linux/fh6-rx580.sh" %command%' \
        '' \
        'Optional environment variables:' \
        '  FH6_RX580_LOG=1             Enable local Proton / VKD3D logs.' \
        '  FH6_RX580_DEVICE="RX 580"   Filter Vulkan devices by name substring.' \
        '' \
        'Pass the complete Proton/Steam launch command, not a bare Windows EXE.'
    exit 0
fi
if [[ $1 == -- ]]; then shift; fi
if (( $# == 0 )); then
    printf 'Missing launch command after --.\n' >&2
    exit 2
fi

# Use VKD3D's feature-level override instead of a Windows proxy DLL. Do not add
# separate shader-model, mesh-shader, enhanced-barrier or VRAM spoofing.
export VKD3D_FEATURE_LEVEL=12_1

if [[ -n ${FH6_RX580_DEVICE-} ]]; then
    export VKD3D_FILTER_DEVICE_NAME="$FH6_RX580_DEVICE"
fi
if [[ ${FH6_RX580_LOG:-0} == 1 ]]; then
    fh6_state_root=${XDG_STATE_HOME:-${HOME:?HOME must be set}/.local/state}
    fh6_log_dir="$fh6_state_root/fh6-rx580/logs"
    mkdir -p -- "$fh6_log_dir"
    export PROTON_LOG=1
    export PROTON_LOG_DIR="$fh6_log_dir"
    export VKD3D_DEBUG=info
    export VKD3D_LOG_FILE="$fh6_log_dir/vkd3d-$(date +%Y%m%d-%H%M%S)-$$.log"
    printf 'FH6 diagnostic logs: %s\n' "$fh6_log_dir" >&2
fi

# Preserve argument boundaries and the launch command's signals / exit status.
exec "$@"
