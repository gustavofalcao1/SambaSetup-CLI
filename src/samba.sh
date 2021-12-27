#!/bin/bash

x="start"

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
echo "    Install / Update SAMBA      - 1"
echo "------------------------------------------"
echo "------------------------------------------"
echo "    Add User to SAMBA           - 2"
echo "------------------------------------------"
echo "------------------------------------------"
echo "    Create SAMBA Server         - 3"
echo "------------------------------------------"
echo "------------------------------------------"
echo "    List SAMBA Users            - 4"
echo "------------------------------------------"
echo "------------------------------------------"
echo "    Status SAMBA Server         - 5"
echo "------------------------------------------"
echo "------------------------------------------"
echo "    Restart SAMBA Server        - 6"
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
      echo "Install / Update all SAMBA packages..."
      echo ""
      sudo apt install libcups2 samba samba-common cups -y
      echo ""
echo ""
echo "=============================================================================================="
echo ""
echo "=============================================================================================="
;;
    2)
      echo ""
      echo "Enter the USER you want to add to SAMBA: "
      read sambauser
      echo ""
      sudo smbpasswd -a $sambauser
      echo ""
      echo "SUCCESS!"
      sleep 1
echo ""
echo "=============================================================================================="
echo ""
echo "=============================================================================================="
;;
    3)
      bkpdate=$(date +-'%F'-'%s')
      sudo cp /etc/samba/smb.conf /etc/samba/smb.conf$bkpdate.bkp 
      echo ""
      echo "Enter the SAMBA server NAME: "
      read nameserver
      echo ""
      echo "Enter a comment (or leave blank) for the SAMBA server: "
      read comment
      echo ""
      echo "Enter the directory for the SAMBA server, Ex.:(/home/server): "
      read path
      echo ""
      echo "Inform if the directory can be BROWSABLE: [yes] or [no]"
      read browsable
      echo ""
      echo "Inform if the file can be READ ONLY: [yes] or [no]"
      read readon
      echo ""
      echo "Inform if the server allows GUEST: [yes] or [no]"
      read guest
      echo ""
      echo "Enter the USER / GROUP that has permission to access this server: "
      read valid
      echo ""
      sudo echo "
        [$nameserver]
        comment = $comment
        path = $path
        browseable = $browsable
        read only = $readon
        guest ok = $guest
        valid users = @$valid
      " >> /etc/samba/smb.conf
      echo ""
      echo "SUCCESS!"
      sleep 1
echo ""
echo "=============================================================================================="
echo ""
echo "=============================================================================================="
;;
    4)
      echo ""
      sudo pdbedit -L -v
      echo ""
      echo "SUCCESS!"
      echo ""
      echo "Press <ENTER> for continue..."
      read p
echo ""
echo 
"=============================================================================================="
echo ""
echo "=============================================================================================="
;;
    5)
      echo ""
      sudo /etc/init.d/smbd status
      echo ""
      echo "SUCCESS!"
      echo ""
      echo "Press <ENTER> for continue..."
      read p
echo ""
echo 
"=============================================================================================="
echo ""
echo "=============================================================================================="
;;
    6)
      echo ""
      sudo /etc/init.d/smbd restart
      echo ""
      echo "SUCCESS!"
      echo ""
      sleep 1
echo ""
echo 
"=============================================================================================="
echo ""
echo "=============================================================================================="
;;
    9)
      echo ""
      echo "Returning..."
      echo ""
      src/server.sh
      exit
echo ""
echo "=============================================================================================="
echo ""
echo "=============================================================================================="
;;
    0)
      echo ""
      echo "Exiting..."
      echo ""
      clear
      exit
echo ""
echo "=============================================================================================="
echo ""
echo "=============================================================================================="
;;

*)
        echo "Invalid option!"
esac
done

}
menu
