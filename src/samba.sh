#!/bin/bash

# =============================================================================
# Samba AD DC Setup and Management Script
# =============================================================================
# 
# Este script gerencia a configuração e administração de um Controlador de Domínio
# Samba Active Directory (AD DC). Ele fornece funcionalidades para:
#   - Instalação inicial do DC
#   - Limpeza e reinicialização do ambiente
#   - Gerenciamento de compartilhamentos
#   - Monitoramento de status e logs
#
# Requisitos:
#   - Ubuntu 22.04 ou superior
#   - Samba 4.19.x ou superior
#   - Privilégios de root/sudo
#
# Autor: Codeium
# Data: 30/12/2023
# =============================================================================

# Configurações e variáveis globais
SAMBA_CONF="/etc/samba/smb.conf"
SAMBA_LIB="/var/lib/samba"
SAMBA_LOG="/var/log/samba"
SAMBA_RUN="/run/samba"
SCRIPT_LOG="/var/log/samba_script.log"

# Função para logging
log_message() {
    local message=$1
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] $message" >> "$SCRIPT_LOG"
    echo "[$timestamp] $message"
}

# Função para verificar erros
check_error() {
    if [ $? -ne 0 ]; then
        log_message "ERRO: $1"
        return 1
    fi
    return 0
}

# Função para limpar o ambiente Samba completamente
clean_samba_environment() {
    log_message "Iniciando limpeza do ambiente Samba..."
    
    # Parar e desabilitar serviços
    systemctl stop samba-ad-dc smbd nmbd winbind
    systemctl disable samba-ad-dc smbd nmbd winbind
    
    # Backup de arquivos importantes
    if [ -d "$SAMBA_LIB/private" ]; then
        mkdir -p /root/samba_backup
        cp -r "$SAMBA_LIB/private" /root/samba_backup/
        log_message "Backup dos arquivos privados criado em /root/samba_backup"
    fi
    
    # Limpar diretórios
    rm -rf "$SAMBA_CONF"
    rm -rf "$SAMBA_LIB"/*
    rm -rf "$SAMBA_LOG"/*
    rm -rf "$SAMBA_RUN"/*
    
    # Recriar estrutura de diretórios com permissões corretas
    mkdir -p /etc/samba
    mkdir -p "$SAMBA_LIB"/{private,sysvol}
    mkdir -p "$SAMBA_LOG"
    mkdir -p "$SAMBA_RUN"/ncalrpc/np
    
    # Configurar permissões
    chown -R root:root /etc/samba "$SAMBA_LIB" "$SAMBA_LOG" "$SAMBA_RUN"
    chmod -R 755 /etc/samba "$SAMBA_LIB" "$SAMBA_LOG" "$SAMBA_RUN"
    chmod 700 "$SAMBA_LIB/private"
    
    log_message "Ambiente Samba limpo com sucesso"
}

# Função para configurar o Samba AD DC
configure_samba() {
    local realm=$1
    local domain=${realm%%.*}
    local password=$2
    local ip_address=$3
    
    log_message "Iniciando configuração do Samba AD DC..."
    log_message "Realm: $realm"
    log_message "Domain: $domain"
    log_message "IP Address: $ip_address"
    
    # Limpar ambiente primeiro
    clean_samba_environment
    
    # Criar smb.conf inicial
    log_message "Criando configuração inicial do Samba..."
    tee "$SAMBA_CONF" > /dev/null << EOL
[global]
    workgroup = ${domain}
    realm = ${realm}
    netbios name = SV-EPG00
    server role = active directory domain controller
    dns forwarder = 8.8.8.8
    server services = rpc, nbt, wrepl, ldap, cldap, kdc, drepl, winbindd, ntp_signd, kcc, dnsupdate, dns
    dcerpc endpoint servers = epmapper, wkssvc, samr, netlogon, lsarpc
    interfaces = lo eth0
    bind interfaces only = yes
    log level = 3
    log file = /var/log/samba/log.%m
    max log size = 50

[netlogon]
    path = /var/lib/samba/sysvol/${realm}/scripts
    read only = No

[sysvol]
    path = /var/lib/samba/sysvol
    read only = No
EOL
    
    # Provisionar domínio
    log_message "Provisionando domínio..."
    samba-tool domain provision \
        --server-role=dc \
        --use-rfc2307 \
        --dns-backend=SAMBA_INTERNAL \
        --realm="$realm" \
        --domain="$domain" \
        --adminpass="$password" \
        --option="interfaces=lo eth0" \
        --option="bind interfaces only=yes"
    
    if ! check_error "Falha no provisionamento do domínio"; then
        return 1
    fi
    
    # Configurar Kerberos
    log_message "Configurando Kerberos..."
    cp "$SAMBA_LIB/private/krb5.conf" /etc/krb5.conf
    
    # Ajustar permissões finais
    chmod 700 "$SAMBA_LIB/private"
    chmod 750 "$SAMBA_LIB/ntp_signd"
    chmod -R 755 "$SAMBA_LIB/sysvol"
    
    # Configurar DNS
    log_message "Configurando DNS..."
    cp /etc/resolv.conf /etc/resolv.conf.bak
    tee /etc/resolv.conf > /dev/null << EOF
domain $realm
nameserver 127.0.0.1
nameserver 8.8.8.8
EOF
    
    # Reiniciar serviços
    log_message "Reiniciando serviços..."
    systemctl daemon-reload
    systemctl enable samba-ad-dc
    systemctl start samba-ad-dc
    
    # Verificar status
    if systemctl is-active --quiet samba-ad-dc; then
        log_message "Samba AD DC configurado e iniciado com sucesso"
    else
        log_message "ERRO: Falha ao iniciar o Samba AD DC"
        return 1
    fi
    
    # Testar funcionalidades básicas
    log_message "Testando funcionalidades básicas..."
    samba-tool domain level show
    host -t SRV _ldap._tcp."$realm"
    
    log_message "Configuração completa"
    return 0
}

# Função para configurar compartilhamentos
configure_shares() {
    local share_name=$1
    local share_path=$2
    
    log_message "Configurando compartilhamento: $share_name"
    
    # Criar diretório do compartilhamento
    mkdir -p "$share_path"
    chmod 2775 "$share_path"
    chown root:"domain users" "$share_path"
    
    # Adicionar configuração ao smb.conf
    tee -a "$SAMBA_CONF" > /dev/null << EOL

[$share_name]
    path = $share_path
    read only = No
    browseable = Yes
    inherit acls = Yes
    inherit permissions = Yes
EOL
    
    # Verificar configuração
    testparm -s
    if ! check_error "Configuração do compartilhamento inválida"; then
        return 1
    fi
    
    # Reiniciar serviço
    systemctl restart samba-ad-dc
    log_message "Compartilhamento $share_name configurado com sucesso"
}

# Função para mostrar status
show_status() {
    log_message "Verificando status do Samba..."
    
    echo "=== Status do Serviço ==="
    systemctl status samba-ad-dc
    
    echo -e "\n=== Últimas 20 linhas do log ==="
    tail -n 20 "$SAMBA_LOG/log.samba"
    
    echo -e "\n=== Verificação do DNS ==="
    host -t SRV _ldap._tcp.EPAD.GAIA
    
    echo -e "\n=== Nível do Domínio ==="
    samba-tool domain level show
}

# Menu principal
while true; do
    echo -e "\n=== Menu do Samba AD DC ==="
    echo "1) Configurar Samba Domain Controller"
    echo "2) Limpar e Resetar Samba"
    echo "3) Configurar Compartilhamento"
    echo "4) Mostrar Status"
    echo "5) Ver Logs"
    echo "6) Sair"
    read -p "Escolha uma opção: " choice
    
    case $choice in
        1)
            read -p "Enter realm (e.g., EXAMPLE.COM): " realm
            read -s -p "Enter administrator password: " password
            echo
            read -p "Enter IP address: " ip_address
            configure_samba "$realm" "$password" "$ip_address"
            ;;
        2)
            read -p "Tem certeza que deseja limpar o ambiente Samba? (s/N) " confirm
            if [ "${confirm,,}" = "s" ]; then
                clean_samba_environment
            fi
            ;;
        3)
            read -p "Nome do compartilhamento: " share_name
            read -p "Caminho do compartilhamento: " share_path
            configure_shares "$share_name" "$share_path"
            ;;
        4)
            show_status
            ;;
        5)
            tail -f "$SAMBA_LOG/log.samba"
            ;;
        6)
            log_message "Encerrando script"
            exit 0
            ;;
        *)
            echo "Opção inválida"
            ;;
    esac
done
