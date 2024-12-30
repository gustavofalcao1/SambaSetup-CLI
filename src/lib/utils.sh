#!/bin/bash
# =============================================================================
# SambaSetup-CLI - Utility Functions
# =============================================================================

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

# Import settings
source "${SCRIPT_DIR}/src/config/settings.conf"

# Logging function with improved formatting
log_message() {
    local level=$1
    local message=$2
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    # Create logs directory if it doesn't exist
    mkdir -p "${LOGS_DIR}"
    
    # Main log
    echo "[$timestamp][$level] $message" >> "${MAIN_LOG}"
    
    # Error log for ERROR and FATAL levels
    if [[ "$level" == "ERROR" || "$level" == "FATAL" ]]; then
        echo "[$timestamp][$level] $message" >> "${ERROR_LOG}"
    fi
    
    # Colored terminal output
    case "$level" in
        "INFO")  echo -e "${COLOR_INFO}[$timestamp][$level] $message${COLOR_RESET}" ;;
        "WARN")  echo -e "${COLOR_WARNING}[$timestamp][$level] $message${COLOR_RESET}" ;;
        "ERROR") echo -e "${COLOR_ERROR}[$timestamp][$level] $message${COLOR_RESET}" ;;
        "FATAL") echo -e "${COLOR_ERROR}[$timestamp][$level] $message${COLOR_RESET}" ;;
        "DEBUG") echo -e "${COLOR_INFO}[$timestamp][$level] $message${COLOR_RESET}" ;;
        *)       echo -e "[$timestamp][$level] $message" ;;
    esac
}

# Error checking function
check_error() {
    if [ $? -ne 0 ]; then
        log_message "ERROR" "$1"
        return 1
    fi
    return 0
}

# Header display function with improved styling
show_header() {
    local title=$1
    clear
    echo -e "${COLOR_PRIMARY}${HEADER_STYLE}${COLOR_RESET}"
    echo -e "${COLOR_HIGHLIGHT}${title}${COLOR_RESET}"
    echo -e "${COLOR_PRIMARY}${HEADER_STYLE}${COLOR_RESET}"
    echo ""
}

# Menu display function with improved formatting
show_menu() {
    local title=$1
    shift
    local options=("$@")
    
    show_header "$title"
    
    local i=1
    for option in "${options[@]}"; do
        echo -e "${COLOR_PRIMARY}${MENU_INDENT}$i)${COLOR_RESET} ${COLOR_SECONDARY}$option${COLOR_RESET}"
        ((i++))
    done
    echo -e "${COLOR_PRIMARY}${MENU_INDENT}0)${COLOR_RESET} ${COLOR_MUTED}Back/Exit${COLOR_RESET}"
    echo ""
}

# Action confirmation function with improved UI
confirm_action() {
    local message=$1
    local default=${2:-"n"}
    
    while true; do
        echo -en "${COLOR_WARNING}$message${COLOR_RESET} "
        read -p "[y/N]: " response
        response=${response:-$default}
        case $response in
            [Yy]* ) return 0;;
            [Nn]* ) return 1;;
            * ) echo -e "${COLOR_ERROR}Please answer with 'y' or 'n'${COLOR_RESET}";;
        esac
    done
}

# Root privileges check
check_root() {
    if [ "$EUID" -ne 0 ]; then
        log_message "FATAL" "This script must be run as root"
        exit 1
    fi
}

# Dependencies check with improved feedback
check_dependencies() {
    local deps=("samba" "winbind" "krb5-config")
    local missing=()
    local total=${#deps[@]}
    local current=0
    
    echo -e "\n${COLOR_INFO}Checking system dependencies...${COLOR_RESET}"
    echo -e "${COLOR_PRIMARY}${SUBMENU_STYLE}${COLOR_RESET}"
    
    for dep in "${deps[@]}"; do
        ((current++))
        show_progress $current $total
        echo -en "\r${MENU_INDENT}Checking $dep... "
        sleep 0.5  # Add small delay for visual effect
        
        if ! dpkg -l | grep -q "^ii  $dep"; then
            echo -e "${COLOR_ERROR}Missing${COLOR_RESET}"
            missing+=("$dep")
        else
            echo -e "${COLOR_SUCCESS}OK${COLOR_RESET}"
        fi
    done
    
    echo -e "${COLOR_PRIMARY}${SUBMENU_STYLE}${COLOR_RESET}"
    
    if [ ${#missing[@]} -ne 0 ]; then
        echo -e "\n${COLOR_WARNING}Missing dependencies: ${missing[*]}${COLOR_RESET}"
        if confirm_action "Would you like to install missing dependencies?"; then
            echo -e "\n${COLOR_INFO}Installing dependencies...${COLOR_RESET}"
            apt update
            apt install -y "${missing[@]}"
            
            if check_error "Failed to install dependencies"; then
                echo -e "${COLOR_SUCCESS}Dependencies installed successfully${COLOR_RESET}"
                sleep 1
            else
                return 1
            fi
        else
            log_message "ERROR" "Required dependencies not installed"
            exit 1
        fi
    else
        echo -e "\n${COLOR_SUCCESS}All dependencies are installed${COLOR_RESET}"
        sleep 1
    fi
}

# Backup creation function with improved feedback
create_backup() {
    local source=$1
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local backup_dir="${BACKUP_DIR}/${timestamp}"
    
    log_message "INFO" "Creating backup..."
    
    mkdir -p "$backup_dir"
    if [ -e "$source" ]; then
        echo -e "\n${COLOR_INFO}Backing up files...${COLOR_RESET}"
        cp -r "$source" "$backup_dir/"
        check_error "Backup failed" || return 1
        log_message "INFO" "Backup created successfully in $backup_dir"
        echo -e "${COLOR_SUCCESS}Backup completed successfully${COLOR_RESET}"
    else
        log_message "ERROR" "Source directory not found: $source"
        return 1
    fi
}

# Backup restoration function with improved feedback
restore_backup() {
    local backup_dir=$1
    local target=$2
    
    if [ -d "$backup_dir" ]; then
        log_message "INFO" "Restoring backup..."
        echo -e "\n${COLOR_INFO}Restoring files...${COLOR_RESET}"
        cp -r "$backup_dir"/* "$(dirname "$target")/"
        check_error "Restore failed" || return 1
        log_message "INFO" "Backup restored successfully from $backup_dir"
        echo -e "${COLOR_SUCCESS}Restore completed successfully${COLOR_RESET}"
    else
        log_message "ERROR" "Backup directory not found: $backup_dir"
        return 1
    fi
}

# Progress bar function
show_progress() {
    local current=$1
    local total=$2
    local width=50
    local percentage=$((current * 100 / total))
    local filled=$((percentage * width / 100))
    local empty=$((width - filled))
    
    printf "\r${MENU_INDENT}${COLOR_PRIMARY}Progress: [${COLOR_RESET}"
    printf "${COLOR_SUCCESS}%${filled}s${COLOR_RESET}" | tr ' ' '='
    printf "${COLOR_MUTED}%${empty}s${COLOR_RESET}" | tr ' ' ' '
    printf "${COLOR_PRIMARY}] %3d%%${COLOR_RESET}" $percentage
}

# Spinner function for long operations
show_spinner() {
    local pid=$1
    local message=$2
    local spin='-\|/'
    local i=0
    
    while kill -0 $pid 2>/dev/null; do
        i=$(( (i+1) %4 ))
        printf "\r${MENU_INDENT}${message} ${spin:$i:1}"
        sleep .1
    done
    printf "\r"
}

# Service status check
check_service_status() {
    local service=$1
    if systemctl is-active --quiet "$service"; then
        echo -e "${COLOR_SUCCESS}Running${COLOR_RESET}"
    else
        echo -e "${COLOR_ERROR}Stopped${COLOR_RESET}"
    fi
}
