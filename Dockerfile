FROM ghcr.io/linuxserver/baseimage-selkies:arch

# set version label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="Custom Arch KDE + VSCode image - Build-date:- ${BUILD_DATE}"
LABEL maintainer="max.ebert"

# title
ENV TITLE="Arch KDE VSCode" \
    NO_GAMEPAD=true

RUN \
  echo "**** update system to latest ****" && \
  pacman -Syu --noconfirm && \
  echo "**** add icon ****" && \
  curl -o \
    /usr/share/selkies/www/icon.png \
    https://raw.githubusercontent.com/linuxserver/docker-templates/master/linuxserver.io/img/webtop-logo.png && \
  echo "**** install KDE packages ****" && \
  pacman -S --noconfirm --needed \
    cargo \
    chromium \
    dolphin \
    firefox \
    kate \
    konsole \
    kwin-x11 \
    plasma-desktop \
    plasma-x11-session && \
  cargo install \
    wl-clipboard-rs-tools && \
  echo "**** replace wl-clipboard with rust ****" && \
  mv \
    /config/.cargo/bin/wl-* \
    /usr/bin/ && \
  echo "**** install VS Code ****" && \
  curl -o /tmp/code.tar.gz -L \
    "https://update.code.visualstudio.com/latest/linux-x64/stable" && \
  mkdir -p /opt/vscode && \
  tar -xzf /tmp/code.tar.gz -C /opt/vscode --strip-components=1 && \
  ln -s /opt/vscode/bin/code /usr/local/bin/code && \
  echo "**** install VS Code dependencies ****" && \
  pacman -S --noconfirm --needed \
    libxkbfile \
    nss \
    libsecret \
    gnome-keyring && \
  echo "**** application tweaks ****" && \
  sed -i \
    's#^Exec=.*#Exec=/usr/local/bin/wrapped-chromium#g' \
    /usr/share/applications/chromium.desktop && \
  setcap -r \
    /usr/sbin/kwin_wayland && \
  echo "**** kde tweaks ****" && \
  sed -i \
    's/applications:org.kde.discover.desktop,/applications:org.kde.konsole.desktop,/g' \
    /usr/share/plasma/plasmoids/org.kde.plasma.taskmanager/contents/config/main.xml && \
  echo "**** create VS Code desktop entry ****" && \
  mkdir -p /usr/share/applications && \
  printf '%s\n' \
    '[Desktop Entry]' \
    'Name=Visual Studio Code' \
    'Comment=Code Editing. Redefined.' \
    'GenericName=Text Editor' \
    'Exec=/usr/local/bin/code --no-sandbox --unity-launch %F' \
    'Icon=/opt/vscode/resources/app/resources/linux/code.png' \
    'Type=Application' \
    'StartupNotify=false' \
    'StartupWMClass=Code' \
    'Categories=TextEditor;Development;IDE;' \
    'MimeType=text/plain;inode/directory;' \
    'Keywords=vscode;' \
    > /usr/share/applications/code.desktop && \
  echo "**** cleanup ****" && \
  rm -rf \
    /config/.cache \
    /config/.cargo \
    /tmp/* \
    /var/cache/pacman/pkg/* \
    /var/lib/pacman/sync/*

# add local files
COPY /root /

# ports and volumes
EXPOSE 3000

VOLUME /config
