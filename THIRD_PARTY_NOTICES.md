# Third-party files

No AMD driver, 7-Zip executable, game file, Windows runtime DLL, or upstream compatibility DLL is shipped in this source repository or its generated release ZIPs.

`windows/requirements.json` records the two upstream downloads, their SHA-256 values, and provenance. `Prepare-Windows.ps1` fetches them into a local ignored `data` directory. The AMD installer is also checked for a valid AMD Authenticode signature before extraction. Each download remains governed by its owner's terms.

The original Windows Polaris repository had **no detected repository license** when inspected on 2026-10-17. Public availability is not a grant to redistribute or relicense its binary. It is credited and fetched from upstream instead. We do not claim authorship of that proxy.

The locally edited AMD INF invalidates the original package catalog's coverage of that INF. The installer remains an experimental use on hardware outside AMD's published compatibility list for this developer driver. We do not sign, endorse, or redistribute the altered driver package.

The Linux profile uses existing VKD3D-Proton functionality. It is not a compiled port of the Windows proxy, and it adds no physical GPU capability. The `12_1` override can also advertise ROVs/conservative rasterization according to the upstream implementation; it is not identical to changing only the Windows feature-level query result.
