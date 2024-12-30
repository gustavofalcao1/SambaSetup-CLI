#!/bin/bash

x="start"
LOGFILE="./logs/samba.log"

log_message() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $1" >> "$LOGFILE"
}

# Função para validar nome de usuário
validate_username() {
    local username=$1
    if [[ ! "$username" =~ ^[a-z][a-z0-9_-]{2,}$ ]]; then
        echo "Error: Username must start with a letter and contain only lowercase letters, numbers, underscore or dash"
        return 1
    fi
    return 0
}

# Função para validar senha
validate_password() {
    local password=$1
    if [ ${#password} -lt 8 ]; then
        echo "Error: Password must be at least 8 characters long"
        return 1
    fi
    return 0
}

# Função para configurar diretório home e perfil
setup_user_home() {
    local username=$1
    local server_hostname=$(hostname)
    
    # Create directories
    local home_dir="/srv/samba/homes/$username"
    local profile_dir="/srv/samba/profiles/$username"
    
    echo "Creating user directories..."
    sudo mkdir -p "$home_dir" "$profile_dir"
    
    # Create default directories
    sudo mkdir -p "$home_dir"/{Documents,Desktop,Downloads,Pictures,Videos,Music}
    
    # Set permissions
    sudo chown -R "$username:domain users" "$home_dir" "$profile_dir"
    sudo chmod 700 "$home_dir" "$profile_dir"
    
    # Set correct ACLs
    sudo setfacl -R -m "u:$username:rwx" "$home_dir" "$profile_dir"
    sudo setfacl -R -m "g:domain users:---" "$home_dir" "$profile_dir"
    sudo setfacl -R -d -m "u:$username:rwx" "$home_dir" "$profile_dir"
    sudo setfacl -R -d -m "g:domain users:---" "$home_dir" "$profile_dir"
    
    echo "Directories created and permissions set"
}

# Função para limpar diretórios do usuário
cleanup_user_dirs() {
    local username=$1
    local backup=$2
    
    if [ "$backup" = "yes" ]; then
        local backup_dir="/srv/samba/backups/$username-$(date +%Y%m%d)"
        echo "Backing up user directories to $backup_dir..."
        sudo mkdir -p "$backup_dir"
        sudo cp -r "/srv/samba/homes/$username" "$backup_dir/home"
        sudo cp -r "/srv/samba/profiles/$username" "$backup_dir/profile"
    fi
    
    echo "Removing user directories..."
    sudo rm -rf "/srv/samba/homes/$username" "/srv/samba/profiles/$username"
}

menu() {
while true $x != "start"
do
clear
echo "=============================================================================================="
echo "                                   SAMBA USER MANAGEMENT"
echo "=============================================================================================="
echo ""
echo "User Management:"
echo "------------------------------------------"
echo "    List Users                  - 1"
echo "    Add User                    - 2"
echo "    Change User Password        - 3"
echo "    Delete User                 - 4"
echo "------------------------------------------"
echo ""
echo "Group Management:"
echo "------------------------------------------"
echo "    List User Groups            - 5"
echo "    Add User to Group           - 6"
echo "    Remove User from Group      - 7"
echo "------------------------------------------"
echo ""
echo "User Administration:"
echo "------------------------------------------"
echo "    Show User Details           - 8"
echo "    Lock/Unlock User            - 9"
echo "    Modify User Attributes      - 10"
echo "------------------------------------------"
echo ""
echo "Navigation:"
echo "------------------------------------------"
echo "    Return                      - 98"
echo "    Exit                        - 99"
echo "------------------------------------------"
echo ""
echo "Enter your choice (number): "
read x
echo ""
echo "Selected option: $x"
echo "=============================================================================================="

case "$x" in
    1)
        echo "Listing all users..."
        echo ""
        sudo samba-tool user list
        echo ""
        log_message "Listed all users"
        read -p "Press ENTER to continue..."
        ;;
        
    2)
        echo "Creating new Samba user"
        echo ""
        
        # Get user information
        read -p "Enter first name: " firstname
        read -p "Enter surname: " surname
        read -p "Enter username: " username
        
        # Validate username
        if ! validate_username "$username"; then
            read -p "Press ENTER to continue..."
            continue
        fi
        
        # Get and validate password
        while true; do
            read -s -p "Enter password: " password
            echo ""
            read -s -p "Confirm password: " password2
            echo ""
            
            if [ "$password" != "$password2" ]; then
                echo "Passwords do not match!"
                continue
            fi
            
            if ! validate_password "$password"; then
                continue
            fi
            break
        done
        
        read -p "Force password change at next login? [y/n]: " force_change
        
        # Get domain info
        domain=$(grep -i 'realm' /etc/samba/smb.conf | awk -F= '{print $2}' | tr -d '[:space:]' | tr '[:upper:]' '[:lower:]')
        server_hostname=$(hostname)
        
        echo ""
        echo "Creating user '$username'..."
        
        # Create user
        if [ "$force_change" = "y" ]; then
            sudo samba-tool user create "$username" "$password" \
                --given-name="$firstname" \
                --surname="$surname" \
                --home-directory="\\\\${server_hostname}\\homes\\${username}" \
                --profile-path="\\\\${server_hostname}\\profiles\\${username}" \
                --script-path="\\\\${server_hostname}\\netlogon\\${username}.cmd" \
                --must-change-at-next-login
        else
            sudo samba-tool user create "$username" "$password" \
                --given-name="$firstname" \
                --surname="$surname" \
                --home-directory="\\\\${server_hostname}\\homes\\${username}" \
                --profile-path="\\\\${server_hostname}\\profiles\\${username}" \
                --script-path="\\\\${server_hostname}\\netlogon\\${username}.cmd"
        fi
        
        if [ $? -eq 0 ]; then
            # Setup user directories
            setup_user_home "$username"
            echo "User $username created successfully!"
            log_message "Created user: $username"
        else
            echo "Failed to create user $username"
            log_message "Failed to create user: $username"
        fi
        
        read -p "Press ENTER to continue..."
        ;;
        
    3)
        echo "Change user password"
        echo ""
        read -p "Enter username: " username
        
        if sudo samba-tool user list | grep -q "^$username$"; then
            sudo samba-tool user setpassword "$username"
            if [ $? -eq 0 ]; then
                echo "Password changed successfully!"
                log_message "Changed password for user: $username"
            else
                echo "Failed to change password!"
            fi
        else
            echo "User $username does not exist!"
        fi
        
        read -p "Press ENTER to continue..."
        ;;
        
    4)
        echo "Delete user"
        echo ""
        read -p "Enter username to delete: " username
        
        if sudo samba-tool user list | grep -q "^$username$"; then
            read -p "Do you want to backup user data before deletion? [y/n]: " backup
            read -p "Are you SURE you want to delete user $username? This cannot be undone! [y/n]: " confirm
            
            if [ "$confirm" = "y" ]; then
                # Backup and cleanup user directories
                if [ "$backup" = "y" ]; then
                    cleanup_user_dirs "$username" "yes"
                else
                    cleanup_user_dirs "$username" "no"
                fi
                
                # Delete user
                sudo samba-tool user delete "$username"
                if [ $? -eq 0 ]; then
                    echo "User $username deleted successfully!"
                    log_message "Deleted user: $username"
                else
                    echo "Failed to delete user $username"
                fi
            else
                echo "Operation cancelled"
            fi
        else
            echo "User $username does not exist!"
        fi
        
        read -p "Press ENTER to continue..."
        ;;
        
    5)
        echo "List user groups"
        echo ""
        read -p "Enter username: " username
        
        if sudo samba-tool user list | grep -q "^$username$"; then
            echo "Groups for user $username:"
            sudo samba-tool user getgroups "$username"
            log_message "Listed groups for user: $username"
        else
            echo "User $username does not exist!"
        fi
        
        read -p "Press ENTER to continue..."
        ;;
        
    6)
        echo "Add user to group"
        echo ""
        read -p "Enter username: " username
        read -p "Enter group name: " groupname
        
        if sudo samba-tool user list | grep -q "^$username$"; then
            sudo samba-tool group addmembers "$groupname" "$username"
            if [ $? -eq 0 ]; then
                echo "Added $username to group $groupname successfully!"
                log_message "Added user $username to group: $groupname"
            else
                echo "Failed to add user to group!"
            fi
        else
            echo "User $username does not exist!"
        fi
        
        read -p "Press ENTER to continue..."
        ;;
        
    7)
        echo "Remove user from group"
        echo ""
        read -p "Enter username: " username
        read -p "Enter group name: " groupname
        
        if sudo samba-tool user list | grep -q "^$username$"; then
            sudo samba-tool group removemembers "$groupname" "$username"
            if [ $? -eq 0 ]; then
                echo "Removed $username from group $groupname successfully!"
                log_message "Removed user $username from group: $groupname"
            else
                echo "Failed to remove user from group!"
            fi
        else
            echo "User $username does not exist!"
        fi
        
        read -p "Press ENTER to continue..."
        ;;
        
    8)
        echo "Show user details"
        echo ""
        read -p "Enter username: " username
        
        if sudo samba-tool user list | grep -q "^$username$"; then
            echo "Details for user $username:"
            sudo samba-tool user show "$username"
            log_message "Showed details for user: $username"
        else
            echo "User $username does not exist!"
        fi
        
        read -p "Press ENTER to continue..."
        ;;
        
    9)
        echo "Lock/Unlock user account"
        echo ""
        read -p "Enter username: " username
        
        if sudo samba-tool user list | grep -q "^$username$"; then
            read -p "Do you want to [l]ock or [u]nlock the account? " action
            
            case "$action" in
                l|L)
                    sudo samba-tool user disable "$username"
                    echo "User account $username has been locked"
                    log_message "Locked user account: $username"
                    ;;
                u|U)
                    sudo samba-tool user enable "$username"
                    echo "User account $username has been unlocked"
                    log_message "Unlocked user account: $username"
                    ;;
                *)
                    echo "Invalid option!"
                    ;;
            esac
        else
            echo "User $username does not exist!"
        fi
        
        read -p "Press ENTER to continue..."
        ;;
        
    10)
        echo "Modify user attributes"
        echo ""
        read -p "Enter username: " username
        
        if sudo samba-tool user list | grep -q "^$username$"; then
            echo "Current user information:"
            sudo samba-tool user show "$username"
            echo ""
            
            echo "Select attribute to modify:"
            echo "1. Given Name"
            echo "2. Surname"
            echo "3. User Principal Name"
            echo "4. Home Directory"
            echo "5. Profile Path"
            echo "6. Script Path"
            read -p "Enter choice (1-6): " attr_choice
            
            # Get server hostname for paths
            server_hostname=$(hostname)
            
            case "$attr_choice" in
                1)
                    read -p "Enter new given name: " new_value
                    sudo samba-tool user set "$username" --given-name="$new_value"
                    ;;
                2)
                    read -p "Enter new surname: " new_value
                    sudo samba-tool user set "$username" --surname="$new_value"
                    ;;
                3)
                    read -p "Enter new UPN: " new_value
                    sudo samba-tool user set "$username" --principal-name="$new_value"
                    ;;
                4)
                    new_value="\\\\${server_hostname}\\homes\\${username}"
                    sudo samba-tool user set "$username" --home-directory="$new_value"
                    ;;
                5)
                    new_value="\\\\${server_hostname}\\profiles\\${username}"
                    sudo samba-tool user set "$username" --profile-path="$new_value"
                    ;;
                6)
                    new_value="\\\\${server_hostname}\\netlogon\\${username}.cmd"
                    sudo samba-tool user set "$username" --script-path="$new_value"
                    ;;
                *)
                    echo "Invalid option!"
                    read -p "Press ENTER to continue..."
                    continue
                    ;;
            esac
            
            if [ $? -eq 0 ]; then
                echo "User attribute modified successfully!"
                echo ""
                echo "Updated user information:"
                sudo samba-tool user show "$username"
                log_message "Modified attributes for user: $username"
            else
                echo "Failed to modify user attribute!"
            fi
        else
            echo "User $username does not exist!"
        fi
        
        read -p "Press ENTER to continue..."
        ;;
        
    98)
        echo "Returning to main menu..."
        src/server.sh
        exit 0
        ;;
        
    99)
        echo "Exiting..."
        clear
        exit 0
        ;;
        
    *)
        echo "Invalid option!"
        read -p "Press ENTER to continue..."
        ;;
esac
done
}

menu
