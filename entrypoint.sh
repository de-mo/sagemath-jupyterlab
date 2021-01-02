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

# Add user $USERNAME to group sage
usermod -a -G sage $GROUPNAME

# Change owner of directories host, config and install
chown -R $USERNAME:$GROUPNAME /home/sage/host
chown -R $USERNAME:$GROUPNAME /home/sage/config
chown -R $USERNAME:$GROUPNAME /home/sage/install

# Copy default config, if not exist (with user $USERNAME)
if [ ! -f $CONFIG_FILE ]; then
    sudo -u $USERNAME cp /home/sage/install/jupyter_notebook_config.py $CONFIG_FILE
fi

# Start exec with user $USERNAME:$GROUPNAME
exec gosu $USERNAME:$GROUPNAME "$@"
