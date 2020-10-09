#!/bin/sh

GROUPNAME="math"
USERNAME="math"
CONFIG_FILE="/home/sage/config/jupyter_notebook_config.py"

LUID=${LOCAL_UID:-0}
LGID=${LOCAL_GID:-0}

# Step down from host root to well-known nobody/nogroup user

if [ $LUID -eq 0 ]
then
    LUID=65534
fi
if [ $LGID -eq 0 ]
then
    LGID=65534
fi

# Create user and group

groupadd -o -g $LGID $GROUPNAME #>/dev/null 2>&1 ||
groupmod -o -g $LGID $GROUPNAME #>/dev/null 2>&1
useradd -o -m -u $LUID -g $GROUPNAME -s /bin/false $USERNAME #>/dev/null 2>&1 ||
usermod -o -u $LUID -g $GROUPNAME -s /bin/false $USERNAME #>/dev/null 2>&1

# Add sage user to group $GROUPNAME
usermod -a -G $GROUPNAME sage

# Copy default config, if not exist
if [ ! -f $CONFIG_FILE ]; then
    sudo -u sage cp /home/sage/install/jupyter_notebook_config.py $CONFIG_FILE
fi

# Start exec with user sage
exec gosu  sage:sage "$@"
