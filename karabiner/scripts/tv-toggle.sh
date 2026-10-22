#!/bin/sh
# Toggle the LG TV between HDMI_1 (Mac) and HDMI_2. From any other input, go to HDMI_1.
# Karabiner runs this without HOME or PATH, so every path is absolute.
LG="/Users/emilio/.local/bin/bscpylgtvcommand -p /Users/emilio/.aiopylgtv.sqlite 192.168.50.117"

if [ "$($LG get_input)" = "com.webos.app.hdmi1" ]; then
    $LG set_input HDMI_2
else
    $LG set_input HDMI_1
fi
