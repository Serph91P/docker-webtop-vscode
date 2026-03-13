#!/bin/bash
ulimit -c 0

# Disable compositing and screen locking
if [ ! -f $HOME/.config/kwinrc ]; then
  kwriteconfig6 --file $HOME/.config/kwinrc --group Compositing --key Enabled false
fi
if [ ! -f $HOME/.config/kscreenlockerrc ]; then
  kwriteconfig6 --file $HOME/.config/kscreenlockerrc --group Daemon --key Autolock false
fi

# Power related
setterm blank 0
setterm powerdown 0

# Setup permissive clipboard rules
KWIN_RULES_FILE="$HOME/.config/kwinrulesrc"
RULE_DESC="wl-clipboard support"
if ! grep -q "$RULE_DESC" "$KWIN_RULES_FILE" 2>/dev/null; then
  echo "Applying KWin clipboard rule..."
  if command -v uuidgen &> /dev/null; then
    RULE_ID=$(uuidgen)
  else
    RULE_ID=$(cat /proc/sys/kernel/random/uuid)
  fi
  count=$(kreadconfig6 --file "$KWIN_RULES_FILE" --group General --key count --default 0)
  new_count=$((count + 1))
  kwriteconfig6 --file "$KWIN_RULES_FILE" --group General --key count "$new_count"
  existing_rules=$(kreadconfig6 --file "$KWIN_RULES_FILE" --group General --key rules)
  if [ -z "$existing_rules" ]; then
    new_rules="$RULE_ID"
  else
    new_rules="$existing_rules,$RULE_ID"
  fi
  kwriteconfig6 --file "$KWIN_RULES_FILE" --group General --key rules "$new_rules"
  kwriteconfig6 --file "$KWIN_RULES_FILE" --group "$RULE_ID" --key Description "$RULE_DESC"
  kwriteconfig6 --file "$KWIN_RULES_FILE" --group "$RULE_ID" --key clientmachine "localhost"
  kwriteconfig6 --file "$KWIN_RULES_FILE" --group "$RULE_ID" --key clientmachinematch 0
  kwriteconfig6 --file "$KWIN_RULES_FILE" --group "$RULE_ID" --key wmclass "wl-copy|wl-paste"
  kwriteconfig6 --file "$KWIN_RULES_FILE" --group "$RULE_ID" --key wmclassmatch 3
  kwriteconfig6 --file "$KWIN_RULES_FILE" --group "$RULE_ID" --key skippager true
  kwriteconfig6 --file "$KWIN_RULES_FILE" --group "$RULE_ID" --key skippagerrule 2
  kwriteconfig6 --file "$KWIN_RULES_FILE" --group "$RULE_ID" --key skiptaskbar true
  kwriteconfig6 --file "$KWIN_RULES_FILE" --group "$RULE_ID" --key skiptaskbarrule 2
  kwriteconfig6 --file "$KWIN_RULES_FILE" --group "$RULE_ID" --key minimizedrule 2
  kwriteconfig6 --file "$KWIN_RULES_FILE" --group "$RULE_ID" --key minimized true
fi

# Directories
sudo rm -f /usr/share/dbus-1/system-services/org.freedesktop.UDisks2.service
mkdir -p "${HOME}/.config/autostart" "${HOME}/.XDG" "${HOME}/.local/share/"
chmod 700 "${HOME}/.XDG"
touch "${HOME}/.local/share/user-places.xbel"

# Background perm loop
if [ ! -d $HOME/.config/kde.org ]; then
  (
    loop_end_time=$((SECONDS + 30))
    while [ $SECONDS -lt $loop_end_time ]; do
        find "$HOME/.cache" "$HOME/.config" "$HOME/.local" -type f -perm 000 -exec chmod 644 {} + 2>/dev/null
        sleep .1
    done
  ) &
fi
