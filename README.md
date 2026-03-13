# Docker Webtop VSCode

Arch Linux KDE Plasma Desktop mit VS Code, basierend auf [linuxserver/baseimage-selkies](https://github.com/linuxserver/docker-baseimage-selkies).

## Features

- **Arch Linux** auf dem aktuellsten Stand (`pacman -Syu` beim Build)
- **KDE Plasma Desktop** als vollwertiger Desktop
- **Visual Studio Code** vorinstalliert (GitHub Copilot ready)
- **Chromium & Firefox** Browser
- **Selkies WebRTC** Streaming via Browser

## Quick Start

```bash
docker pull ghcr.io/serph91p/docker-webtop-vscode:latest
```

```bash
docker run -d \
  --name=webtop-vscode \
  --security-opt seccomp=unconfined \
  -e PUID=1000 \
  -e PGID=1000 \
  -e TZ=Europe/Berlin \
  -v ./config:/config \
  -p 3000:3000 \
  -p 3001:3001 \
  --shm-size="2gb" \
  --restart unless-stopped \
  ghcr.io/serph91p/docker-webtop-vscode:latest
```

Oder mit Docker Compose:

```bash
docker compose up -d
```

Erreichbar unter **https://localhost:3001** (oder http://localhost:3000).

## VS Code + GitHub Copilot

1. Im KDE Desktop VS Code starten (Anwendungsmenü oder `code --no-sandbox`)
2. Extensions → "GitHub Copilot" installieren
3. Mit GitHub Account anmelden

Extensions und Einstellungen bleiben im `/config` Volume persistent.

## Environment Variables

| Variable | Beschreibung | Default |
|---|---|---|
| `PUID` | User ID | `1000` |
| `PGID` | Group ID | `1000` |
| `TZ` | Timezone | `Europe/Berlin` |
| `PASSWORD` | HTTP Basic Auth Passwort | (kein Auth) |
| `CUSTOM_USER` | HTTP Basic Auth User | `abc` |
| `TITLE` | Browser Tab Titel | `Arch KDE VSCode` |

Weitere Optionen siehe [Selkies Base Image Docs](https://github.com/linuxserver/docker-baseimage-selkies).

## GPU Acceleration

### Intel/AMD (DRI3)
```bash
docker run ... --device /dev/dri:/dev/dri ...
```

### Nvidia
```bash
docker run ... --gpus all --runtime nvidia ...
```
