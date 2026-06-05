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
#
# DefaultWork / DefaultPersonal: pre-selected state in the interactive menu
# for each profile. User can always toggle before installing.

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
        Description     = 'Modern tabbed terminal — Command Prompt, PowerShell, WSL, Azure Cloud Shell'
        Manager         = 'winget'
        PackageId       = 'Microsoft.WindowsTerminal'
        DefaultWork     = $true
        DefaultPersonal = $true
    },
    @{
        Name            = 'PowerShell 7'
        Category        = 'Shell & Terminal'
        Description     = 'Cross-platform PowerShell (PS7+) — runs side-by-side with Windows PowerShell 5.1'
        Manager         = 'winget'
        PackageId       = 'Microsoft.PowerShell'
        DefaultWork     = $true
        DefaultPersonal = $true
    },
    @{
        Name            = 'Oh My Posh'
        Category        = 'Shell & Terminal'
        Description     = 'Prompt theme engine for PowerShell and other shells'
        Manager         = 'winget'
        PackageId       = 'JanDeDobbeleer.OhMyPosh'
        DefaultWork     = $true
        DefaultPersonal = $true
    },

    # ── Browsers ─────────────────────────────────────────────────────────────
    @{
        Name            = 'Google Chrome'
        Category        = 'Browsers'
        Description     = 'Google Chrome browser'
        Manager         = 'winget'
        PackageId       = 'Google.Chrome'
        DefaultWork     = $true
        DefaultPersonal = $false
    },
    @{
        Name            = 'Mozilla Firefox'
        Category        = 'Browsers'
        Description     = 'Firefox browser'
        Manager         = 'winget'
        PackageId       = 'Mozilla.Firefox'
        DefaultWork     = $true
        DefaultPersonal = $false
    },
    @{
        Name            = 'Firefox Developer Edition'
        Category        = 'Browsers'
        Description     = 'Firefox with experimental dev tools and WebExtensions debugging'
        Manager         = 'winget'
        PackageId       = 'Mozilla.FirefoxDeveloperEdition'
        DefaultWork     = $false
        DefaultPersonal = $false
    },
    @{
        Name            = 'Brave Browser'
        Category        = 'Browsers'
        Description     = 'Privacy-focused browser with built-in ad/tracker blocking and Shields'
        Manager         = 'winget'
        PackageId       = 'Brave.Brave'
        DefaultWork     = $false
        DefaultPersonal = $true
    },

    # ── Dev Tools ────────────────────────────────────────────────────────────
    @{
        Name            = 'VS Code'
        Category        = 'Dev Tools'
        Description     = 'Visual Studio Code — lightweight editor with extensions for nearly everything'
        Manager         = 'winget'
        PackageId       = 'Microsoft.VisualStudioCode'
        DefaultWork     = $true
        DefaultPersonal = $true
    },
    @{
        Name            = 'Git'
        Category        = 'Dev Tools'
        Description     = 'Git version control — includes Git Bash and credential manager'
        Manager         = 'winget'
        PackageId       = 'Git.Git'
        DefaultWork     = $false
        DefaultPersonal = $true
    },
    @{
        Name            = 'GitHub Desktop'
        Category        = 'Dev Tools'
        Description     = 'GitHub GUI client for managing repos without the CLI'
        Manager         = 'winget'
        PackageId       = 'GitHub.GitHubDesktop'
        DefaultWork     = $false
        DefaultPersonal = $true
    },
    @{
        Name            = 'WinMerge'
        Category        = 'Dev Tools'
        Description     = 'File and folder diff/merge tool — great for config comparisons'
        Manager         = 'winget'
        PackageId       = 'WinMerge.WinMerge'
        DefaultWork     = $true
        DefaultPersonal = $true
    },
    @{
        Name            = 'Windows PowerToys'
        Category        = 'Dev Tools'
        Description     = "Microsoft's power-user utility collection — FancyZones, PowerRename, Run launcher, and more"
        Manager         = 'winget'
        PackageId       = 'Microsoft.PowerToys'
        DefaultWork     = $true
        DefaultPersonal = $true
    },
    @{
        Name            = 'jq'
        Category        = 'Dev Tools'
        Description     = 'Lightweight command-line JSON processor — essential for scripting against APIs'
        Manager         = 'scoop'
        PackageId       = 'jq'
        ScoopBucket     = 'main'
        DefaultWork     = $false
        DefaultPersonal = $false
    },
    @{
        Name            = 'yq'
        Category        = 'Dev Tools'
        Description     = 'Command-line YAML/JSON/XML/CSV processor — like jq but for structured config files'
        Manager         = 'scoop'
        PackageId       = 'yq'
        ScoopBucket     = 'main'
        DefaultWork     = $false
        DefaultPersonal = $false
    },

    # ── Productivity ─────────────────────────────────────────────────────────
    @{
        Name            = 'Notepad++'
        Category        = 'Productivity'
        Description     = 'Feature-rich text and code editor — tabs, macros, multi-cursor, plugin ecosystem'
        Manager         = 'winget'
        PackageId       = 'Notepad++.Notepad++'
        DefaultWork     = $true
        DefaultPersonal = $true
    },
    @{
        Name            = 'Notepads App'
        Category        = 'Productivity'
        Description     = 'Modern minimal notepad for quick notes — clean UX, tabbed'
        Manager         = 'winget'
        PackageId       = 'JamieOleary.Notepads'
        DefaultWork     = $true
        DefaultPersonal = $true
        Notes           = 'If install fails by ID, try: winget install -e --name "Notepads App"'
    },
    @{
        Name            = '7-Zip'
        Category        = 'Productivity'
        Description     = 'File archiver and compression utility — handles ZIP, 7z, RAR, ISO, and more'
        Manager         = 'winget'
        PackageId       = '7zip.7zip'
        DefaultWork     = $true
        DefaultPersonal = $true
    },
    @{
        Name            = 'Snipaste'
        Category        = 'Productivity'
        Description     = 'Screen capture, recording, and annotation — scrolling capture, OCR, upload workflows'
        Manager         = 'winget'
        PackageId       = 'liule.Snipaste'
        DefaultWork     = $true
        DefaultPersonal = $true
    },

    # ── Media & Graphics ─────────────────────────────────────────────────────
    @{
        Name            = 'VLC'
        Category        = 'Media & Graphics'
        Description     = 'Universal media player — plays virtually any format without extra codecs'
        Manager         = 'winget'
        PackageId       = 'VideoLAN.VLC'
        DefaultWork     = $false
        DefaultPersonal = $true
    },
    @{
        Name            = 'Paint.NET'
        Category        = 'Media & Graphics'
        Description     = 'Image editor with layers, adjustments, and a rich plugin library'
        Manager         = 'winget'
        PackageId       = 'dotPDN.PaintDotNet'
        DefaultWork     = $false
        DefaultPersonal = $true
    },

    # ── File Management ───────────────────────────────────────────────────────
    @{
        Name            = 'WinSCP'
        Category        = 'File Management'
        Description     = 'SFTP, FTP, S3, SCP, and WebDAV client — built-in scripting support'
        Manager         = 'winget'
        PackageId       = 'WinSCP.WinSCP'
        DefaultWork     = $true
        DefaultPersonal = $false
    },
    @{
        Name            = 'FileZilla'
        Category        = 'File Management'
        Description     = 'FTP/SFTP/FTPS client — reliable fallback when WinSCP is not enough'
        Manager         = 'choco'
        PackageId       = 'filezilla'
        DefaultWork     = $false
        DefaultPersonal = $true
    },
    @{
        Name            = 'WizTree'
        Category        = 'File Management'
        Description     = 'Disk space analyzer — reads the MFT directly, results in seconds on any drive size'
        Manager         = 'winget'
        PackageId       = 'AntibodySoftware.WizTree'
        DefaultWork     = $true
        DefaultPersonal = $true
    },

    # ── Admin & Security Tools ────────────────────────────────────────────────
    @{
        Name            = 'SysInternals Suite'
        Category        = 'Admin & Security Tools'
        Description     = 'Complete Microsoft Sysinternals toolkit — Process Explorer, PsExec, AutoRuns, TCPView, and 70+ more'
        Manager         = 'winget'
        PackageId       = 'Microsoft.Sysinternals.Suite'
        DefaultWork     = $true
        DefaultPersonal = $false
    },
    @{
        Name            = 'IIS Crypto'
        Category        = 'Admin & Security Tools'
        Description     = 'GUI tool to configure TLS versions, cipher suites, and protocol settings on Windows/IIS'
        Manager         = 'choco'
        PackageId       = 'iiscrypto'
        DefaultWork     = $true
        DefaultPersonal = $false
    },
    @{
        Name            = 'OpenSSL for Windows'
        Category        = 'Admin & Security Tools'
        Description     = 'OpenSSL binaries — CSR generation, cert inspection, key operations, TLS debugging'
        Manager         = 'winget'
        PackageId       = 'ShiningLight.OpenSSL'
        DefaultWork     = $true
        DefaultPersonal = $false
    },
    @{
        Name            = 'LockHunter'
        Category        = 'Admin & Security Tools'
        Description     = 'Find what process is locking a file or folder — unlock and delete without rebooting'
        Manager         = 'winget'
        PackageId       = 'Crystal.LockHunter'
        DefaultWork     = $true
        DefaultPersonal = $false
    },
    @{
        Name            = 'Rufus'
        Category        = 'Admin & Security Tools'
        Description     = 'Bootable USB drive creator — fast, reliable, supports Windows and Linux ISOs'
        Manager         = 'winget'
        PackageId       = 'Rufus.Rufus'
        DefaultWork     = $true
        DefaultPersonal = $true
    },
    @{
        Name            = 'LGPO'
        Category        = 'Admin & Security Tools'
        Description     = 'Microsoft Local Group Policy Object utility — apply/export/import GPO settings on non-domain machines'
        Manager         = 'manual'
        PackageId       = 'https://www.microsoft.com/en-us/download/details.aspx?id=55319'
        DefaultWork     = $false
        DefaultPersonal = $false
        Notes           = 'No package manager entry. Download from Microsoft Security Compliance Toolkit.'
    },
    @{
        Name            = 'Windows Admin Center'
        Category        = 'Admin & Security Tools'
        Description     = "Microsoft's browser-based server management — replaces many MMC snap-ins with a modern UI"
        Manager         = 'winget'
        PackageId       = 'Microsoft.WindowsAdminCenter'
        DefaultWork     = $false
        DefaultPersonal = $false
        Notes           = 'Installs as a local HTTPS service. Choose port during install (default 443 or 6516).'
    },

    # ── Network Tools ─────────────────────────────────────────────────────────
    @{
        Name            = 'MobaXterm'
        Category        = 'Network Tools'
        Description     = 'Enhanced terminal with tabbed SSH, RDP, VNC, SFTP, X11, and port forwarding in one app'
        Manager         = 'winget'
        PackageId       = 'Mobatek.MobaXterm'
        DefaultWork     = $true
        DefaultPersonal = $false
        Notes           = 'Installs Home/free edition. Copy MobaXterm.mlic from your toolbox folder post-install to activate your license.'
    },
    @{
        Name            = 'PuTTY'
        Category        = 'Network Tools'
        Description     = 'Classic SSH and Telnet client — included as a lightweight fallback'
        Manager         = 'winget'
        PackageId       = 'PuTTY.PuTTY'
        DefaultWork     = $false
        DefaultPersonal = $false
    },
    @{
        Name            = 'Nmap'
        Category        = 'Network Tools'
        Description     = 'Network discovery and port scanning — includes Zenmap GUI and Nping'
        Manager         = 'winget'
        PackageId       = 'Insecure.Nmap'
        DefaultWork     = $false
        DefaultPersonal = $false
    },
    @{
        Name            = 'Wireshark'
        Category        = 'Network Tools'
        Description     = 'Network protocol analyzer — deep packet inspection and capture'
        Manager         = 'winget'
        PackageId       = 'WiresharkFoundation.Wireshark'
        DefaultWork     = $false
        DefaultPersonal = $false
    },
    @{
        Name            = 'PortQryUI'
        Category        = 'Network Tools'
        Description     = 'GUI front-end for PortQry — test TCP/UDP port connectivity and query service endpoints'
        Manager         = 'manual'
        PackageId       = 'https://www.microsoft.com/en-us/download/details.aspx?id=24009'
        DefaultWork     = $false
        DefaultPersonal = $false
        Notes           = 'No package manager entry. Download from Microsoft.'
    },

    # ── Azure & Cloud Tools ───────────────────────────────────────────────────
    @{
        Name            = 'Azure CLI'
        Category        = 'Azure & Cloud Tools'
        Description     = 'az command-line interface for managing Azure resources — subscriptions, VMs, networking, storage'
        Manager         = 'winget'
        PackageId       = 'Microsoft.AzureCLI'
        DefaultWork     = $true
        DefaultPersonal = $false
    },
    @{
        Name            = 'Azure Storage Explorer'
        Category        = 'Azure & Cloud Tools'
        Description     = 'GUI for Azure blobs, files, queues, tables, and Cosmos DB — upload, download, manage'
        Manager         = 'winget'
        PackageId       = 'Microsoft.AzureStorageExplorer'
        DefaultWork     = $true
        DefaultPersonal = $false
    },
    @{
        Name            = 'Azure Data Studio'
        Category        = 'Azure & Cloud Tools'
        Description     = 'Cross-platform database tool for SQL Server, Azure SQL, and PostgreSQL'
        Manager         = 'winget'
        PackageId       = 'Microsoft.AzureDataStudio'
        DefaultWork     = $false
        DefaultPersonal = $false
    },

    # ── Virtualization & Remote ───────────────────────────────────────────────
    @{
        Name            = 'RVTools'
        Category        = 'Virtualization & Remote'
        Description     = 'VMware/vSphere inventory and health reporting — exports full VM, host, and datastore details to Excel'
        Manager         = 'winget'
        PackageId       = 'RobWare.RVTools'
        DefaultWork     = $true
        DefaultPersonal = $false
    },

    # ── AI Tools ─────────────────────────────────────────────────────────────
    @{
        Name            = 'ChatGPT'
        Category        = 'AI Tools'
        Description     = 'ChatGPT desktop application'
        Manager         = 'winget'
        PackageId       = '9nt1r1c2hh7j'
        DefaultWork     = $false
        DefaultPersonal = $true
        Notes           = 'Microsoft Store app ID'
    },

    # ── PowerShell Modules ────────────────────────────────────────────────────
    @{
        Name            = 'Az (Azure PowerShell)'
        Category        = 'PowerShell Modules'
        Description     = 'Azure PowerShell module — manage all Azure services: Compute, Networking, Storage, RBAC, Key Vault'
        Manager         = 'psgallery'
        PackageId       = 'Az'
        DefaultWork     = $true
        DefaultPersonal = $false
    },
    @{
        Name            = 'Microsoft Graph SDK'
        Category        = 'PowerShell Modules'
        Description     = 'MS Graph PowerShell — Intune, Entra ID (Azure AD), Exchange Online, Teams, SharePoint via Graph API'
        Manager         = 'psgallery'
        PackageId       = 'Microsoft.Graph'
        DefaultWork     = $true
        DefaultPersonal = $false
        Notes           = 'Large install (~500 MB). Includes all Graph service submodules.'
    },
    @{
        Name            = 'Exchange Online Management'
        Category        = 'PowerShell Modules'
        Description     = 'Connect-ExchangeOnline and full Exchange Online/M365 mail administration cmdlets'
        Manager         = 'psgallery'
        PackageId       = 'ExchangeOnlineManagement'
        DefaultWork     = $false
        DefaultPersonal = $false
    },
    @{
        Name            = 'Posh-SSH'
        Category        = 'PowerShell Modules'
        Description     = 'SSH and SFTP sessions directly from PowerShell — useful for scripting against Linux/network gear'
        Manager         = 'psgallery'
        PackageId       = 'Posh-SSH'
        DefaultWork     = $false
        DefaultPersonal = $false
    },
    @{
        Name            = 'PSWindowsUpdate'
        Category        = 'PowerShell Modules'
        Description     = 'Manage Windows Update from PowerShell — Get, install, and schedule updates via script'
        Manager         = 'psgallery'
        PackageId       = 'PSWindowsUpdate'
        DefaultWork     = $true
        DefaultPersonal = $true
    },

    # ── Windows Features (RSAT) ───────────────────────────────────────────────
    @{
        Name            = 'RSAT: Active Directory'
        Category        = 'Windows Features'
        Description     = 'ADUC, ADSI Edit, Sites & Services, Schema snap-in — full AD DS and AD LDS management'
        Manager         = 'feature'
        PackageId       = 'Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0'
        DefaultWork     = $true
        DefaultPersonal = $false
    },
    @{
        Name            = 'RSAT: Certificate Services'
        Category        = 'Windows Features'
        Description     = 'Certificate Authority MMC snap-in — issue, revoke, and manage certs on enterprise CA'
        Manager         = 'feature'
        PackageId       = 'Rsat.CertificateServices.Tools~~~~0.0.1.0'
        DefaultWork     = $true
        DefaultPersonal = $false
    },
    @{
        Name            = 'RSAT: DNS Server'
        Category        = 'Windows Features'
        Description     = 'Remote DNS zone and record management via DNS Manager MMC'
        Manager         = 'feature'
        PackageId       = 'Rsat.Dns.Tools~~~~0.0.1.0'
        DefaultWork     = $true
        DefaultPersonal = $false
    },
    @{
        Name            = 'RSAT: DHCP Server'
        Category        = 'Windows Features'
        Description     = 'Remote DHCP scope, lease, and reservation management'
        Manager         = 'feature'
        PackageId       = 'Rsat.DHCP.Tools~~~~0.0.1.0'
        DefaultWork     = $false
        DefaultPersonal = $false
    },
    @{
        Name            = 'RSAT: Group Policy Management'
        Category        = 'Windows Features'
        Description     = 'GPMC — create, edit, link, and model GPOs across the domain'
        Manager         = 'feature'
        PackageId       = 'Rsat.GroupPolicy.Management.Tools~~~~0.0.1.0'
        DefaultWork     = $true
        DefaultPersonal = $false
    },
    @{
        Name            = 'RSAT: Remote Desktop Services'
        Category        = 'Windows Features'
        Description     = 'Manage RDS deployments, session hosts, connection brokers, and RDS licensing'
        Manager         = 'feature'
        PackageId       = 'Rsat.RemoteDesktop.Services.Tools~~~~0.0.1.0'
        DefaultWork     = $false
        DefaultPersonal = $false
    },
    @{
        Name            = 'RSAT: Failover Clustering'
        Category        = 'Windows Features'
        Description     = 'Failover Cluster Manager — manage Windows Server clusters and cluster-aware updating'
        Manager         = 'feature'
        PackageId       = 'Rsat.FailoverCluster.Management.Tools~~~~0.0.1.0'
        DefaultWork     = $false
        DefaultPersonal = $false
    }
)
