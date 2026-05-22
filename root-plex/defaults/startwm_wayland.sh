#!/usr/bin/env bash

# LinuxServer Selkies Wayland desktop launcher.
# Keep this close to upstream baseimage-selkies. svc-selkies provides the stream,
# svc-de calls this after the Wayland socket exists.

ulimit -c 0
export XCURSOR_THEME=whiteglass
export XCURSOR_SIZE=24
export XKB_DEFAULT_LAYOUT=us
export XKB_DEFAULT_RULES=evdev
export WAYLAND_DISPLAY=wayland-1

if [ "${SELKIES_DESKTOP}" == "true" ]; then
  labwc > /tmp/labwc.log 2>&1 &
  sleep 1
  export WAYLAND_DISPLAY=wayland-0
  export DISPLAY=:0
  selkies-desktop
else
  exec labwc > /tmp/labwc.log 2>&1
fi
