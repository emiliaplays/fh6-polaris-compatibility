#!/usr/bin/env bash
# Back up ONLY the exact Windows compatibility DLLs used in our session.
set -euo pipefail

if (( $# != 1 )) || [[ ${1-} == --help ]]; then
    printf '%s\n' 'Usage: bash prepare-game.sh "/path/to/Forza Horizon 6"' \
        'Close the game first. Known Windows patch DLLs are MOVED into a backup.' \
        'Unknown DLLs are refused. No game saves, drivers or Proton files are touched.'
    exit 0
fi
fh6_game_dir=$(cd -- "$1" && pwd -P)
if [[ ! -f "$fh6_game_dir/forzahorizon6.exe" && ! -f "$fh6_game_dir/ForzaHorizon6.exe" ]]; then
    printf 'No ForzaHorizon6.exe found in: %s\n' "$fh6_game_dir" >&2
    exit 2
fi
command -v sha256sum >/dev/null 2>&1 || { printf 'sha256sum is required.\n' >&2; exit 2; }
fh6_files=()
for fh6_name in d3d12.dll dxgi.dll; do
    fh6_path="$fh6_game_dir/$fh6_name"
    if [[ -L $fh6_path ]]; then
        printf 'Refusing a symbolic link: %s\n' "$fh6_path" >&2
        exit 2
    fi
    if [[ ! -e $fh6_path ]]; then continue; fi
    if [[ ! -f $fh6_path ]]; then
        printf 'Refusing a non-regular file: %s\n' "$fh6_path" >&2
        exit 2
    fi
    fh6_hash=$(sha256sum -- "$fh6_path")
    fh6_hash=${fh6_hash%% *}
    case "$fh6_name:$fh6_hash" in
        d3d12.dll:f307fc5ef567debca6d090922d27de135b3f29bc578962db61cddc3137ac1128|\
        d3d12.dll:851e85698bb0906f3b65f23dcd10a4d022684151ba53fd77e65a0f3dd1d273c6|\
        dxgi.dll:e52f2622c40b1491fb667fd8d673eb3ebf5de44dab8f7548f1a8f2b509927909|\
        dxgi.dll:7e059feeca6ee63a322192bfdf59d62d67c939b1162d4e495d80dd553a15289d)
            fh6_files+=("$fh6_path") ;;
        *)
            printf 'Unknown %s (%s). Nothing has been moved.\n' "$fh6_name" "$fh6_hash" >&2
            printf 'Inspect it manually; it may belong to another mod or runtime.\n' >&2
            exit 2 ;;
    esac
done
if (( ${#fh6_files[@]} == 0 )); then
    printf 'No known Windows patch DLLs found. No changes needed.\n'
    exit 0
fi
fh6_backup_dir="$fh6_game_dir/.fh6-windows-patch-backups/$(date +%Y%m%d-%H%M%S)-$$"
mkdir -p -- "$fh6_backup_dir"
for fh6_path in "${fh6_files[@]}"; do
    mv -- "$fh6_path" "$fh6_backup_dir/"
done
printf 'Windows patch DLLs backed up to:\n%s\n' "$fh6_backup_dir"
printf 'To restore Windows use: close the game, then move these DLLs back into the game folder.\n'
printf 'If a DLL already exists at the destination, inspect it first; do not overwrite it blindly.\n'
