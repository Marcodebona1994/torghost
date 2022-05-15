#!/bin/bash

[[ $(id -u) -eq 0 ]] || {
        echo "You must be root to run this script. Exit"
        exit 1
}


TIME=$(date '+%H:%M:%S')

function usage(){
        echo "
  #####   ####   #####    ####   #    #   ####    #####
    #    #    #  #    #  #    #  #    #  #    #     #
    #    #    #  #    #  #       ######  #    #     #
    #    #    #  #####   #  ###  #    #  #    #     #
    #    #    #  #   #   #    #  #    #  #    #     #
    #     ####   #    #   ####   #    #   ####      #
  
  github.com/marcodebona1994/torghost
"
        echo  "Torghost usage:
    -s, --start       # Start Torghost
    -r, --switch      # Request new tor exit node
    -x, --stop        # Stop Torghost
    -h  --help
    -b  --backup      # Create backup for restoring networking system
    -r  --restore     # Restore backup configuration
    "

}

function get_public_ip(){
        public_ip=$(curl -s ifconfig.me)

        if [[ "$public_ip" =~ ^(([1-9]?[0-9]|1[0-9][0-9]|2([0-4][0-9]|5[0-5]))\.){3}([1-9]?[0-9]|1[0-9][0-9]|2([0-4][0-9]|5[0-5]))$ ]]; then
                echo $public_ip
        else
                echo "Unable to get public ip. Check your internet connection status. Resource ifconfig.me"
                exit 1
        fi
}


function start(){
        echo ""
        echo " Fetching current IP..."
        public_ip=$(get_public_ip)
        echo " Current IP:  $public_ip"
        echo "Replacing  /opt/torghost/conf/torghostrc -> /etc/tor/torghostrc" 
        cp -p /opt/torghost/conf/torghostrc /etc/tor/torghostrc
        echo "Replacing /opt/torghost/conf/resolv.conf -> /etc/resolv.conf " 
        cp -p /opt/torghost/conf/torghost_resolv.conf /etc/resolv.conf
        echo "Stopping tor service"
        service tor stop
        fuser -k 9051/tcp > /dev/null 2>&1
        echo "Starting new tor daemon"
        sudo -u debian-tor tor -f /etc/tor/torghostrc > /dev/null
        echo "setting up iptables rules"
        chmod +x /opt/torghost/conf/iptables_setup.sh
        /opt/torghost/conf/iptables_setup.sh
        
        echo "Torghost is running"
        echo " Fetching current IP..."
        public_ip=$(get_public_ip)
        echo " TOR EXIT NODE IP:  $public_ip"
        
}
 
function stop(){
        echo " Stopping torghost"
        echo " Flushing iptables, resetting to default"
        iptables -P INPUT ACCEPT
        iptables -P FORWARD ACCEPT
        iptables -P OUTPUT ACCEPT
        iptables -t nat -F
        iptables -t mangle -F
        iptables -F
        iptables -X
        echo " Restoring default resolv.conf configuration"
        cp -p /opt/torghost/conf/default_resolv.conf /etc/resolv.conf
        service tor stop
        fuser -k 9051/tcp > /dev/null 2>&1
        echo " Restarting Network manager"
        service networking restart
        echo " Fetching current IP..."
        sleep 3
        public_ip=$(get_public_ip)
        echo " Current IP:  $public_ip"

}

function backup(){
        bck_time=$(date "+%F_%R")
        echo "Creating backup folders on /opt/torghost/backup"
        mkdir -p /opt/torghost/backup/iptables/
        mkdir -p /opt/torghost/backup/resolv.conf.d
        echo "Saving /etc/resolv.conf -> /opt/torghost/backup/resolv.conf.d/resolv.conf.$bck_time.bak"
        cp -p /etc/resolv.conf /opt/torghost/backup/resolv.conf.d/resolv.conf.$bck_time.bak     
        echo "Saving iptables rules on /opt/torghost/backup/iptables/iptables_bck_$bck_time.fw"
        iptables-save | tee /opt/torghost/backup/iptables/iptables_bck_$bck_time.fw > /dev/null

}

function new_circuit(){
        echo ""
}
 
function restore(){
        iptables_restore="/opt/torghost/backup/iptables/$1"
        resolv_restore="/opt/torghost/backup/resolv.conf.d/$2"  
        if [ -f "$iptables_restore" ]; then
                echo "Selected iptables backup  $iptables_restore."
        else 
                echo "Unable to find $iptables_restore config file."
                echo "Pass as second parameter an iptables backup. Check them on /opt/torghost/backup/iptables/"
                echo "Example: torghost --restore <iptables_bck> <resolv_conf_bck>"
                exit 1
        fi
        
        if [ -f "$resolv_restore" ]; then
                echo "Selected resolv.conf backup  $resolv_restore."
        else 
                echo "Unable to find $resolv_restore config file."
                echo "Pass as third parameter an iptables backup. Check them on /opt/torghost/backup/resolv_conf.d/"
                echo "Example: torghost --restore <iptables_bck> <resolv_conf_bck>"
                exit 1
        fi
        
        read -p "Are you sure that you whant to continue (y/n)?" choice
        case "$choice" in 
          y|Y ) echo "Restore in progress"
                echo "Restoring $iptables_restore"      
                iptables-restore < $iptables_restore
                echo "Restoring $resolv_restore -> /etc/resolv.conf"    
                cp -p $resolv_restore /etc/resolv.conf
                echo "Restarting network manager"
                sudo fuser -k 9051/tcp > /dev/null 2>&1
                sudo service network-manager restart
                ;;
          n|N ) echo "Restore canceled"
                exit 0;;
          * ) echo "Input invalid";;
        esac
        
}

case "$1" in
        "-h" | "--help")
                usage
                ;;
        "-b" | "--backup")
                backup
        ;;
        "-r" | "--restore")
                restore $2 $3
        ;;
        "-s" | "--start")
                start
        ;;
        "-x" | "--stop")
                stop
        ;;
        *) 
                usage
        ;;
esac



