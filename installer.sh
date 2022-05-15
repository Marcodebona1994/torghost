#!/bin/bash

[[ $(id -u) -eq 0 ]] || {
        echo " [x] You must be root to run this script. Exit"
        exit 1
}

echo " [+] Torghost installer v3.0"

echo " [+] [+] Installing prerequisites "
apt-get update 1>/dev/null 2>&1
apt-get install tor -y 1>/dev/null 2>&1

echo " [+] [+] Creating /opt/torghost configuration folder "
mkdir -p /opt/torghost
rm -rf /opt/torghost/*
cp -r conf /opt/torghost
cp /etc/resolv.conf /opt/torghost/conf/default_resolv.conf

cp -p torghost.sh /usr/bin/torghost
if [ $? -eq 0 ]; then
    echo " [+] [+] [SUCCESS] Copied binary to /usr/bin"
else
    echo " [x] [ERROR] Unable to copy"
    exit 1
fi

echo " [+] Installation completed"
echo "

████████╗ ██████╗ ██████╗ ███████╗██╗   ██╗███████╗████████╗███████╗███╗   ███╗
╚══██╔══╝██╔═══██╗██╔══██╗██╔════╝╚██╗ ██╔╝██╔════╝╚══██╔══╝██╔════╝████╗ ████║
   ██║   ██║   ██║██████╔╝███████╗ ╚████╔╝ ███████╗   ██║   █████╗  ██╔████╔██║
   ██║   ██║   ██║██╔══██╗╚════██║  ╚██╔╝  ╚════██║   ██║   ██╔══╝  ██║╚██╔╝██║
   ██║   ╚██████╔╝██║  ██║███████║   ██║   ███████║   ██║   ███████╗██║ ╚═╝ ██║
   ╚═╝    ╚═════╝ ╚═╝  ╚═╝╚══════╝   ╚═╝   ╚══════╝   ╚═╝   ╚══════╝╚═╝     ╚═╝
                                                                               
  
github.com/marcodebona1994/torghost


"
echo  "Torghost usage:
    -s, --start            # Start Torghost
    -n, --new-circuit      # Request new tor exit node
    -x, --stop             # Stop Torghost
    -b  --backup           # Create backup for restoring networking system
    -h  --help"   
