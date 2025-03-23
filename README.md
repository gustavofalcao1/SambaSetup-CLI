# SambaSetup-CLI

**SambaSetup-CLI** is a command-line tool designed to simplify the configuration and management of a Samba Active Directory Domain Controller (AD DC).

---

## ✨ Features

### Core Capabilities
- Initial Samba AD DC setup and configuration
- Domain join and forest management
- User and group management with quota and templates
- Share creation and permission management
- DNS and Kerberos configuration
- Real-time service monitoring and logs
- Backup and restore with retention and verification

### Technical Highlights
- Modular, maintainable architecture
- Full error handling and logging system
- Visual progress indicators and color-coded messages
- Modern CLI interface with green-themed visuals

### Security
- Secure password and permission policies
- Backup encryption
- SSL/TLS support
- Audit logs and role-based access

---

## ✅ Compatibility

### Tested on:
- Ubuntu Server 22.04 LTS
- Ubuntu Server 22.10
- Ubuntu Server 24.04 LTS (Development)

### Requirements:
- Samba 4.19.x or newer
- Root privileges (sudo)
- Required packages:
  - `samba`
  - `winbind`
  - `krb5-config`

### Default Settings:
- Domain: `DOMAIN.LOCAL`
- Workgroup: `DOMAIN`
- NetBIOS: `SV-DOMAIN`
- DNS Forwarder: `1.1.1.1`

---

## 📦 Installation

1. **Clone the repository:**
```bash
git clone https://github.com/gustavofalcao1/SambaSetup-CLI.git
cd SambaSetup-CLI
```

2. **Make the script executable:**
```bash
chmod +x sambasetup
```

---

## 🚀 Usage

Run the main interface:
```bash
sudo ./sambasetup
```

### Command-Line Options
```bash
./sambasetup -h   # Help message
./sambasetup -v   # Version info
./sambasetup -s   # Service status
./sambasetup -l   # Recent logs
```

---

## 📋 Available Menus

### 1. Domain Configuration
- Initial AD DC setup
- Reset environment
- Configure DNS and Kerberos
- Join/leave domain
- Manage forest/domain levels

### 2. User Management
- Add/remove users and groups
- Assign permissions and quotas
- Apply user templates
- Configure password policies

### 3. Share Management
- Create/delete shares
- Configure ACLs and permissions
- Manage mount points
- Use share templates

### 4. Monitoring & Logs
- Service status with visual indicators
- View logs in real time
- Track active sessions and system stats

### 5. Backup & Restore
- Full and incremental backups
- Scheduled backups
- Retention (30 days)
- Backup validation and restore

### 6. Advanced Settings
- `smb.conf` editor
- DNS/Kerberos tuning
- System performance configs
- Service management interface

---

## 📁 Project Structure
```
SambaSetup-CLI/
├── docs/             # Documentation
├── logs/             # Application and system logs
├── src/
│   ├── config/       # Global settings
│   ├── lib/          # Utility functions
│   ├── samba.sh      # Core domain setup
│   ├── shares.sh     # Share logic
│   └── users.sh      # User management
└── sambasetup        # Main CLI entrypoint
```

---

## ⚙️ Configuration

Edit `src/config/settings.conf` to customize:
- Samba paths and defaults
- Color theme (green)
- Backup preferences
- Log locations

---

## 🧾 Logging

Log files include:
- `logs/sambasetup.log` — General operations
- `logs/error.log` — Error and failure reports
- `/var/log/samba/log.samba` — Samba system logs

---

## 💻 Visual Interface
- Custom ASCII branding
- Animated progress bars
- Color-coded messaging
- Menu-based navigation with hierarchy

---

## 🛡️ Error Handling
- Context-aware error prompts
- Color-coded errors
- Safe fallbacks
- Log-backed diagnostics

---

## 🔐 Backup System
- Automatic encrypted backups
- 30-day retention policy
- Progress indicators
- Restoration confirmation and checks

---

## ⚡ Performance
- Lightweight and fast
- Optimized shell scripts
- Low memory impact
- Smart caching and job control

---

## 🤝 Contributing

We welcome contributions! Open an issue or check our roadmap. Pull requests are encouraged!

---

## 📄 License

This project is licensed under the MIT License. See `LICENSE` for details.

---

## 📦 Recent Updates (v2.1.4)
- Full English language support
- Green theme and UI overhaul
- Enhanced error and log system
- New CLI flags
- Better backup automation

---

## 💬 Support
- Open a GitHub Issue
- Check the documentation in `docs/`
- Contact the maintainer

## 👤 Author
**Gustavo Falcão**  
[GitHub @gustavofalcao1](https://github.com/gustavofalcao1)  
[Project Link](https://github.com/gustavofalcao1/SambaSetup-CLI)

