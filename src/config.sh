#!/bin/bash

x="start"

LOGFILE="./logs/config.log"

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
echo "    Update Server               - 1"
echo "------------------------------------------"
echo "------------------------------------------"
echo "    Reboot Server               - 2"
echo "------------------------------------------"
echo "------------------------------------------"
echo "    Configure Static IP         - 3"
echo "------------------------------------------"
echo "------------------------------------------"
echo "    Configure DNS (resolv.conf) - 4"
echo "------------------------------------------"
echo "------------------------------------------"
echo "    View Network Config         - 5"
echo "------------------------------------------"
echo "------------------------------------------"
echo "    Set Hostname and Domain     - 6"
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
    echo "Update all Server packages..."
    echo ""
    sudo apt update && sudo apt upgrade -y && sudo apt dist-upgrade -y && sudo apt autoremove -y && sudo apt clean
    echo ""
    echo "SUCCESS!"
    log_message "Updated server packages"
    echo ""
    echo "Press <ENTER> to continue..."
    read p
;;
  2)
    echo ""
    echo "Rebooting..."
    log_message "Server reboot initiated"
    echo ""
    sudo reboot
;;
  3) 
    bkpdate=$(date +-'%F'-'%s')
    sudo cp /etc/netplan/99-custom.yaml /etc/netplan/99-custom.yaml$bkpdate.bkp

    echo ""
    echo "Configuring Static IP..."
    ip link show | awk -F': ' '{print $2}' | grep -v '^lo$'
    echo "Enter the network interface (e.g., enp2s0): "
    read iface
    echo "Enter the static IP address (e.g., 192.168.1.181/24): "
    read ipaddr
    echo "Enter the gateway (e.g., 192.168.1.1): "
    read gateway
    echo "Enter the primary DNS server (e.g., 8.8.8.8): "
    read dns1
    echo "Enter the secondary DNS server (optional, e.g., 1.1.1.1): "
    read dns2
    echo "Enter the tertiary DNS server (optional, e.g., 9.9.9.9): "
    read dns3

    sudo bash -c "echo '
    network:
        version: 2
        ethernets:
            $iface:
                addresses:
                    - $ipaddr
                nameservers:
                    addresses:
                        - $dns1
                        ${dns2:+- $dns2}
                        ${dns3:+- $dns3}
                routes:
                    - to: default
                      via: $gateway
    ' > /etc/netplan/99-custom.yaml" -- "$iface" "$ipaddr" "$dns1" "$dns2" "$dns3" "$gateway"
    sudo netplan apply
    echo "Static IP and DNS configured!"
    echo ""
    echo "Press <ENTER> to continue..."
    read p
;;
  4)
    bkpdate=$(date +-'%F'-'%s')
    sudo cp /etc/resolv.conf /etc/resolv.conf$bkpdate.bkp
    echo ""
    echo "Configuring DNS (resolv.conf)..."
    echo "Enter the DNS server addresses (comma-separated, e.g., 8.8.8.8,8.8.4.4): "
    read dns

    sudo bash -c "echo -e 'nameserver $(echo $dns | sed 's/,/\n/g')' > /etc/resolv.conf"

    echo "resolv.conf configured!"
    log_message "Configured resolv.conf with DNS: $dns"
    echo ""
    echo "Press <ENTER> to continue..."
    read p
;;
  5)
    echo ""
    echo "Current Network Configuration:"
    ip a
    echo ""
    echo "Press <ENTER> to continue..."
    log_message "Viewed network configuration"
    read p
;;
  6)
    bkpdate=$(date +-'%F'-'%s')
    sudo cp /etc/hosts /etc/hosts$bkpdate.bkp
    echo ""
    echo "Setting Hostname and Domain..."
    echo ""
    echo "Acctual Hostname and FQDN:"
    echo ""
    hostname -f
    echo ""
    echo "Enter the new hostname: "
    read newhostname
    echo ""
    echo "Enter the FQDN (Fully Qualified Domain Name) for this host, if any (e.g., example.local):"
    read fqdn
    echo ""
    sudo hostnamectl set-hostname "$newhostname"
    echo "Updating /etc/hosts..."
    sudo sed -i "s/127.0.1.1.*/127.0.1.1 $newhostname/" /etc/hosts
    echo "Updated /etc/hosts with new hostname."
    if [ -n "$fqdn" ]; then
      echo "Updating /etc/hosts with FQDN..."
      sudo sed -i "/$newhostname/d" /etc/hosts
      echo "127.0.1.1 $newhostname"."$fqdn $newhostname" | sudo tee -a /etc/hosts > /dev/null
      echo "Updated /etc/hosts with FQDN."
    else
      echo "No FQDN provided. Only hostname is set."
    fi
    echo "Hostname set to $newhostname!"
    echo "Domain set to $newdomain!"
    log_message "Hostname and /etc/hosts set to $newhostname"
    log_message "Domain on /etc/hosts set to $newdomain"
    echo ""
    echo "Press <ENTER> to continue..."
    read p
;;
  9)
    echo ""
    echo "Returning..."
    echo ""
    src/server.sh
    exit
;;
  0)
    echo ""
    echo "Exiting..."
    echo ""
    clear
    exit
;;
  *)
    echo "Invalid option!"
esac
done

}
menu
