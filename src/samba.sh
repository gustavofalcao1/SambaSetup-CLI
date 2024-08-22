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
echo "    Install SAMBA Services      - 1"
echo "------------------------------------------"
echo "------------------------------------------"
echo "    Configure SAMBA-AD-DC       - 2"
echo "------------------------------------------"
echo "------------------------------------------"
echo "    Configure Kerberos          - 3"
echo "------------------------------------------"
echo "------------------------------------------"
echo "    Status SAMBA Server         - 4"
echo "------------------------------------------"
echo "------------------------------------------"
echo "    Restart SAMBA Server        - 5"
echo "------------------------------------------"
echo "------------------------------------------"
echo "    AD DC Roaming Profile       - 6"
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
    echo "Install all SAMBA Services and Packages..."
    echo ""
    sudo apt install libcups2 samba samba-common samba-dsdb-modules samba-vfs-modules cups krb5-user winbind openssl -y
    echo ""
    echo "SUCCESS!"
    log_message "Installed SAMBA Services and Packages"
    echo ""
    echo "Press <ENTER> for continue..."
    read p
;;
  2)
    echo ""
    echo "Configuring Samba AD DC..."
    bkpdate=$(date +-'%F'-'%s')
    sudo cp /etc/samba/smb.conf /etc/samba/smb.conf$bkpdate.bkp

    sudo systemctl enable winbind
    sudo systemctl start winbind
    sudo systemctl restart smbd nmbd winbind samba-ad-dc
    sudo useradd -r -g samba -s /sbin/nologin samba
    sudo groupadd samba
    sudo chown -R samba:samba /var/lib/samba/sysvol
    sudo chmod 755 /var/lib/samba/sysvol

    hostname=$(hostname)
    fqdn=$(hostname -f)
    nameserver=$hostname
    realm=$(echo "$fqdn" | awk -F'.' '{print toupper($2"."$3)}')
    workgroup=$(echo "$realm" | awk -F'.' '{print $1}')

    echo "Check if SAMBA TLS certificates already exist..."
    if [ -f /etc/samba/tls/private_key.pem ] && [ -f /etc/samba/tls/certificate.crt ]; then
        echo "TLS certificates already exist."
        echo "Do you want to regenerate the certificates? (y/n): "
        read regenerate
        if [ "$regenerate" != "y" ]; then
            echo "Skipping certificate generation."
            regenerate_certificates=false
        else
            regenerate_certificates=true
        fi
    else
        regenerate_certificates=true
    fi

    if [ "$regenerate_certificates" = true ]; then
      echo "Generating SAMBA TLS certificates..."
      sudo bash -c "echo '
      [ req ]
        default_bits       = 2048
        distinguished_name = req_distinguished_name
        x509_extensions    = v3_ca
        req_extensions     = v3_req

      [ req_distinguished_name ]
        countryName            = Country Name (2 letter code)
        countryName_default    = US
        stateOrProvinceName    = State or Province Name (full name)
        stateOrProvinceName_default = State
        localityName           = Locality Name (e.g., city)
        localityName_default   = City
        organizationalUnitName = Organizational Unit Name (e.g., section)
        organizationalUnitName_default = IT
        commonName             = Common Name (e.g., server FQDN or YOUR name)
        commonName_default     = $fqdn
        commonName_max         = 64

      [ v3_ca ]
        subjectKeyIdentifier   = hash
        authorityKeyIdentifier = keyid:always,issuer:always
        basicConstraints       = CA:TRUE
        keyUsage                = keyCertSign, cRLSign

      [ v3_req ]
        basicConstraints       = CA:FALSE
        keyUsage                = digitalSignature, keyEncipherment
      ' > /tmp/openssl.cnf"

      sudo openssl genrsa -out /etc/samba/tls/private_key.pem 2048
      sudo openssl req -x509 -new -nodes -key /etc/samba/tls/private_key.pem -sha256 -days 365 -out /etc/samba/tls/certificate.crt -config /tmp/openssl.cnf
    echo "TLS certificates generated successfully."
    else
      echo "Continuing with existing TLS certificates."
    fi

    echo "Apply SAMBA settings..."
    sudo bash -c "echo '
    [global]
      netbios name = $nameserver
      realm = $realm
      workgroup = $workgroup
      server role = active directory domain controller
      idmap_ldb:use rfc2307 = yes
      log file = /var/log/samba/log.%m
      max log size = 1000
      panic action = /usr/share/samba/panic-action %d
      server string = $nameserver server (Samba, Ubuntu)
      log level = 3
      idmap config *: range = 1000000-1999999
      idmap config *: backend = tdb
      tls enabled = yes
      tls keyfile = /etc/samba/tls/private_key.pem
      tls certfile = /etc/samba/tls/certificate.crt

    [netlogon]
      path = /var/lib/samba/sysvol/$realm/scripts
      read only = no

    [sysvol]
      path = /var/lib/samba/sysvol
      read only = no

    [$nameserver]
      path = /var/lib/samba/sysvol
      read only = no
    ' > /etc/samba/smb.conf"
    echo "Generate SAMBA Domain..."
    echo ""
    echo "Enter the Domain Password: "
    read -s password
    sudo samba-tool domain provision \
    --use-rfc2307 \
    --server-role=dc \
    --dns-backend=SAMBA_INTERNAL \
    --domain=$workgroup \
    --realm=$realm \
    --adminpass=$password
    sudo systemctl restart smbd nmbd winbind samba-ad-dc
    testparm
    echo ""
    echo "SUCCESS! Samba AD DC configuration has been applied."
    echo ""
    log_message "Configured Samba AD DC with server name $nameserver and realm $realm"
    echo ""
    echo "Press <ENTER> to continue..."
    read p
;;
  3)
    bkpdate=$(date +-'%F'-'%s')
    sudo cp /etc/krb5.conf /etc/krb5.conf$bkpdate.bkp
    
    echo ""
    echo "Configuring Kerberos..."
    fqdn=$(hostname -f)
    realm=$(echo "$fqdn" | awk -F'.' '{print toupper($2"."$3)}')
    echo ""
    sudo bash -c "echo '
    [libdefaults]
      default_realm = $realm
      dns_lookup_realm = false
      dns_lookup_kdc = true

    [realms]
      $realm = {
        kdc = kerberos.$realm
        admin_server = kerberos.$realm
      }

    [domain_realm]
      .$realm = $realm
      $realm = $realm
    ' > /etc/krb5.conf" -- "$realm"

    echo "Kerberos configuration file created."
    echo ""
    log_message "Configured Kerberos for domain $realm"
    echo ""
    echo "Press <ENTER> to continue..."
    read p
;;
  4)
    echo ""
    sudo /etc/init.d/samba-ad-dc status
    echo ""
    echo "SUCCESS!"
    echo ""
    log_message "Checked Samba server status"
    echo ""
    echo "Press <ENTER> for continue..."
    read p
;;
  5)
    echo ""
    sudo /etc/init.d/smbd restart
    sudo systemctl restart smbd nmbd winbind samba-ad-dc
    echo ""
    echo "SUCCESS!"
    echo ""
    log_message "Restarted Samba server"
    echo ""
    sleep 1
;;
  6)
    echo ""
    echo "Setting up Roaming Profiles..."

    sudo mkdir -p /srv/samba/profiles
    sudo chmod 0770 /srv/samba/profiles
    sudo chown root:"Domain Users" /srv/samba/profiles

    sudo bash -c "echo '
    [profiles]
      path = /srv/samba/profiles
      read only = no
      browseable = no
      force create mode = 0600
      force directory mode = 0700
      csc policy = disable
      vfs objects = acl_xattr
    ' >> /etc/samba/smb.conf"

    sudo systemctl restart smbd nmbd winbind samba-ad-dc

    echo ""
    echo "SUCCESS!"
    echo ""
    log_message "Roaming Profiles configuration has been applied"
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
