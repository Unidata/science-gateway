#!/bin/bash
set -e

export DISPLAY=${DISPLAY:-:1}
export VD_OUT="$HOME/.virtual-desktop.out"
export VD_ERR="$HOME/.virtual-desktop.err"

echo "[[ INFO ]] Starting Virtual Desktop as $(whoami): $(date '+%F %T')" | tee -a "$VD_OUT" "$VD_ERR"

# Start virtual framebuffer
Xvfb $DISPLAY -screen 0 1024x768x16 >> "$VD_OUT" 2>> "$VD_ERR" &
sleep 2

# Start VNC server
x11vnc -display $DISPLAY -forever -repeat -shared >> "$VD_OUT" 2>> "$VD_ERR" &

# Launch desktop
case "$DESKTOP_ENVIRONMENT" in
  xfce) startxfce4 & ;;
  *) startxfce4 & ;;
esac

# Launch noVNC websocket proxy
${NOVNC_DIR}/utils/novnc_proxy --vnc localhost:5900 --listen 6080 >> "$VD_OUT" 2>> "$VD_ERR"

# Keep the script running
echo "[[ INFO ]] Waiting on background processes..." | tee -a "$VD_OUT"
wait -n
