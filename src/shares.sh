#!/bin/bash
# =============================================================================
# Share Management
# =============================================================================

# Import libraries
source "$(dirname "$0")/config/settings.conf"
source "$(dirname "$0")/lib/utils.sh"

# Create share function
create_share() {
    local share_name=$1
    local share_path=$2
    
    log_message "INFO" "Creating share: $share_name"
    
    # Create directory
    echo -e "\n${COLOR_CYAN}Creating share directory...${COLOR_RESET}"
    mkdir -p "$share_path"
    chmod 2775 "$share_path"
    chown root:"domain users" "$share_path"
    
    # Add to smb.conf
    echo -e "${COLOR_CYAN}Configuring share in smb.conf...${COLOR_RESET}"
    tee -a "${SAMBA_CONF}" > /dev/null << EOL

[$share_name]
    path = $share_path
    read only = No
    browseable = Yes
    inherit acls = Yes
    inherit permissions = Yes
EOL
    
    # Verify configuration
    echo -e "${COLOR_CYAN}Verifying configuration...${COLOR_RESET}"
    testparm -s
    if ! check_error "Invalid share configuration"; then
        return 1
    fi
    
    # Restart service
    echo -e "${COLOR_CYAN}Restarting Samba service...${COLOR_RESET}"
    systemctl restart samba-ad-dc
    log_message "INFO" "Share $share_name configured successfully"
    echo -e "${COLOR_GREEN}Share created successfully${COLOR_RESET}"
}

# Remove share function
remove_share() {
    local share_name=$1
    
    log_message "INFO" "Removing share: $share_name"
    
    # Backup smb.conf
    echo -e "\n${COLOR_CYAN}Creating backup of smb.conf...${COLOR_RESET}"
    cp "${SAMBA_CONF}" "${SAMBA_CONF}.bak"
    
    # Remove share section
    echo -e "${COLOR_CYAN}Removing share configuration...${COLOR_RESET}"
    sed -i "/\[$share_name\]/,/^$/d" "${SAMBA_CONF}"
    
    # Verify configuration
    echo -e "${COLOR_CYAN}Verifying configuration...${COLOR_RESET}"
    testparm -s
    if ! check_error "Invalid configuration after removing share"; then
        echo -e "${COLOR_RED}Configuration error detected, restoring backup...${COLOR_RESET}"
        cp "${SAMBA_CONF}.bak" "${SAMBA_CONF}"
        return 1
    fi
    
    # Restart service
    echo -e "${COLOR_CYAN}Restarting Samba service...${COLOR_RESET}"
    systemctl restart samba-ad-dc
    log_message "INFO" "Share $share_name removed successfully"
    echo -e "${COLOR_GREEN}Share removed successfully${COLOR_RESET}"
}

# List shares function
list_shares() {
    log_message "INFO" "Listing shares"
    echo -e "\n${COLOR_CYAN}Available Shares:${COLOR_RESET}"
    echo -e "${COLOR_CYAN}${SUBMENU_STYLE}${COLOR_RESET}"
    smbclient -L localhost -N
    echo -e "${COLOR_CYAN}${SUBMENU_STYLE}${COLOR_RESET}"
}

# Share permissions function
set_share_permissions() {
    local share_path=$1
    local group_name=$2
    local perms=$3
    
    log_message "INFO" "Setting permissions for share: $share_path"
    
    echo -e "\n${COLOR_CYAN}Setting ownership and permissions...${COLOR_RESET}"
    chown :"$group_name" "$share_path"
    chmod "$perms" "$share_path"
    
    if check_error "Failed to set permissions"; then
        echo -e "${COLOR_GREEN}Permissions set successfully${COLOR_RESET}"
    fi
}

# Shares menu
shares_menu() {
    while true; do
        show_menu "Share Management" \
            "Create New Share" \
            "Remove Share" \
            "List Shares" \
            "Configure Permissions"
        
        read -p "$(echo -e "${COLOR_BLUE}Select an option:${COLOR_RESET} ")" choice
        
        case $choice in
            1)
                echo -e "\n${COLOR_CYAN}Create New Share${COLOR_RESET}"
                echo -e "${COLOR_CYAN}${SUBMENU_STYLE}${COLOR_RESET}"
                read -p "Share name: " share_name
                read -p "Share path: " share_path
                create_share "$share_name" "$share_path"
                ;;
            2)
                echo -e "\n${COLOR_CYAN}Remove Share${COLOR_RESET}"
                echo -e "${COLOR_CYAN}${SUBMENU_STYLE}${COLOR_RESET}"
                read -p "Share name to remove: " share_name
                if confirm_action "Are you sure you want to remove share $share_name?"; then
                    remove_share "$share_name"
                fi
                ;;
            3)
                list_shares
                read -p "Press ENTER to continue..."
                ;;
            4)
                echo -e "\n${COLOR_CYAN}Configure Share Permissions${COLOR_RESET}"
                echo -e "${COLOR_CYAN}${SUBMENU_STYLE}${COLOR_RESET}"
                read -p "Share path: " share_path
                read -p "Group name: " group_name
                read -p "Permissions (e.g., 2775): " perms
                set_share_permissions "$share_path" "$group_name" "${perms:-2775}"
                ;;
            0)
                break
                ;;
            *)
                log_message "WARN" "Invalid option"
                ;;
        esac
    done
}

# Start menu if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    shares_menu
fi
