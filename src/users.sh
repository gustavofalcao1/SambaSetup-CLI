#!/bin/bash

x="start"

LOGFILE="./logs/samba.log"

log_message() {
  echo "$(date +'%Y-%m-%d %H:%M:%S') - $1" >> $LOGFILE
}

menu ()
{
while true $x != "start"
do
clear
echo "=============================================================================================="
echo "                                   SAMBA"
echo "=============================================================================================="
echo ""
echo "------------------------------------------"
echo "    List Server Users           - 1"
echo "------------------------------------------"
echo "------------------------------------------"
echo "    Add Server User             - 2"
echo "------------------------------------------"
echo "------------------------------------------"
echo "    Delete Server User          - 3"
echo "------------------------------------------"
echo "------------------------------------------"
echo "    Return                      - 9"
echo "------------------------------------------"
echo "------------------------------------------"
echo "    Exit                        - 0"
echo "------------------------------------------"
echo ""
echo "Inform the menu option (number): "
read x
echo ""
echo "Menu option ($x)"
echo "=============================================================================================="
echo ""
echo "=============================================================================================="

case "$x" in

  1)
    echo ""
    echo "Server Users"
    echo ""
    sudo samba-tool user list
    echo ""
    echo "SUCCESS!"
    log_message "Server Users Listed"
    echo ""
    echo "Press <ENTER> for continue..."
    read p
;;
  2)
    echo ""
    echo "Enter the new user NAME to create: "
    read useradd
    echo ""
    echo "Enter the user PASSWORD: "
    read -s password
    echo ""
    echo "Creating user '$useradd'..."
    sudo samba-tool user create "$useradd" "$password"
    echo ""
    echo "SUCCESS!"
    log_message "Server Users Created"
    echo ""
    echo "Press <ENTER> for continue..."
    read p
;;
  3)
    echo ""
    echo "Enter the user NAME to delete: "
    read userdel
    echo ""
    echo "The user '$userdel' and all their data will be DELETED. Are you sure? "
    echo "[y]es or [n]o: "
    read sure
    echo ""
    if [ "$sure" == 'y' ]; then 
      sudo samba-tool user delete "$userdel"
      echo ""
      echo "SUCCESS!!!"
    else
      echo "Operation canceled."
    fi
    log_message "Server Users Deleted"
    echo ""
    echo "Press <ENTER> for continue..."
    read p
;;
  9)
    echo ""
    echo "Returning..."
    echo ""
    src/server.sh
    exit
    echo ""
    sleep 1
;;
  0)
    echo ""
    echo "Exiting..."
    echo ""
    clear
    exit
    echo ""
    sleep 1
;;
  *)
    echo "Invalid option!"
esac
done
}

menu
