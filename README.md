# SambaSetup-CLI

A command-line tool for configuring and managing Samba Active Directory Domain Controller.

## Features

- Simplified Samba AD DC configuration
- User and group management
- Share management
- Monitoring and logs
- Backup and restoration
- User-friendly command-line interface
- Green-themed visual interface with progress indicators
- English language support

## Requirements

- Ubuntu Server 22.04 or higher
- Samba 4.19.x or higher
- Root/sudo privileges
- Required packages: samba, winbind, krb5-config

## Installation

1. Clone the repository:
```bash
git clone https://github.com/your-username/SambaSetup-CLI.git
cd SambaSetup-CLI
```

2. Make the main script executable:
```bash
chmod +x sambasetup
```

## Usage

Run the main script as root:
```bash
sudo ./sambasetup
```

### Available Menus

1. Domain Configuration
   - Initial DC setup
   - Environment cleanup and reset
   - DNS and Kerberos configuration
   - Default domain: DOMAIN.LOCAL
   - Default workgroup: DOMAIN
   - Default NetBIOS name: SV-DOMAIN
   - Default DNS forwarder: 1.1.1.1

2. User Management
   - Create/remove users
   - Manage groups
   - Set permissions
   - User quota management

3. Share Management
   - Create/remove shares
   - Configure permissions
   - List shares
   - Mount point management

4. Monitoring and Logs
   - Service status with visual indicators
   - Log viewing with color coding
   - Active connections monitoring
   - System statistics

5. Backup and Restore
   - Full backup with progress bar
   - Backup restoration
   - Backup management (30-day retention)
   - Automated cleanup

6. Advanced Settings
   - smb.conf editor
   - DNS configuration
   - Kerberos configuration
   - Service management

## Project Structure

```
SambaSetup-CLI/
├── docs/               # Documentation
├── logs/              # System logs
├── src/
│   ├── config/        # Configuration files
│   │   └── settings.conf
│   ├── lib/           # Shared libraries
│   │   └── utils.sh   # Utility functions
│   ├── samba.sh       # Samba configuration
│   ├── shares.sh      # Share management
│   └── users.sh       # User management
└── sambasetup         # Main script
```

## Configuration

The main configuration file `src/config/settings.conf` contains:
- System paths and directories
- Visual theme settings (green color scheme)
- Default Samba settings
- Backup configuration
- Service settings

## Logs

System logs are stored in:
- `/home/administrator/SambaSetup-CLI/logs/sambasetup.log` - General logs
- `/home/administrator/SambaSetup-CLI/logs/error.log` - Error logs
- `/var/log/samba/log.samba` - Samba logs

## Visual Interface

The tool features a modern command-line interface with:
- ASCII art logo
- Progress bars for long operations
- Color-coded status messages
- Green-themed menus and prompts
- Clear visual hierarchy
- Intuitive navigation

## Error Handling

- Comprehensive error checking
- Color-coded error messages
- Detailed logging
- User-friendly error recovery
- Confirmation prompts for critical actions

## Backup System

- Automated backup system
- 30-day retention policy
- Progress indication during backup/restore
- Backup verification
- Easy restoration process

## Contributing

Feel free to contribute to the project through pull requests or by reporting issues.

## License

This project is licensed under the MIT License.

## Recent Updates

- Translated interface to English
- Updated visual theme to green color scheme
- Enhanced progress indicators
- Updated default domain settings
- Improved error handling and user feedback
- Added comprehensive logging
- Enhanced backup system with progress tracking
