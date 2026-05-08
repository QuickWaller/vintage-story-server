#!/usr/bin/env python3
"""
Downloads all client-required mods to client-mods/.
Run from the repo root: python download-client-mods.py

Server-only mods are skipped. Both-sided and client-only mods are downloaded.
Re-running is safe -- already-present zips are skipped.
Uses the same release selection as the server (latest release, no version filtering).
"""

import io
import json
import re
import sys
import urllib.request
from pathlib import Path

# Windows console safe output
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding="utf-8", errors="replace")

REPO_ROOT = Path(__file__).parent
MODS_DIR = REPO_ROOT / "client-mods"
COMPOSE_FILE = REPO_ROOT / "compose.yaml"
API_BASE = "https://mods.vintagestory.at/api/mod"


def read_compose():
    content = COMPOSE_FILE.read_text()
    version = re.search(r"VERSION=(\S+)", content).group(1)
    mods_line = re.search(r"MODS=(\S+)", content).group(1)
    mods = [m.strip() for m in mods_line.split(",")]
    return version, mods


def get_mod_info(mod_id):
    url = f"{API_BASE}/{mod_id}"
    with urllib.request.urlopen(url, timeout=15) as r:
        return json.load(r)


def download_file(url, dest):
    url = url.replace(" ", "%20")
    urllib.request.urlretrieve(url, dest)


def main():
    MODS_DIR.mkdir(exist_ok=True)
    version, mods = read_compose()
    print(f"VS version : {version}")
    print(f"Mods total : {len(mods)}\n")

    downloaded, already_present, skipped_server, no_release, errors = [], [], [], [], []

    for mod_id in mods:
        try:
            data = get_mod_info(mod_id)
            if data.get("statuscode") != "200":
                errors.append(mod_id)
                print(f"  [?] {mod_id}: not found in mod DB")
                continue

            mod = data["mod"]
            side = mod.get("side", "both")
            name = mod.get("name", mod_id)
            releases = mod.get("releases", [])

            if side == "server":
                skipped_server.append(mod_id)
                print(f"  [-] {name}: server-only, skipping")
                continue

            if not releases:
                no_release.append(mod_id)
                print(f"  [!] {name}: no releases found")
                continue

            release = releases[0]
            filename = release["filename"]
            dest = MODS_DIR / filename

            if dest.exists():
                already_present.append(mod_id)
                print(f"  [=] {name}: already present")
                continue

            print(f"  [>] {name}: downloading {filename} ...", end="", flush=True)
            download_file(release["mainfile"], dest)
            downloaded.append(mod_id)
            print(" done")

        except Exception as e:
            errors.append(mod_id)
            print(f"  [E] {mod_id}: {e}")

    print(f"""
Summary
-------
Downloaded      : {len(downloaded)}
Already present : {len(already_present)}
Server-only     : {len(skipped_server)}
No releases     : {len(no_release)}
Errors          : {len(errors)}
Output folder   : {MODS_DIR}
""")

    if errors:
        print("Errors:", ", ".join(errors))


if __name__ == "__main__":
    main()
