#!/usr/bin/env bash
# Local diagnostics only. Does not install packages, change settings or upload.
set -uo pipefail
printf 'FH6 RX580 Linux compatibility diagnostics\n\n'
printf 'Kernel:\n'
uname -srmo
printf '\nDistribution:\n'
if [[ -r /etc/os-release ]]; then
    grep -E '^(NAME|VERSION|PRETTY_NAME)=' /etc/os-release || true
fi
printf '\nGraphics / gaming packages:\n'
if command -v pacman >/dev/null 2>&1; then
    pacman -Q mesa lib32-mesa vulkan-radeon lib32-vulkan-radeon vulkan-tools \
        proton-cachyos-slr proton-cachyos-native 2>&1 || true
else
    printf 'pacman is not available; this is not an Arch/CachyOS environment.\n'
fi
printf '\nDisplay adapters and kernel drivers:\n'
if command -v lspci >/dev/null 2>&1; then
    lspci -nnk | grep -A3 -E 'VGA compatible controller|3D controller|Display controller' || true
else
    printf 'lspci is not installed.\n'
fi
printf '\nVulkan summary:\n'
if command -v vulkaninfo >/dev/null 2>&1; then
    if command -v timeout >/dev/null 2>&1; then
        timeout 30s vulkaninfo --summary 2>&1 || true
    else
        vulkaninfo --summary 2>&1 || true
    fi
else
    printf 'vulkaninfo is not installed (provided by vulkan-tools).\n'
fi
printf '\nRelevant launch environment:\n'
for fh6_var in VKD3D_FEATURE_LEVEL VKD3D_SHADER_MODEL VKD3D_CONFIG \
    VKD3D_FILTER_DEVICE_NAME DRI_PRIME WINEDLLOVERRIDES; do
    printf '%s=%s\n' "$fh6_var" "${!fh6_var-<unset>}"
done
printf '\nRun with the game closed for a short recent GPU error extract:\n'
printf '%s\n' 'journalctl -b -k --no-pager | grep -Ei "amdgpu.*(timeout|reset|fault)|ring.*timeout" | tail -n 60'
