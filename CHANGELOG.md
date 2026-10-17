# Changelog

## v0.1.0 — experimental prerelease

- Document Windows Polaris driver preparation, installation, display checks and rollback.
- Fetch a hash-pinned original upstream Polaris proxy and official AMD developer driver locally; do not redistribute third-party binaries.
- Provide a hardware-specific Windows INF preparation helper and driver installation helper with original-driver backup prerequisites.
- Provide a CachyOS/Proton feature-level profile, local diagnostics and a helper that backs up only known Windows proxy DLLs.
- Record observed Windows gameplay, driver timeouts, intermittent launch failures and multi-GPU/display problems without claiming stability.
- Add local script syntax/behavior checks and explicit package-content selection for separate Windows/Linux ZIPs.

Linux gameplay and the generic Windows release-helper installation path remain unvalidated.
