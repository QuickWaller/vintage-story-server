FROM mcr.microsoft.com/dotnet/runtime:8.0 AS dotnet8
FROM mcr.microsoft.com/dotnet/runtime:10.0

ENV STABLE_URL="https://cdn.vintagestory.at/gamefiles/stable/vs_server_linux-x64_"
ENV UNSTABLE_URL="https://cdn.vintagestory.at/gamefiles/unstable/vs_server_linux-x64_"

# Graft the .NET 8 runtime into the .NET 10 installation directory
# so dotnet host can find both runtimes under /usr/share/dotnet/
COPY --from=dotnet8 /usr/share/dotnet/shared/Microsoft.NETCore.App \
    /usr/share/dotnet/shared/Microsoft.NETCore.App

# Install required packages
RUN rm -f /etc/apt/apt.conf.d/docker-clean && \
    echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' > /etc/apt/apt.conf.d/keep-cache
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update && apt-get install -y --no-install-recommends \
        cron \
        jq \
        wget \
    && rm -rf /var/lib/apt/lists/*

# Rename the existing ubuntu user (UID 1000) rather than creating a new one,
# preserving compatibility with existing volume mounts
RUN usermod -l gameserver -s /sbin/nologin -d /srv/gameserver ubuntu && \
    groupmod -n gameserver ubuntu

# Create necessary directories and set ownership
RUN mkdir -p /srv/gameserver/vintagestory \
    /srv/gameserver/data/vs && \
    chown -R gameserver:gameserver /srv/gameserver

WORKDIR /srv/gameserver/vintagestory

# Copy scripts into the container
COPY scripts/download_server.sh /srv/gameserver/vintagestory/
COPY scripts/check_and_start.sh /srv/gameserver/vintagestory/
COPY scripts/entrypoint.sh /srv/gameserver/vintagestory/
COPY scripts/backup.sh /srv/gameserver/vintagestory/
COPY scripts/log-rotate.sh /srv/gameserver/vintagestory/
COPY scripts/crontab /srv/gameserver/vintagestory/

RUN chmod +x /srv/gameserver/vintagestory/*.sh && \
    chown -R gameserver:gameserver /srv/gameserver/vintagestory

EXPOSE 1079

ENTRYPOINT ["/srv/gameserver/vintagestory/entrypoint.sh"]
