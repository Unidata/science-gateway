#!/bin/bash

mkdir -p "/home/$NB_USER/Desktop/"
cp /usr/local/share/applications/IDV.desktop "/home/$NB_USER/Desktop/IDV.desktop"
cp /usr/local/share/applications/cave.desktop "/home/$NB_USER/Desktop/cave.desktop"

# Must have this, otherwise there is a snafu about trying to connect to server
# hidden behind the AWIPS splash screen
CAVE_PREFS_DIR=~/caveData/.metadata/.plugins/org.eclipse.core.runtime/.settings
CAVE_PREFS_FILE="$CAVE_PREFS_DIR/localization.prefs"

if [ ! -f "$CAVE_PREFS_FILE" ]; then
  mkdir -p "$CAVE_PREFS_DIR"

  cat <<EOF > "$CAVE_PREFS_FILE"
alertServer=tcp\\://localhost\\:61998
eclipse.preferences.version=1
httpServerAddress=http\\://edex-beta.unidata.ucar.edu\\:9581/services
httpServerAddressOptions=http\\://edex-beta.unidata.ucar.edu\\:9581/services
siteName=OAX
EOF
fi
