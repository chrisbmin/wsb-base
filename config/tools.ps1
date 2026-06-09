# config/tools.ps1
# Central tool catalog — all menus and install scripts read from here.
#
# Manager values:
#   winget    — winget install -e --id <PackageId>
#   choco     — choco install -y <PackageId>
#   scoop     — scoop install <PackageId>  (ScoopBucket specifies the bucket)
#   psgallery — Install-Module -Name <PackageId> -Force -AllowClobber -Scope CurrentUser
#   feature   — Add-WindowsCapability -Online -Name <PackageId>
#   manual    — not automated; Notes contains the download URL or instructions

# ── Scoop buckets to add before any scoop installs ──────────────────────────
$ScoopBuckets = @(
    'main',
    'extras',
    'versions',
    'nerd-fonts'
)

# ── Tool catalog ─────────────────────────────────────────────────────────────
# Categories are displayed in the menu in the order they first appear here.
$ToolCatalog = @(

    # ── Shell & Terminal ─────────────────────────────────────────────────────
    @{
        Name            = 'Windows Terminal'
        Category        = 'Shell & Terminal'
        Description     = 'Modern tabbed terminal - Command Prompt, PowerShell, WSL, Azure Cloud Shell'
        Manager         = 'winget'
        PackageId       = 'Microsoft.WindowsTerminal'
    },
    @{
        Name            = 'PowerShell 7'
        Category        = 'Shell & Terminal'
        Description     = 'Cross-platform PowerShell (PS7+) - runs side-by-side with Windows PowerShell 5.1'
        Manager         = 'winget'
        PackageId       = 'Microsoft.PowerShell'
    },
    @{
        Name            = 'Oh My Posh'
        Category        = 'Shell & Terminal'
        Description     = 'Prompt theme engine for PowerShell and other shells'
        Manager         = 'winget'
        PackageId       = 'JanDeDobbeleer.OhMyPosh'
    },
    @{
        Name            = 'Scoop'
        Category        = 'Shell & Terminal'
        Description     = 'Command-line installer for portable apps and dev tools (also installs git, a required dependency)'
        Manager         = 'scoop-bootstrap'
        PackageId       = ''
    },

    # ── Browsers ─────────────────────────────────────────────────────────────
    @{
        Name            = 'Arc Browser'
        Category        = 'Browsers'
        Description     = 'A fast, private, and secure browser.'
        Manager         = 'winget'
        PackageId       = 'TheBrowserCompany.Arc'
    },
    @{
        Name            = 'Brave Browser'
        Category        = 'Browsers'
        Description     = 'Privacy-focused browser with built-in ad/tracker blocking and Shields'
        Manager         = 'winget'
        PackageId       = 'Brave.Brave'
    },
    @{
        Name            = 'Google Chrome'
        Category        = 'Browsers'
        Description     = 'Google Chrome browser'
        Manager         = 'winget'
        PackageId       = 'Google.Chrome'
    },
    @{
        Name            = 'Librewolf'
        Category        = 'Browsers'
        Description     = 'A fork of Firefox, focuses on privacy, security and freedom.'
        Manager         = 'winget'
        PackageId       = 'LibreWolf.LibreWolf'
    },    
    @{
        Name            = 'Mozilla Firefox'
        Category        = 'Browsers'
        Description     = 'Firefox browser'
        Manager         = 'winget'
        PackageId       = 'Mozilla.Firefox'
    },
    @{
        Name            = 'Firefox Developer Edition'
        Category        = 'Browsers'
        Description     = 'Firefox with experimental dev tools and WebExtensions debugging'
        Manager         = 'winget'
        PackageId       = 'Mozilla.FirefoxDeveloperEdition'
    },
    @{
        Name            = 'Vivaldi Browser'
        Category        = 'Browsers'
        Description     = 'A Powerful, Personal. Private. web browser'
        Manager         = 'winget'
        PackageId       = 'Vivaldi.Vivaldi'
    },

    # ── Dev Tools ────────────────────────────────────────────────────────────
    @{
        Name            = 'VS Code'
        Category        = 'Dev Tools'
        Description     = 'Visual Studio Code - lightweight editor with extensions for nearly everything'
        Manager         = 'winget'
        PackageId       = 'Microsoft.VisualStudioCode'
    },
    @{
        Name            = 'Git'
        Category        = 'Dev Tools'
        Description     = 'Git version control - includes Git Bash and credential manager'
        Manager         = 'winget'
        PackageId       = 'Git.Git'
    },
    @{
        Name            = 'GitHub Desktop'
        Category        = 'Dev Tools'
        Description     = 'GitHub GUI client for managing repos without the CLI'
        Manager         = 'winget'
        PackageId       = 'GitHub.GitHubDesktop'
    },
    @{
        Name            = 'WinMerge'
        Category        = 'Dev Tools'
        Description     = 'File and folder diff/merge tool - great for config comparisons'
        Manager         = 'winget'
        PackageId       = 'WinMerge.WinMerge'
    },
    @{
        Name            = 'jq'
        Category        = 'Dev Tools'
        Description     = 'Lightweight command-line JSON processor - essential for scripting against APIs'
        Manager         = 'scoop'
        PackageId       = 'jq'
        ScoopBucket     = 'main'
    },
    @{
        Name            = 'yq'
        Category        = 'Dev Tools'
        Description     = 'Command-line YAML/JSON/XML/CSV processor - like jq but for structured config files'
        Manager         = 'scoop'
        PackageId       = 'yq'
        ScoopBucket     = 'main'
    },
    @{
        Name            = 'Zed'
        Category        = 'Dev Tools'
        Description     = 'High-performance multiplayer code editor built in Rust — fast startup, collaborative editing, AI-native'
        Manager         = 'winget'
        PackageId       = 'Zed.Zed'
    },
    @{
        Name            = 'Node.js LTS'
        Category        = 'Dev Tools'
        Description     = 'Node.js JavaScript runtime (LTS) — includes npm; use for web tooling, scripts, and server-side JS'
        Manager         = 'winget'
        PackageId       = 'OpenJS.NodeJS.LTS'
    },
    @{
        Name            = 'Python 3'
        Category        = 'Dev Tools'
        Description     = 'Python 3 interpreter — includes pip; adds python and py launcher to PATH'
        Manager         = 'winget'
        PackageId       = 'Python.Python.3'
    },
    @{
        Name            = 'nmap'
        Category        = 'Dev Tools'
        Description     = 'Network scanner — port scanning, service/OS detection, and host discovery'
        Manager         = 'scoop'
        PackageId       = 'nmap'
        ScoopBucket     = 'main'
    },
    @{
        Name            = 'gping'
        Category        = 'Dev Tools'
        Description     = 'Graphical ping in the terminal — plots latency over time, supports multi-host comparison'
        Manager         = 'scoop'
        PackageId       = 'gping'
        ScoopBucket     = 'main'
    },
    @{
        Name            = 'dog'
        Category        = 'Dev Tools'
        Description     = 'Modern dig replacement — cleaner DNS query output with colour and multiple record types'
        Manager         = 'scoop'
        PackageId       = 'dog'
        ScoopBucket     = 'main'
    },
    @{
        Name            = 'bat'
        Category        = 'Dev Tools'
        Description     = 'cat with syntax highlighting and line numbers — ideal for reviewing configs, scripts, and logs'
        Manager         = 'scoop'
        PackageId       = 'bat'
        ScoopBucket     = 'main'
    },
    @{
        Name            = 'ripgrep'
        Category        = 'Dev Tools'
        Description     = 'Extremely fast grep replacement (rg) — searches logs, configs, and code faster than any alternative'
        Manager         = 'scoop'
        PackageId       = 'ripgrep'
        ScoopBucket     = 'main'
    },
    @{
        Name            = 'duf'
        Category        = 'Dev Tools'
        Description     = 'Modern df replacement — clean disk usage and free space overview across all volumes'
        Manager         = 'scoop'
        PackageId       = 'duf'
        ScoopBucket     = 'main'
    },
    @{
        Name            = 'bottom'
        Category        = 'Dev Tools'
        Description     = 'TUI system monitor (btm) — CPU, memory, processes, and network; like htop for Windows'
        Manager         = 'scoop'
        PackageId       = 'bottom'
        ScoopBucket     = 'main'
    },
    @{
        Name            = 'Terraform'
        Category        = 'Dev Tools'
        Description     = 'HashiCorp infrastructure as code — automate provisioning across Nutanix, vSphere, cloud, and on-prem'
        Manager         = 'scoop'
        PackageId       = 'terraform'
        ScoopBucket     = 'main'
    },
    @{
        Name            = 'kubectl'
        Category        = 'Dev Tools'
        Description     = 'Kubernetes CLI — manage clusters including Nutanix Kubernetes Engine (NKE)'
        Manager         = 'scoop'
        PackageId       = 'kubectl'
        ScoopBucket     = 'main'
    },
    @{
        Name            = 'Helm'
        Category        = 'Dev Tools'
        Description     = 'Kubernetes package manager — deploy and manage applications on NKE and other clusters'
        Manager         = 'scoop'
        PackageId       = 'helm'
        ScoopBucket     = 'main'
    },
    @{
        Name            = 'lazygit'
        Category        = 'Dev Tools'
        Description     = 'Terminal UI for Git — visual branch, commit, diff, and merge management without memorising flags'
        Manager         = 'scoop'
        PackageId       = 'lazygit'
        ScoopBucket     = 'extras'
    },

    # ── Productivity ─────────────────────────────────────────────────────────
    @{
        Name            = '1Password'
        Category        = 'Productivity'
        Description     = 'Security at the speed of life'
        Manager         = 'winget'
        PackageId       = 'AgileBits.1Password '
    },
    @{
        Name            = 'LastPass for Desktop'
        Category        = 'Productivity'
        Description     = 'LastPass for Desktop - password manager and vault application'
        Manager         = 'winget'
        PackageId       = 'LastPass.LastPass'
    },    
    @{
        Name            = 'Notepad++'
        Category        = 'Productivity'
        Description     = 'Feature-rich text and code editor - tabs, macros, multi-cursor, plugin ecosystem'
        Manager         = 'winget'
        PackageId       = 'Notepad++.Notepad++'
    },
    @{
        Name            = 'Notepads App'
        Category        = 'Productivity'
        Description     = 'Modern minimal notepad for quick notes - clean UX, tabbed'
        Manager         = 'winget'
        PackageId       = 'JamieOleary.Notepads'
        Notes           = 'If install fails by ID, try: winget install -e --name "Notepads App"'
    },
    @{
        Name            = '7-Zip'
        Category        = 'Productivity'
        Description     = 'File archiver and compression utility - handles ZIP, 7z, RAR, ISO, and more'
        Manager         = 'winget'
        PackageId       = '7zip.7zip'
    },
    @{
        Name            = 'Windows PowerToys'
        Category        = 'Productivity'
        Description     = "Microsoft's power-user utility collection - FancyZones, PowerRename, Run launcher, and more"
        Manager         = 'winget'
        PackageId       = 'Microsoft.PowerToys'
    },    
    @{
        Name            = 'Snipaste'
        Category        = 'Productivity'
        Description     = 'Screen capture, recording, and annotation - scrolling capture, OCR, upload workflows'
        Manager         = 'winget'
        PackageId       = 'liule.Snipaste'
    },
    @{
        Name            = 'Kleopatra'
        Category        = 'Productivity'
        Description     = 'Certificate manager and GUI for GnuPG — encrypt, decrypt, sign, and verify files and email (installs full Gpg4win suite)'
        Manager         = 'winget'
        PackageId       = 'GnuPG.Gpg4win'
    },
    @{
        Name            = 'Keybase'
        Category        = 'Productivity'
        Description     = 'End-to-end encrypted messaging, file sharing, and Git — identity anchored to social profiles'
        Manager         = 'winget'
        PackageId       = 'Keybase.Keybase'
    },
    @{
        Name            = 'NZXT CAM'
        Category        = 'Productivity'
        Description     = 'System monitoring and NZXT hardware control — CPU/GPU temps, fan curves, RGB, and performance overlay'
        Manager         = 'winget'
        PackageId       = 'NZXT.CAM'
    },
    @{
        Name            = 'Raspberry Pi Imager'
        Category        = 'Productivity'
        Description     = 'Official Raspberry Pi OS imaging tool — write OS images to SD cards and USB drives'
        Manager         = 'winget'
        PackageId       = 'RaspberryPiFoundation.RaspberryPiImager'
    },
    @{
        Name            = 'Thunderbird'
        Category        = 'Productivity'
        Description     = 'Mozilla email client — IMAP/POP3/SMTP, calendar, contacts, and end-to-end encryption via OpenPGP'
        Manager         = 'winget'
        PackageId       = 'Mozilla.Thunderbird'
    },

    # ── Media & Graphics ─────────────────────────────────────────────────────
    @{
        Name            = 'VLC'
        Category        = 'Media & Graphics'
        Description     = 'Universal media player - plays virtually any format without extra codecs'
        Manager         = 'winget'
        PackageId       = 'VideoLAN.VLC'
    },
    @{
        Name            = 'Paint.NET'
        Category        = 'Media & Graphics'
        Description     = 'Image editor with layers, adjustments, and a rich plugin library'
        Manager         = 'winget'
        PackageId       = 'dotPDN.PaintDotNet'
    },
    @{
        Name            = 'GIMP'
        Category        = 'Media & Graphics'
        Description     = 'Free and open-source raster image editor — full Photoshop-style layer and filter toolset'
        Manager         = 'winget'
        PackageId       = 'GIMP.GIMP'
    },
    @{
        Name            = 'Inkscape'
        Category        = 'Media & Graphics'
        Description     = 'Free and open-source vector graphics editor — SVG-native, great for logos and diagrams'
        Manager         = 'winget'
        PackageId       = 'Inkscape.Inkscape'
    },
    @{
        Name            = 'K-Lite Codec Pack Full'
        Category        = 'Media & Graphics'
        Description     = 'Comprehensive codec collection for playing any audio/video format in Windows Media Player and other players'
        Manager         = 'choco'
        PackageId       = 'k-litecodecpackfull'
        Notes           = 'Installs the Full variant; Basic/Standard/Mega also available as separate choco packages'
    },

    # ── File Management ───────────────────────────────────────────────────────
    @{
        Name            = 'WinSCP'
        Category        = 'File Management'
        Description     = 'SFTP, FTP, S3, SCP, and WebDAV client - built-in scripting support'
        Manager         = 'winget'
        PackageId       = 'WinSCP.WinSCP'
    },
    @{
        Name            = 'FileZilla'
        Category        = 'File Management'
        Description     = 'FTP/SFTP/FTPS client - reliable fallback when WinSCP is not enough'
        Manager         = 'choco'
        PackageId       = 'filezilla'
    },
    @{
        Name            = 'WizTree'
        Category        = 'File Management'
        Description     = 'Disk space analyzer - reads the MFT directly, results in seconds on any drive size'
        Manager         = 'winget'
        PackageId       = 'AntibodySoftware.WizTree'
    },

    # ── Admin & Security Tools ────────────────────────────────────────────────
    @{
        Name            = 'SysInternals Suite'
        Category        = 'Admin & Security Tools'
        Description     = 'Complete Microsoft Sysinternals toolkit - Process Explorer, PsExec, AutoRuns, TCPView, and 70+ more'
        Manager         = 'winget'
        PackageId       = 'Microsoft.Sysinternals.Suite'
    },
    @{
        Name            = 'IIS Crypto'
        Category        = 'Admin & Security Tools'
        Description     = 'GUI tool to configure TLS versions, cipher suites, and protocol settings on Windows/IIS'
        Manager         = 'choco'
        PackageId       = 'iiscrypto'
    },
    @{
        Name            = 'OpenSSL for Windows'
        Category        = 'Admin & Security Tools'
        Description     = 'OpenSSL binaries - CSR generation, cert inspection, key operations, TLS debugging'
        Manager         = 'winget'
        PackageId       = 'ShiningLight.OpenSSL'
    },
    @{
        Name            = 'LockHunter'
        Category        = 'Admin & Security Tools'
        Description     = 'Find what process is locking a file or folder - unlock and delete without rebooting'
        Manager         = 'winget'
        PackageId       = 'Crystal.LockHunter'
    },
    @{
        Name            = 'Rufus'
        Category        = 'Admin & Security Tools'
        Description     = 'Bootable USB drive creator - fast, reliable, supports Windows and Linux ISOs'
        Manager         = 'winget'
        PackageId       = 'Rufus.Rufus'
    },
    @{
        Name            = 'LGPO'
        Category        = 'Admin & Security Tools'
        Description     = 'Microsoft Local Group Policy Object utility - apply/export/import GPO settings on non-domain machines'
        Manager         = 'manual'
        PackageId       = 'https://www.microsoft.com/en-us/download/details.aspx?id=55319'
        Notes           = 'No package manager entry. Download from Microsoft Security Compliance Toolkit.'
    },
    @{
        Name            = 'Windows Admin Center'
        Category        = 'Admin & Security Tools'
        Description     = "Microsoft's browser-based server management - replaces many MMC snap-ins with a modern UI"
        Manager         = 'winget'
        PackageId       = 'Microsoft.WindowsAdminCenter'
        Notes           = 'Installs as a local HTTPS service. Choose port during install (default 443 or 6516).'
    },

    # ── Network Tools ─────────────────────────────────────────────────────────
    @{
        Name            = 'MobaXterm'
        Category        = 'Network Tools'
        Description     = 'Enhanced terminal with tabbed SSH, RDP, VNC, SFTP, X11, and port forwarding in one app'
        Manager         = 'winget'
        PackageId       = 'Mobatek.MobaXterm'
        Notes           = 'Installs Home/free edition. Copy MobaXterm.mlic from your toolbox folder post-install to activate your license.'
    },
    @{
        Name            = 'PuTTY'
        Category        = 'Network Tools'
        Description     = 'Classic SSH and Telnet client - included as a lightweight fallback'
        Manager         = 'winget'
        PackageId       = 'PuTTY.PuTTY'
    },
    @{
        Name            = 'Nmap'
        Category        = 'Network Tools'
        Description     = 'Network discovery and port scanning - includes Zenmap GUI and Nping'
        Manager         = 'winget'
        PackageId       = 'Insecure.Nmap'
    },
    @{
        Name            = 'Wireshark'
        Category        = 'Network Tools'
        Description     = 'Network protocol analyzer - deep packet inspection and capture'
        Manager         = 'winget'
        PackageId       = 'WiresharkFoundation.Wireshark'
    },
    @{
        Name            = 'PortQryUI'
        Category        = 'Network Tools'
        Description     = 'GUI front-end for PortQry - test TCP/UDP port connectivity and query service endpoints'
        Manager         = 'manual'
        PackageId       = 'https://www.microsoft.com/en-us/download/details.aspx?id=24009'
        Notes           = 'No package manager entry. Download from Microsoft.'
    },

    # ── Azure & Cloud Tools ───────────────────────────────────────────────────
    @{
        Name            = 'Azure CLI'
        Category        = 'Azure & Cloud Tools'
        Description     = 'az command-line interface for managing Azure resources - subscriptions, VMs, networking, storage'
        Manager         = 'winget'
        PackageId       = 'Microsoft.AzureCLI'
    },
    @{
        Name            = 'Azure Storage Explorer'
        Category        = 'Azure & Cloud Tools'
        Description     = 'GUI for Azure blobs, files, queues, tables, and Cosmos DB - upload, download, manage'
        Manager         = 'winget'
        PackageId       = 'Microsoft.AzureStorageExplorer'
    },
    @{
        Name            = 'Azure Data Studio'
        Category        = 'Azure & Cloud Tools'
        Description     = 'Cross-platform database tool for SQL Server, Azure SQL, and PostgreSQL'
        Manager         = 'winget'
        PackageId       = 'Microsoft.AzureDataStudio'
    },

    # ── Virtualization & Remote ───────────────────────────────────────────────
    @{
        Name            = 'RVTools'
        Category        = 'Virtualization & Remote'
        Description     = 'VMware/vSphere inventory and health reporting - exports full VM, host, and datastore details to Excel'
        Manager         = 'winget'
        PackageId       = 'RobWare.RVTools'
    },

    # ── AI Tools ─────────────────────────────────────────────────────────────
    @{
        Name            = 'ChatGPT'
        Category        = 'AI Tools'
        Description     = 'ChatGPT desktop application'
        Manager         = 'winget'
        PackageId       = '9nt1r1c2hh7j'
        Notes           = 'Microsoft Store app ID'
    },
    @{
        Name            = 'Claude'
        Category        = 'AI Tools'
        Description     = 'Claude desktop application'
        Manager         = 'winget'
        PackageId       = 'Anthropic.Claude'
        Notes           = 'Microsoft Store app ID'
    },

    # ── PowerShell Modules ────────────────────────────────────────────────────
    @{
        Name            = 'Az (Azure PowerShell)'
        Category        = 'PowerShell Modules'
        Description     = 'Azure PowerShell module - manage all Azure services: Compute, Networking, Storage, RBAC, Key Vault'
        Manager         = 'psgallery'
        PackageId       = 'Az'
    },
    @{
        Name            = 'Microsoft Graph SDK'
        Category        = 'PowerShell Modules'
        Description     = 'MS Graph PowerShell - Intune, Entra ID (Azure AD), Exchange Online, Teams, SharePoint via Graph API'
        Manager         = 'psgallery'
        PackageId       = 'Microsoft.Graph'
        Notes           = 'Large install (~500 MB). Includes all Graph service submodules.'
    },
    @{
        Name            = 'Exchange Online Management'
        Category        = 'PowerShell Modules'
        Description     = 'Connect-ExchangeOnline and full Exchange Online/M365 mail administration cmdlets'
        Manager         = 'psgallery'
        PackageId       = 'ExchangeOnlineManagement'
    },
    @{
        Name            = 'Posh-SSH'
        Category        = 'PowerShell Modules'
        Description     = 'SSH and SFTP sessions directly from PowerShell - useful for scripting against Linux/network gear'
        Manager         = 'psgallery'
        PackageId       = 'Posh-SSH'
    },
    @{
        Name            = 'PSWindowsUpdate'
        Category        = 'PowerShell Modules'
        Description     = 'Manage Windows Update from PowerShell - Get, install, and schedule updates via script'
        Manager         = 'psgallery'
        PackageId       = 'PSWindowsUpdate'
    },

    # ── Windows Features (RSAT) ───────────────────────────────────────────────
    @{
        Name            = 'RSAT: Active Directory'
        Category        = 'Windows Features'
        Description     = 'ADUC, ADSI Edit, Sites & Services, Schema snap-in - full AD DS and AD LDS management'
        Manager         = 'feature'
        PackageId       = 'Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0'
    },
    @{
        Name            = 'RSAT: Certificate Services'
        Category        = 'Windows Features'
        Description     = 'Certificate Authority MMC snap-in - issue, revoke, and manage certs on enterprise CA'
        Manager         = 'feature'
        PackageId       = 'Rsat.CertificateServices.Tools~~~~0.0.1.0'
    },
    @{
        Name            = 'RSAT: DNS Server'
        Category        = 'Windows Features'
        Description     = 'Remote DNS zone and record management via DNS Manager MMC'
        Manager         = 'feature'
        PackageId       = 'Rsat.Dns.Tools~~~~0.0.1.0'
    },
    @{
        Name            = 'RSAT: DHCP Server'
        Category        = 'Windows Features'
        Description     = 'Remote DHCP scope, lease, and reservation management'
        Manager         = 'feature'
        PackageId       = 'Rsat.DHCP.Tools~~~~0.0.1.0'
    },
    @{
        Name            = 'RSAT: Group Policy Management'
        Category        = 'Windows Features'
        Description     = 'GPMC — create, edit, link, and model GPOs across the domain'
        Manager         = 'feature'
        PackageId       = 'Rsat.GroupPolicy.Management.Tools~~~~0.0.1.0'
    },
    @{
        Name            = 'RSAT: Remote Desktop Services'
        Category        = 'Windows Features'
        Description     = 'Manage RDS deployments, session hosts, connection brokers, and RDS licensing'
        Manager         = 'feature'
        PackageId       = 'Rsat.RemoteDesktop.Services.Tools~~~~0.0.1.0'
    },
    @{
        Name            = 'RSAT: Failover Clustering'
        Category        = 'Windows Features'
        Description     = 'Failover Cluster Manager — manage Windows Server clusters and cluster-aware updating'
        Manager         = 'feature'
        PackageId       = 'Rsat.FailoverCluster.Management.Tools~~~~0.0.1.0'
    },
    @{
        Name            = 'RSAT: BitLocker Recovery'
        Category        = 'Windows Features'
        Description     = 'BitLocker Recovery Password Viewer — read recovery keys from AD computer objects'
        Manager         = 'feature'
        PackageId       = 'Rsat.BitLocker.Recovery.Tools~~~~0.0.1.0'
    },
    @{
        Name            = 'RSAT: File Services'
        Category        = 'Windows Features'
        Description     = 'File Server Resource Manager and Services for NFS MMC snap-ins'
        Manager         = 'feature'
        PackageId       = 'Rsat.FileServices.Tools~~~~0.0.1.0'
    },
    @{
        Name            = 'RSAT: IP Address Management (IPAM) Client'
        Category        = 'Windows Features'
        Description     = 'IPAM console — manage IP address space, DNS, and DHCP from one place'
        Manager         = 'feature'
        PackageId       = 'Rsat.IPAM.Client.Tools~~~~0.0.1.0'
    },
    @{
        Name            = 'RSAT: LLDP Tools'
        Category        = 'Windows Features'
        Description     = 'Link Layer Discovery Protocol — view neighboring network device info'
        Manager         = 'feature'
        PackageId       = 'Rsat.LLDP.Tools~~~~0.0.1.0'
    },
    @{
        Name            = 'RSAT: Network Controller'
        Category        = 'Windows Features'
        Description     = 'PowerShell module for managing Network Controller in SDN deployments'
        Manager         = 'feature'
        PackageId       = 'Rsat.NetworkController.Tools~~~~0.0.1.0'
    },
    @{
        Name            = 'RSAT: Network Load Balancing'
        Category        = 'Windows Features'
        Description     = 'NLB Manager — configure and monitor Network Load Balancing clusters'
        Manager         = 'feature'
        PackageId       = 'Rsat.NetworkLoadBalancing.Tools~~~~0.0.1.0'
    },
    @{
        Name            = 'RSAT: Remote Access Management'
        Category        = 'Windows Features'
        Description     = 'Manage DirectAccess, VPN, and routing via Remote Access Management Console'
        Manager         = 'feature'
        PackageId       = 'Rsat.RemoteAccess.Management.Tools~~~~0.0.1.0'
    },
    @{
        Name            = 'RSAT: Server Manager'
        Category        = 'Windows Features'
        Description     = 'Server Manager console — manage roles, features, and remote servers'
        Manager         = 'feature'
        PackageId       = 'Rsat.ServerManager.Tools~~~~0.0.1.0'
    },
    @{
        Name            = 'RSAT: Shielded VM Tools'
        Category        = 'Windows Features'
        Description     = 'Manage Shielded VM templates and Host Guardian Service'
        Manager         = 'feature'
        PackageId       = 'Rsat.Shielded.VM.Tools~~~~0.0.1.0'
    },
    @{
        Name            = 'RSAT: Storage Migration Service'
        Category        = 'Windows Features'
        Description     = 'Storage Migration Service Management — orchestrate server storage migrations'
        Manager         = 'feature'
        PackageId       = 'Rsat.StorageMigrationService.Management.Tools~~~~0.0.1.0'
    },
    @{
        Name            = 'RSAT: Storage Replica'
        Category        = 'Windows Features'
        Description     = 'PowerShell module for configuring and monitoring Storage Replica'
        Manager         = 'feature'
        PackageId       = 'Rsat.StorageReplica.Tools~~~~0.0.1.0'
    },
    @{
        Name            = 'RSAT: System Insights'
        Category        = 'Windows Features'
        Description     = 'PowerShell module for System Insights predictive analytics capabilities'
        Manager         = 'feature'
        PackageId       = 'Rsat.SystemInsights.Management.Tools~~~~0.0.1.0'
    },
    @{
        Name            = 'RSAT: Volume Activation'
        Category        = 'Windows Features'
        Description     = 'Volume Activation Tools — manage KMS/MAK activation via VAMT'
        Manager         = 'feature'
        PackageId       = 'Rsat.VolumeActivation.Tools~~~~0.0.1.0'
    },
    @{
        Name            = 'RSAT: WSUS Tools'
        Category        = 'Windows Features'
        Description     = 'Windows Server Update Services console and PowerShell module'
        Manager         = 'feature'
        PackageId       = 'Rsat.WSUS.Tools~~~~0.0.1.0'
    },
    @{
        Name            = 'RSAT: All Tools'
        Category        = 'Windows Features'
        Description     = 'Installs every RSAT capability above in one go — convenience option for full admin workstations'
        Manager         = 'feature-group'
        PackageId       = 'Rsat*'
        Notes           = 'Enables all not-yet-installed Rsat.* Windows capabilities; selecting individual RSAT tools above is unnecessary if you pick this'
    }
)
