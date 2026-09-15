# v0.5 release build

This directory stores the reproducible v0.5 release inputs and metadata.

- `v05_package_b64/part-*`: base64 chunks of the verified delta-patch ZIP
- `v05_release_info.json`: upstream/patched hashes and release counters
- `upstream_state.json`: tracked itch.io upstream upload and binary hashes
- `Install_Korean_Patch.*`, `README_KO.txt`: installer/readme sources

`.github/workflows/release-v05.yml` reconstructs the ZIP, verifies its SHA-256 and manifest, and only then publishes GitHub Release `v0.5`.
