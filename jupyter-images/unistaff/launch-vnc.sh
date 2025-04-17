#!/bin/bash
set -e

export DISPLAY=${DISPLAY:-:1}
export VD_OUT="$HOME/.virtual-desktop.out"
export VD_ERR="$HOME/.virtual-desktop.err"

echo "[[ INFO ]] Starting Virtual Desktop as $(whoami): $(date '+%F %T')" | tee -a "$VD_OUT" "$VD_ERR"

# Start virtual framebuffer
Xvfb $DISPLAY -screen 0 1280x800x16 >> "$VD_OUT" 2>> "$VD_ERR" &
sleep 2

# Start VNC server
x11vnc -display $DISPLAY -forever -repeat -shared >> "$VD_OUT" 2>> "$VD_ERR" &

# Launch desktop environment (backgrounded)
case "$DESKTOP_ENVIRONMENT" in
  xfce) startxfce4 & ;;
  *) startxfce4 & ;;
esac

# 🕵️ Wait for xfconfd and xfce4-panel to become available (robust loop, max 10 seconds)
echo "[[ INFO ]] Waiting for xfconfd and xfce4-panel to start..." | tee -a "$VD_OUT"
for i in {1..20}; do
    if pgrep -x xfconfd > /dev/null && pgrep -x xfce4-panel > /dev/null; then
        echo "[[ INFO ]] xfconfd and xfce4-panel detected." | tee -a "$VD_OUT"
        break
    fi
    sleep 0.5
done

# Apply XFCE desktop customizations
{
  echo "[[ INFO ]] Applying XFCE settings..." >> "$VD_OUT"

  # Hide "Home" and "File System" desktop icons
  xfconf-query -c xfce4-desktop -p /desktop-icons/file-icons/show-home --create -t bool -s false || \
  xfconf-query -c xfce4-desktop -p /desktop-icons/file-icons/show-home -s false || true

  xfconf-query -c xfce4-desktop -p /desktop-icons/file-icons/show-filesystem --create -t bool -s false || \
  xfconf-query -c xfce4-desktop -p /desktop-icons/file-icons/show-filesystem -s false || true

  # Autohide the Dock (bottom panel, panel-2)
  xfconf-query -c xfce4-panel -p /panels/panel-2/autohide-behavior --create -t int -s 2 || \
  xfconf-query -c xfce4-panel -p /panels/panel-2/autohide-behavior -s 2 || true
} >> "$VD_OUT" 2>> "$VD_ERR" || true

# Launch noVNC websocket proxy
${NOVNC_DIR}/utils/novnc_proxy --vnc localhost:5900 --listen 6080 >> "$VD_OUT" 2>> "$VD_ERR"

# Keep the script running
echo "[[ INFO ]] Waiting on background processes..." | tee -a "$VD_OUT"
wait -n
