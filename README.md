# SambaSetup-CLI

A command-line tool for configuring and managing Samba Active Directory Domain Controller.

## Features

- Simplified Samba AD DC configuration and management
- User-friendly command-line interface with green theme
- Progress indicators and visual feedback
- Comprehensive logging system
- English language support

### Core Features
- Domain Controller setup and configuration
- User and group management with quota support
- Share management with advanced permissions
- Backup and restore functionality with retention policies
- Service monitoring and status tracking
- DNS and Kerberos configuration

### Technical Features
- Modular architecture for easy maintenance
- Comprehensive error handling and logging
- Progress bars for long operations
- Color-coded status messages
- Configuration backup and restore
- Service health monitoring

### Security Features
- Secure password policies
- Permission management
- Backup encryption support
- Audit logging
- SSL/TLS support for secure connections

## Compatibility

### Tested Operating Systems
- Ubuntu Server 22.04 LTS
- Ubuntu Server 22.10
- Ubuntu Server 24.04 LTS (Development)

### Requirements

- Samba 4.19.x or higher
- Root/sudo privileges
- Required packages:
  - samba
  - winbind
  - krb5-config

### Default Settings
- Domain: DOMAIN.LOCAL
- Workgroup: DOMAIN
- NetBIOS name: SV-DOMAIN
- DNS forwarder: 1.1.1.1

## Installation

1. Clone the repository:
```bash
git clone https://github.com/gustavofalcao1/SambaSetup-CLI.git
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

### Command Line Options
```bash
./sambasetup -h        # Show help message
./sambasetup -v        # Show version information
./sambasetup -s        # Show service status
./sambasetup -l        # Show recent logs
```

### Available Menus

1. Domain Configuration
   - Initial DC setup
   - Environment cleanup and reset
   - DNS and Kerberos configuration
   - Domain join operations
   - Forest level management

2. User Management
   - Create/remove users
   - Manage groups and permissions
   - Set user quotas
   - Password policies
   - User templates

3. Share Management
   - Create/remove shares
   - Configure permissions
   - Access control lists
   - Share templates
   - Mount point management

4. Monitoring and Logs
   - Service status with visual indicators
   - Real-time log viewing
   - Active connections monitoring
   - Performance metrics
   - System statistics

5. Backup and Restore
   - Full system backup
   - Incremental backups
   - Scheduled backups
   - 30-day retention management
   - Backup verification

6. Advanced Settings
   - smb.conf editor
   - DNS configuration
   - Kerberos settings
   - Service management
   - Performance tuning

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
- ASCII art logo for brand identity
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

## Performance

- Efficient resource usage
- Fast operation execution
- Minimal system impact
- Optimized code structure
- Cache management

## Security

- Secure password handling
- Permission verification
- Audit logging
- SSL/TLS support
- Backup encryption

## Contributing

Feel free to contribute to the project through pull requests or by reporting issues.

## License

This project is licensed under the MIT License.

## Recent Updates

- Version 2.1.4
  - Complete English translation
  - Updated visual theme to green color scheme
  - Enhanced progress indicators
  - Updated default domain settings
  - Improved error handling
  - Added comprehensive logging
  - Enhanced backup system
  - Added command-line interface
  - Improved documentation

## Support

For issues, feature requests, or general questions:
- Create an issue on GitHub
- Contact the maintainer
- Check the documentation

## Author

Gustavo Falcão
- GitHub: [@gustavofalcao1](https://github.com/gustavofalcao1)
- Repository: [SambaSetup-CLI](https://github.com/gustavofalcao1/SambaSetup-CLI)
