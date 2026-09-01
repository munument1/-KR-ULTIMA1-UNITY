from pathlib import Path
import json, hashlib, shutil, zipfile

ROOT = Path(__file__).resolve().parent.parent
BUILD = ROOT / "release_build"
OLD = ROOT / "_v03"
OUT = ROOT / "_v04_out"
ZIP = ROOT / "Ultima1Unity_Korean_v0.4_DeltaPatch.zip"


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


old_manifest = json.loads((OLD / "patch_data.json").read_text(encoding="utf-8-sig"))
transform = json.loads((BUILD / "v04_transform.json").read_text(encoding="utf-8"))

new_manifest = {
    "version": transform["version"],
    "game": transform["game"],
    "binary_files": [],
    "json_files": old_manifest["json_files"],
}

for file_index, tf in enumerate(transform["binary_files"]):
    old_file = old_manifest["binary_files"][file_index]
    rebuilt = {
        "path": tf["path"],
        "original_sha256": tf["original_sha256"],
        "patched_sha256": tf["patched_sha256"],
        "size": tf["size"],
        "patches": [],
    }
    for offset, value in tf["patches"]:
        if isinstance(value, int):
            data = old_file["patches"][value]["data"]
        else:
            data = value
        rebuilt["patches"].append({"offset": offset, "data": data})
    new_manifest["binary_files"].append(rebuilt)

if OUT.exists():
    shutil.rmtree(OUT)
OUT.mkdir()

manifest_path = OUT / "patch_data.json"
manifest_path.write_text(
    json.dumps(new_manifest, ensure_ascii=False, separators=(",", ":")),
    encoding="utf-8",
)

expected_manifest_sha = "93d4ae0834ee201d7498b97016c72bd6606a28279ea2602404d2419cf1bc64f4"
actual_manifest_sha = sha256(manifest_path)
if actual_manifest_sha != expected_manifest_sha:
    raise SystemExit(f"patch_data.json SHA mismatch: {actual_manifest_sha}")

for name in ("Install_Korean_Patch.ps1", "Install_Korean_Patch.bat", "README_KO.txt"):
    shutil.copy2(BUILD / name, OUT / name)
shutil.copy2(OLD / "LICENSE_Galmuri.txt", OUT / "LICENSE_Galmuri.txt")

expected_files = {
    "Install_Korean_Patch.ps1": "844c85474c0ca28f4bb8d10569fb5dd1d3a6d61fad76f199bea9d2a22ee7eafa",
    "Install_Korean_Patch.bat": "de69a0212149a5edb0acbd6f14d8e4387de5cc8f18dab50b937acdd407fda428",
    "README_KO.txt": "98881fc8c1cf08004427b5cf3d1c0e7af9f866759d01cc3b573f0ec8a8ed31fc",
    "LICENSE_Galmuri.txt": "86a3ee9495f942f0243f18c103da9faca27adb88142613edb8bb852e56c892c1",
    "patch_data.json": expected_manifest_sha,
}
for name, expected in expected_files.items():
    actual = sha256(OUT / name)
    if actual != expected:
        raise SystemExit(f"{name} SHA mismatch: {actual}")

if ZIP.exists():
    ZIP.unlink()
with zipfile.ZipFile(ZIP, "w", zipfile.ZIP_DEFLATED, compresslevel=9) as z:
    for p in sorted(OUT.iterdir()):
        z.write(p, p.name)

with zipfile.ZipFile(ZIP) as z:
    bad = z.testzip()
    if bad:
        raise SystemExit(f"ZIP integrity failure: {bad}")

zip_sha = sha256(ZIP)
(ROOT / "SHA256SUMS.txt").write_text(f"{zip_sha}  {ZIP.name}\n", encoding="utf-8")
print(f"Built {ZIP.name}: {ZIP.stat().st_size} bytes")
print(f"SHA-256: {zip_sha}")
