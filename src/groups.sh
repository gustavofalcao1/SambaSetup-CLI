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
echo "    List Server Groups          - 1"
echo "------------------------------------------"
echo "------------------------------------------"
echo "    Add Server Group            - 2"
echo "------------------------------------------"
echo "------------------------------------------"
echo "    Delete Server Group         - 3"
echo "------------------------------------------"
echo "------------------------------------------"
echo "    Add User to Server Group    - 4"
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
    echo "Server Groups"
    echo ""
    sudo samba-tool group list
    echo ""
    echo "SUCCESS!"
    log_message "Server Group Listed"
    echo ""
    echo "Press <ENTER> for continue..."
    read p
;;
  2)
    echo ""
    echo "Enter the Group NAME to create: "
    read groupadd
    echo ""
    sudo samba-tool group add "$groupadd"
    echo ""
    echo "SUCCESS!"
    log_message "Server Group Created"
    echo ""
    echo "Press <ENTER> for continue..."
    read p
;;
  3)
    echo ""
    echo "Enter the Group NAME to delete: "
    read groupdel
    echo ""
    echo "The group '$groupdel' and all its data will be DELETED. Are you sure? "
    echo "[yes] or [no]: "
    read sure
    echo ""
    if [ "$sure" == 'yes' ]; then 
      sudo samba-tool group delete "$groupdel"
      echo ""
      echo "SUCCESS!!!"
    else
      echo "Operation canceled."
    fi
    log_message "Server Group Deleted"
    echo ""
    echo "Press <ENTER> for continue..."
    read p
;;
  4)
    echo ""
    echo "Enter the Group NAME: "
    read group
    echo ""
    echo "Enter the User NAME to ADD to $group: "
    read user
    echo ""
    sudo samba-tool group addmembers "$group" "$user"
    echo ""
    echo "SUCCESS!!!"
    log_message "Server User added to Group"
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
