#!/bin/bash

if [ -z "$VERSION" ]; then
    echo "ERROR: VERSION environment variable must be set"
    exit 1
fi

# Check if we need to download/update server files
if [ ! -f VintagestoryServer.dll ] || [ ! -f current_version ] || [ "$(cat current_version)" != "$VERSION" ]; then
    ./download_server.sh
fi

# Check latest versions
STABLE_JSON=$(wget -qO- https://api.vintagestory.at/stable.json)
LATEST_STABLE=$(echo "$STABLE_JSON" | jq -r 'keys_unsorted[0]')
UNSTABLE_JSON=$(wget -qO- https://api.vintagestory.at/unstable.json)
LATEST_UNSTABLE=$(echo "$UNSTABLE_JSON" | jq -r 'keys_unsorted[0]')

# Check if stable version
if wget --spider -q "${STABLE_URL}${VERSION}.tar.gz" 2>/dev/null; then
    if [ "$VERSION" != "$LATEST_STABLE" ]; then
        echo "NOTE: You are running stable version ${VERSION} but version ${LATEST_STABLE} is available!"
    else
        echo "NOTE: Current version ${VERSION} is the latest stable version"
    fi
else
    if [ "$VERSION" != "$LATEST_UNSTABLE" ]; then
        echo "NOTE: You are running unstable version ${VERSION} but version ${LATEST_UNSTABLE} is available!"
    else
        echo "NOTE: Current version ${VERSION} is the latest unstable version"
    fi
fi

# Download mods listed in MODS env var (comma-separated mod IDs from mods.vintagestory.at)
if [ -n "$MODS" ]; then
    mkdir -p /srv/gameserver/data/vs/Mods
    for MOD_ID in $(echo "$MODS" | tr ',' ' '); do
        MOD_ID=$(echo "$MOD_ID" | xargs)
        MOD_JSON=$(wget -qO- "https://mods.vintagestory.at/api/mod/${MOD_ID}")
        FILENAME=$(echo "$MOD_JSON" | jq -r '.mod.releases[0].filename')
        MAINFILE=$(echo "$MOD_JSON" | jq -r '.mod.releases[0].mainfile')
        if [ -z "$FILENAME" ] || [ "$FILENAME" = "null" ]; then
            echo "WARNING: Could not find mod '${MOD_ID}' on mods.vintagestory.at — skipping"
            continue
        fi
        if [ -f "/srv/gameserver/data/vs/Mods/${FILENAME}" ]; then
            echo "Mod already present, skipping: ${FILENAME}"
            continue
        fi
        # Use full URL if provided, otherwise prefix with base domain
        if echo "$MAINFILE" | grep -q "^http"; then
            DOWNLOAD_URL="$MAINFILE"
        else
            DOWNLOAD_URL="https://mods.vintagestory.at${MAINFILE}"
        fi
        echo "Downloading mod: ${FILENAME}"
        if wget -q "$DOWNLOAD_URL" -O "/srv/gameserver/data/vs/Mods/${FILENAME}"; then
            if [ ! -s "/srv/gameserver/data/vs/Mods/${FILENAME}" ]; then
                echo "WARNING: Downloaded file for '${MOD_ID}' is empty — removing"
                rm -f "/srv/gameserver/data/vs/Mods/${FILENAME}"
            fi
        else
            echo "WARNING: Failed to download mod '${MOD_ID}' — removing partial file"
            rm -f "/srv/gameserver/data/vs/Mods/${FILENAME}"
        fi
    done
fi

exec dotnet VintagestoryServer.dll --dataPath /srv/gameserver/data/vs
