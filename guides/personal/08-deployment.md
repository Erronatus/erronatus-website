# Chapter 8: Deployment & Persistence
*The Erronatus Blueprint Personal Edition*

## The Persistence Problem

Your AI agent is brilliant when you're actively chatting. But the moment you close your laptop, restart your computer, or lose internet connection, everything stops. Your morning briefings vanish. Market monitors go silent. The system that was making you money goes to sleep.

**Non-persistent AI (typical setup):**
```
9:00 AM: Start OpenClaw manually
9:01 AM: Agent begins morning routine
...
6:00 PM: Close laptop for dinner
6:01 PM: OpenClaw stops, cron jobs die
8:00 PM: Market moves 2%, no alerts sent
11:59 PM: System backup never runs
```

**Persistent AI (proper deployment):**
```
System boots: OpenClaw auto-starts
Power outage: OpenClaw restarts when power returns
Internet hiccup: OpenClaw reconnects automatically
You travel: Agent keeps working from home base
You sleep: Morning briefing generates at 8 AM sharp
```

This chapter teaches you to deploy OpenClaw as a persistent service across Windows, macOS, and Linux, ensuring your AI operations continue 24/7 regardless of what happens to your computer.

## Running OpenClaw Persistently

The goal is simple: OpenClaw should start when your computer boots and restart if it crashes. This requires configuring your operating system to treat OpenClaw as a system service.

### Core Requirements
- **Auto-start**: OpenClaw begins when computer boots
- **Auto-restart**: Recovers from crashes or failures  
- **Background execution**: Runs without user login
- **Log management**: Captures errors and activity
- **Remote control**: Start/stop/restart from anywhere

## Windows Deployment

Windows offers two robust methods for running persistent services: NSSM (Non-Sucking Service Manager) and Task Scheduler. NSSM is cleaner for long-running services, while Task Scheduler offers more granular control.

### Method 1: NSSM (Recommended)

NSSM transforms any executable into a proper Windows service with automatic restart, logging, and management capabilities.

#### Install NSSM

```powershell
# Option 1: Install via Chocolatey (if you have it)
choco install nssm

# Option 2: Download manually
# Go to https://nssm.cc/download and download nssm-2.24.zip
# Extract to C:\nssm\ or any preferred location
# Add C:\nssm\win64\ to your PATH environment variable

# Option 3: Install via Scoop (if you have it)  
scoop install nssm

# Verify installation
nssm version
```

#### Configure OpenClaw Service

```powershell
# Run PowerShell as Administrator (required for service creation)

# Install OpenClaw as Windows service
nssm install OpenClawGateway

# Configure service parameters  
nssm set OpenClawGateway Application "C:\Program Files\nodejs\node.exe"
nssm set OpenClawGateway AppParameters "C:\Users\$env:USERNAME\AppData\Roaming\npm\node_modules\openclaw\bin\openclaw.js gateway start"
nssm set OpenClawGateway AppDirectory "C:\Users\$env:USERNAME\.openclaw"
nssm set OpenClawGateway DisplayName "OpenClaw AI Gateway"
nssm set OpenClawGateway Description "OpenClaw AI agent gateway service"

# Set startup type to automatic
nssm set OpenClawGateway Start SERVICE_AUTO_START

# Configure logging
nssm set OpenClawGateway AppStdout "C:\Users\$env:USERNAME\.openclaw\logs\gateway-stdout.log"
nssm set OpenClawGateway AppStderr "C:\Users\$env:USERNAME\.openclaw\logs\gateway-stderr.log"
nssm set OpenClawGateway AppRotateFiles 1
nssm set OpenClawGateway AppRotateOnline 1  
nssm set OpenClawGateway AppRotateSeconds 86400  # Daily rotation
nssm set OpenClawGateway AppRotateBytes 10485760  # 10MB max file size

# Set environment variables
nssm set OpenClawGateway AppEnvironmentExtra "NODE_ENV=production"

# Configure restart behavior
nssm set OpenClawGateway AppRestartDelay 30000  # Wait 30 seconds before restart
nssm set OpenClawGateway AppThrottle 10000      # Throttle rapid restarts

# Start the service
nssm start OpenClawGateway

# Verify service is running
nssm status OpenClawGateway
Get-Service OpenClawGateway
```

#### Service Management Commands

```powershell
# Start service
nssm start OpenClawGateway
# or
Start-Service OpenClawGateway

# Stop service  
nssm stop OpenClawGateway
# or
Stop-Service OpenClawGateway

# Restart service
nssm restart OpenClawGateway
# or
Restart-Service OpenClawGateway

# Check status
nssm status OpenClawGateway
Get-Service OpenClawGateway | Format-List *

# View logs
Get-Content "C:\Users\$env:USERNAME\.openclaw\logs\gateway-stdout.log" -Tail 20
Get-Content "C:\Users\$env:USERNAME\.openclaw\logs\gateway-stderr.log" -Tail 20

# Remove service (if needed)
nssm stop OpenClawGateway
nssm remove OpenClawGateway confirm
```

### Method 2: Task Scheduler Alternative

Task Scheduler provides more granular control and doesn't require third-party tools.

#### Create Scheduled Task

```powershell
# Create task scheduler configuration
$TaskName = "OpenClawGateway"
$TaskDescription = "OpenClaw AI Gateway - Persistent Service"
$TaskPath = "C:\Users\$env:USERNAME\AppData\Roaming\npm\node_modules\openclaw\bin\openclaw.js"
$TaskArgs = "gateway start"
$NodePath = "C:\Program Files\nodejs\node.exe"

# Register the scheduled task
$Action = New-ScheduledTaskAction -Execute $NodePath -Argument "$TaskPath $TaskArgs" -WorkingDirectory "C:\Users\$env:USERNAME\.openclaw"

$Trigger = New-ScheduledTaskTrigger -AtStartup

$Settings = New-ScheduledTaskSettingsSet -DontStopIfGoingOnBatteries -StartWhenAvailable -RestartInterval (New-TimeSpan -Minutes 5) -RestartCount 999 -ExecutionTimeLimit (New-TimeSpan -Hours 0)

$Principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -LogonType ServiceAccount

Register-ScheduledTask -TaskName $TaskName -Action $Action -Trigger $Trigger -Settings $Settings -Principal $Principal -Description $TaskDescription
```

#### Alternative: XML Configuration

For maximum control, create a complete XML configuration:

```xml
<!-- Save as OpenClawGateway.xml -->
<?xml version="1.0" encoding="UTF-16"?>
<Task version="1.4" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">
  <RegistrationInfo>
    <Date>2024-12-16T12:00:00</Date>
    <Author>OpenClaw User</Author>
    <Description>OpenClaw AI Gateway - Persistent Service</Description>
  </RegistrationInfo>
  <Triggers>
    <BootTrigger>
      <Enabled>true</Enabled>
      <Delay>PT30S</Delay>
    </BootTrigger>
  </Triggers>
  <Principals>
    <Principal id="Author">
      <UserId>%USERNAME%</UserId>
      <LogonType>ServiceAccount</LogonType>
      <RunLevel>HighestAvailable</RunLevel>
    </Principal>
  </Principals>
  <Settings>
    <MultipleInstancesPolicy>IgnoreNew</MultipleInstancesPolicy>
    <DisallowStartIfOnBatteries>false</DisallowStartIfOnBatteries>
    <StopIfGoingOnBatteries>false</StopIfGoingOnBatteries>
    <AllowHardTerminate>true</AllowHardTerminate>
    <StartWhenAvailable>true</StartWhenAvailable>
    <RunOnlyIfNetworkAvailable>true</RunOnlyIfNetworkAvailable>
    <IdleSettings>
      <StopOnIdleEnd>false</StopOnIdleEnd>
      <RestartOnIdle>false</RestartOnIdle>
    </IdleSettings>
    <AllowStartOnDemand>true</AllowStartOnDemand>
    <Enabled>true</Enabled>
    <Hidden>false</Hidden>
    <RunOnlyIfIdle>false</RunOnlyIfIdle>
    <DisallowStartOnRemoteAppSession>false</DisallowStartOnRemoteAppSession>
    <UseUnifiedSchedulingEngine>true</UseUnifiedSchedulingEngine>
    <WakeToRun>false</WakeToRun>
    <ExecutionTimeLimit>PT0S</ExecutionTimeLimit>
    <Priority>6</Priority>
    <RestartPolicy>
      <Interval>PT5M</Interval>
      <Count>999</Count>
    </RestartPolicy>
  </Settings>
  <Actions Context="Author">
    <Exec>
      <Command>C:\Program Files\nodejs\node.exe</Command>
      <Arguments>C:\Users\%USERNAME%\AppData\Roaming\npm\node_modules\openclaw\bin\openclaw.js gateway start</Arguments>
      <WorkingDirectory>C:\Users\%USERNAME%\.openclaw</WorkingDirectory>
    </Exec>
  </Actions>
</Task>
```

**Import the XML task:**
```powershell
# Import task from XML file
schtasks /create /xml "C:\path\to\OpenClawGateway.xml" /tn "OpenClawGateway"

# Start the task
schtasks /run /tn "OpenClawGateway"

# Check task status
schtasks /query /tn "OpenClawGateway" /fo LIST /v
```

#### Task Scheduler Management

```powershell
# Start task
schtasks /run /tn "OpenClawGateway"

# Stop task (end running instance)
schtasks /end /tn "OpenClawGateway"

# Enable task
schtasks /change /tn "OpenClawGateway" /enable

# Disable task  
schtasks /change /tn "OpenClawGateway" /disable

# Delete task
schtasks /delete /tn "OpenClawGateway" /f

# View task history
Get-WinEvent -FilterHashtable @{LogName="Microsoft-Windows-TaskScheduler/Operational"; ID=100,102,103,107,111} | Where-Object {$_.Message -like "*OpenClawGateway*"} | Select-Object TimeCreated, Id, LevelDisplayName, Message
```

## macOS Deployment

macOS uses launchd for service management. This is the same system that manages built-in macOS services.

### Create launchd Service

launchd services are defined in plist (property list) files. Create a complete configuration:

```xml
<!-- Save as ~/Library/LaunchAgents/com.openclaw.gateway.plist -->
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.openclaw.gateway</string>
    
    <key>ProgramArguments</key>
    <array>
        <string>/usr/local/bin/node</string>
        <string>/usr/local/lib/node_modules/openclaw/bin/openclaw.js</string>
        <string>gateway</string>
        <string>start</string>
    </array>
    
    <key>WorkingDirectory</key>
    <string>/Users/USERNAME/.openclaw</string>
    
    <key>RunAtLoad</key>
    <true/>
    
    <key>KeepAlive</key>
    <dict>
        <key>SuccessfulExit</key>
        <false/>
        <key>Crashed</key>
        <true/>
        <key>NetworkState</key>
        <true/>
    </dict>
    
    <key>ThrottleInterval</key>
    <integer>30</integer>
    
    <key>StandardOutPath</key>
    <string>/Users/USERNAME/.openclaw/logs/gateway-stdout.log</string>
    
    <key>StandardErrorPath</key>
    <string>/Users/USERNAME/.openclaw/logs/gateway-stderr.log</string>
    
    <key>EnvironmentVariables</key>
    <dict>
        <key>NODE_ENV</key>
        <string>production</string>
        <key>PATH</key>
        <string>/usr/local/bin:/usr/bin:/bin</string>
    </dict>
    
    <key>ProcessType</key>
    <string>Background</string>
    
    <key>LowPriorityIO</key>
    <false/>
    
    <key>Nice</key>
    <integer>0</integer>
</dict>
</plist>
```

### Install and Configure Service

```bash
# Create logs directory
mkdir -p ~/.openclaw/logs

# Copy plist file to LaunchAgents directory (replace USERNAME with your actual username)
cp ~/Desktop/com.openclaw.gateway.plist ~/Library/LaunchAgents/

# Set proper permissions
chmod 644 ~/Library/LaunchAgents/com.openclaw.gateway.plist

# Load the service
launchctl load ~/Library/LaunchAgents/com.openclaw.gateway.plist

# Enable the service to start at boot
launchctl enable gui/$(id -u)/com.openclaw.gateway

# Start the service immediately
launchctl start com.openclaw.gateway

# Verify service is running
launchctl list | grep openclaw
```

### Service Management Commands

```bash
# Start service
launchctl start com.openclaw.gateway

# Stop service
launchctl stop com.openclaw.gateway

# Restart service (stop + start)
launchctl stop com.openclaw.gateway && launchctl start com.openclaw.gateway

# Check service status
launchctl list com.openclaw.gateway

# View service configuration
launchctl print gui/$(id -u)/com.openclaw.gateway

# View logs
tail -f ~/.openclaw/logs/gateway-stdout.log
tail -f ~/.openclaw/logs/gateway-stderr.log

# Reload configuration after changes
launchctl unload ~/Library/LaunchAgents/com.openclaw.gateway.plist
launchctl load ~/Library/LaunchAgents/com.openclaw.gateway.plist

# Disable service (prevent auto-start)
launchctl disable gui/$(id -u)/com.openclaw.gateway

# Remove service completely
launchctl unload ~/Library/LaunchAgents/com.openclaw.gateway.plist
rm ~/Library/LaunchAgents/com.openclaw.gateway.plist
```

## Linux Deployment

Linux uses systemd for modern service management. This is the most robust and feature-rich deployment option.

### Create systemd Service

Create a complete systemd service file with proper dependencies and restart policies:

```ini
# Save as /etc/systemd/system/openclaw-gateway.service
[Unit]
Description=OpenClaw AI Gateway Service
Documentation=https://openclaw.com/docs
After=network.target network-online.target
Wants=network-online.target
StartLimitIntervalSec=300
StartLimitBurst=3

[Service]
Type=simple
User=%i
Group=%i
WorkingDirectory=/home/%i/.openclaw
Environment=NODE_ENV=production
Environment=PATH=/usr/local/bin:/usr/bin:/bin
ExecStart=/usr/bin/node /usr/local/lib/node_modules/openclaw/bin/openclaw.js gateway start
ExecReload=/bin/kill -HUP $MAINPID
KillMode=mixed
KillSignal=SIGTERM
TimeoutStopSec=30
Restart=on-failure
RestartSec=30
StandardOutput=append:/home/%i/.openclaw/logs/gateway-stdout.log
StandardError=append:/home/%i/.openclaw/logs/gateway-stderr.log

# Security settings
NoNewPrivileges=true
PrivateTmp=true
ProtectSystem=strict
ProtectHome=false
ReadWritePaths=/home/%i/.openclaw
ProtectKernelTunables=true
ProtectKernelModules=true
ProtectControlGroups=true

[Install]
WantedBy=multi-user.target
```

### Alternative: User Service (Non-root)

For running as a regular user without root privileges:

```ini
# Save as ~/.config/systemd/user/openclaw-gateway.service
[Unit]
Description=OpenClaw AI Gateway Service (User)
Documentation=https://openclaw.com/docs
After=network.target

[Service]
Type=simple
WorkingDirectory=%h/.openclaw
Environment=NODE_ENV=production
ExecStart=/usr/bin/node /home/%i/.npm-global/lib/node_modules/openclaw/bin/openclaw.js gateway start
ExecReload=/bin/kill -HUP $MAINPID
Restart=on-failure
RestartSec=30
StandardOutput=append:%h/.openclaw/logs/gateway-stdout.log
StandardError=append:%h/.openclaw/logs/gateway-stderr.log

[Install]
WantedBy=default.target
```

### Install and Configure Service

**System-wide service (requires root):**
```bash
# Create logs directory
sudo mkdir -p /home/$(whoami)/.openclaw/logs
sudo chown $(whoami):$(whoami) /home/$(whoami)/.openclaw/logs

# Copy service file
sudo cp openclaw-gateway.service /etc/systemd/system/

# Reload systemd configuration
sudo systemctl daemon-reload

# Enable service (auto-start at boot)
sudo systemctl enable openclaw-gateway@$(whoami)

# Start service immediately
sudo systemctl start openclaw-gateway@$(whoami)

# Check service status
sudo systemctl status openclaw-gateway@$(whoami)
```

**User service (no root required):**
```bash
# Create user systemd directory
mkdir -p ~/.config/systemd/user

# Create logs directory
mkdir -p ~/.openclaw/logs

# Copy service file
cp openclaw-gateway.service ~/.config/systemd/user/

# Reload user systemd configuration
systemctl --user daemon-reload

# Enable service (auto-start when user logs in)
systemctl --user enable openclaw-gateway

# Start service immediately  
systemctl --user start openclaw-gateway

# Check service status
systemctl --user status openclaw-gateway

# Enable lingering (service starts even if user not logged in)
sudo loginctl enable-linger $(whoami)
```

### Service Management Commands

**System service:**
```bash
# Start service
sudo systemctl start openclaw-gateway@$(whoami)

# Stop service
sudo systemctl stop openclaw-gateway@$(whoami)

# Restart service
sudo systemctl restart openclaw-gateway@$(whoami)

# Reload configuration
sudo systemctl reload openclaw-gateway@$(whoami)

# Check status
sudo systemctl status openclaw-gateway@$(whoami)

# Enable auto-start
sudo systemctl enable openclaw-gateway@$(whoami)

# Disable auto-start  
sudo systemctl disable openclaw-gateway@$(whoami)

# View logs
sudo journalctl -u openclaw-gateway@$(whoami) -f

# View logs since boot
sudo journalctl -u openclaw-gateway@$(whoami) -b
```

**User service:**
```bash
# Start service
systemctl --user start openclaw-gateway

# Stop service
systemctl --user stop openclaw-gateway

# Restart service  
systemctl --user restart openclaw-gateway

# Check status
systemctl --user status openclaw-gateway

# View logs
journalctl --user -u openclaw-gateway -f

# Check all user services
systemctl --user list-units --type=service
```

## Log Management

Proper logging is crucial for persistent services. You need to know what's happening when things go wrong.

### Log Location Strategy

**Windows:**
```
C:\Users\%USERNAME%\.openclaw\logs\
├── gateway-stdout.log    # Normal output
├── gateway-stderr.log    # Errors and warnings
└── service-events.log    # Service start/stop events
```

**macOS/Linux:**
```
~/.openclaw/logs/
├── gateway-stdout.log    # Normal output  
├── gateway-stderr.log    # Errors and warnings
├── cron-jobs.log         # Cron job execution
└── system-health.log     # Health check results
```

### Log Rotation Configuration

Large log files consume disk space and slow performance. Implement automatic rotation:

**Windows (via NSSM):**
```powershell
# Configure NSSM log rotation (already done in setup above)
nssm set OpenClawGateway AppRotateFiles 1
nssm set OpenClawGateway AppRotateSeconds 86400  # Daily
nssm set OpenClawGateway AppRotateBytes 10485760  # 10MB max
```

**macOS/Linux (via logrotate):**
```bash
# Create logrotate configuration
sudo tee /etc/logrotate.d/openclaw << 'EOF'
/home/*/. openclaw/logs/*.log {
    daily
    missingok
    rotate 14
    compress
    delaycompress
    notifempty
    copytruncate
    create 644 
}
EOF

# Test logrotate configuration
sudo logrotate -d /etc/logrotate.d/openclaw
```

### Custom Log Management Script

For platforms without built-in rotation, create your own:

```bash
#!/bin/bash
# Save as ~/.openclaw/scripts/rotate-logs.sh

LOG_DIR="$HOME/.openclaw/logs"
MAX_SIZE=10485760  # 10MB in bytes
KEEP_FILES=7       # Keep 7 days of logs

rotate_log() {
    local log_file="$1"
    local base_name=$(basename "$log_file" .log)
    
    # Check if file exceeds max size
    if [[ -f "$log_file" ]] && [[ $(stat -f%z "$log_file" 2>/dev/null || stat -c%s "$log_file") -gt $MAX_SIZE ]]; then
        # Rotate existing backup files
        for i in $(seq $((KEEP_FILES-1)) -1 1); do
            if [[ -f "$LOG_DIR/${base_name}-${i}.log.gz" ]]; then
                mv "$LOG_DIR/${base_name}-${i}.log.gz" "$LOG_DIR/${base_name}-$((i+1)).log.gz"
            fi
        done
        
        # Compress and move current log
        gzip -c "$log_file" > "$LOG_DIR/${base_name}-1.log.gz"
        > "$log_file"  # Clear current log
        
        # Remove old files
        rm -f "$LOG_DIR/${base_name}-$((KEEP_FILES+1)).log.gz"
        
        echo "$(date): Rotated $log_file"
    fi
}

# Rotate all log files
for log_file in "$LOG_DIR"/*.log; do
    [[ -f "$log_file" ]] && rotate_log "$log_file"
done
```

**Make it executable and schedule:**
```bash
chmod +x ~/.openclaw/scripts/rotate-logs.sh

# Add to cron (daily at 2 AM)
crontab -e
# Add line: 0 2 * * * /home/username/.openclaw/scripts/rotate-logs.sh
```

### Log Analysis Tools

**View recent errors:**
```bash
# Last 50 error lines across all logs
grep -i error ~/.openclaw/logs/*.log | tail -50

# Service restart events
grep -i "starting\|stopping\|restart" ~/.openclaw/logs/*.log

# Performance issues
grep -i "timeout\|slow\|memory" ~/.openclaw/logs/*.log
```

**Real-time monitoring:**
```bash
# Follow all logs simultaneously  
tail -f ~/.openclaw/logs/*.log

# Monitor for specific patterns
tail -f ~/.openclaw/logs/*.log | grep -E "(error|warning|critical)"

# Count errors per hour
grep "$(date '+%Y-%m-%d %H')" ~/.openclaw/logs/gateway-stderr.log | wc -l
```

## Updating OpenClaw Safely

Updates can break persistent services if not handled properly. Follow this procedure to update without downtime.

### Pre-Update Checklist

```bash
# 1. Check current version
openclaw --version

# 2. Backup configuration
cp -r ~/.openclaw ~/.openclaw-backup-$(date +%Y%m%d)

# 3. Stop service gracefully
# Windows (NSSM):
nssm stop OpenClawGateway
# macOS:  
launchctl stop com.openclaw.gateway
# Linux:
systemctl --user stop openclaw-gateway

# 4. Verify service is stopped
# Check that no openclaw processes are running
ps aux | grep openclaw
```

### Update Process

```bash
# 5. Update OpenClaw
npm update -g openclaw

# 6. Verify new version
openclaw --version

# 7. Test configuration
openclaw gateway start --test

# 8. Check that critical files still exist
ls ~/.openclaw/
ls ~/.openclaw/workspace/
```

### Post-Update Verification

```bash
# 9. Restart service
# Windows (NSSM):
nssm start OpenClawGateway
# macOS:
launchctl start com.openclaw.gateway  
# Linux:
systemctl --user start openclaw-gateway

# 10. Verify service started successfully
# Windows:
nssm status OpenClawGateway
# macOS:
launchctl list | grep openclaw
# Linux:
systemctl --user status openclaw-gateway

# 11. Test core functionality
openclaw status
openclaw cron list

# 12. Monitor logs for first few minutes
tail -f ~/.openclaw/logs/gateway-stdout.log
```

### Rollback Procedure

If the update breaks something:

```bash
# Stop new version
# (Use appropriate service stop command from above)

# Restore backup
rm -rf ~/.openclaw
mv ~/.openclaw-backup-$(date +%Y%m%d) ~/.openclaw

# Downgrade OpenClaw
npm install -g openclaw@previous-version

# Restart service
# (Use appropriate service start command from above)

# Verify rollback successful
openclaw --version
openclaw status
```

## Backup Strategy

A robust backup strategy protects against data loss, configuration corruption, and hardware failure.

### What to Back Up

**Critical files** (must backup):
```
~/.openclaw/
├── .env                 # API keys and secrets
├── config.json          # OpenClaw configuration
├── workspace/           # Your entire workspace
│   ├── SOUL.md
│   ├── USER.md  
│   ├── MEMORY.md
│   ├── memory/          # Daily logs
│   └── projects/        # Your work
└── logs/               # Optional but useful
```

**Non-critical files** (can recreate):
- Node modules  
- Temporary files
- Log files (unless needed for analysis)

### Backup Scripts

**Windows PowerShell backup:**
```powershell
# Save as ~/.openclaw/scripts/backup.ps1
param(
    [string]$BackupPath = "C:\Backups\OpenClaw",
    [switch]$IncludeLogs
)

$SourcePath = "$env:USERPROFILE\.openclaw"
$BackupName = "openclaw-backup-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
$FullBackupPath = Join-Path $BackupPath $BackupName

# Create backup directory
New-Item -ItemType Directory -Path $FullBackupPath -Force | Out-Null

# Files and directories to backup
$ItemsToBackup = @(
    ".env",
    "config.json", 
    "workspace"
)

if ($IncludeLogs) {
    $ItemsToBackup += "logs"
}

# Copy files
foreach ($Item in $ItemsToBackup) {
    $SourceItem = Join-Path $SourcePath $Item
    $DestItem = Join-Path $FullBackupPath $Item
    
    if (Test-Path $SourceItem) {
        if (Test-Path $SourceItem -PathType Container) {
            # Directory
            Copy-Item $SourceItem $DestItem -Recurse -Force
        } else {
            # File
            Copy-Item $SourceItem $DestItem -Force
        }
        Write-Host "✅ Backed up: $Item"
    } else {
        Write-Warning "⚠️ Not found: $Item"
    }
}

# Create backup info
@{
    BackupDate = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    OpenClawVersion = & openclaw --version
    ComputerName = $env:COMPUTERNAME
    Username = $env:USERNAME
} | ConvertTo-Json | Out-File "$FullBackupPath\backup-info.json"

# Compress backup
Compress-Archive -Path "$FullBackupPath\*" -DestinationPath "$FullBackupPath.zip"
Remove-Item $FullBackupPath -Recurse -Force

Write-Host "✅ Backup completed: $FullBackupPath.zip"

# Cleanup old backups (keep last 14)
Get-ChildItem $BackupPath -Filter "openclaw-backup-*.zip" | 
    Sort-Object CreationTime -Descending | 
    Select-Object -Skip 14 | 
    Remove-Item -Force

Write-Host "🗑️ Cleaned up old backups"
```

**macOS/Linux bash backup:**
```bash
#!/bin/bash
# Save as ~/.openclaw/scripts/backup.sh

BACKUP_DIR="$HOME/Backups/OpenClaw"
SOURCE_DIR="$HOME/.openclaw"
BACKUP_NAME="openclaw-backup-$(date +%Y%m%d-%H%M%S)"
INCLUDE_LOGS=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --backup-dir)
            BACKUP_DIR="$2"
            shift 2
            ;;
        --include-logs)
            INCLUDE_LOGS=true
            shift
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Create temporary backup directory
TEMP_DIR="$BACKUP_DIR/$BACKUP_NAME"
mkdir -p "$TEMP_DIR"

# Files and directories to backup
ITEMS_TO_BACKUP=(
    ".env"
    "config.json"
    "workspace"
)

if [[ "$INCLUDE_LOGS" == "true" ]]; then
    ITEMS_TO_BACKUP+=("logs")
fi

# Copy files
for item in "${ITEMS_TO_BACKUP[@]}"; do
    source_path="$SOURCE_DIR/$item"
    dest_path="$TEMP_DIR/$item"
    
    if [[ -e "$source_path" ]]; then
        if [[ -d "$source_path" ]]; then
            # Directory
            cp -r "$source_path" "$dest_path"
        else
            # File  
            cp "$source_path" "$dest_path"
        fi
        echo "✅ Backed up: $item"
    else
        echo "⚠️  Not found: $item"
    fi
done

# Create backup info
cat > "$TEMP_DIR/backup-info.json" << EOF
{
    "backupDate": "$(date -Iseconds)",
    "openClawVersion": "$(openclaw --version 2>/dev/null || echo 'unknown')",
    "hostname": "$(hostname)",
    "username": "$(whoami)",
    "osType": "$(uname -s)",
    "osVersion": "$(uname -r)"
}
EOF

# Compress backup
cd "$BACKUP_DIR"
tar -czf "$BACKUP_NAME.tar.gz" "$BACKUP_NAME/"
rm -rf "$BACKUP_NAME"

echo "✅ Backup completed: $BACKUP_DIR/$BACKUP_NAME.tar.gz"

# Cleanup old backups (keep last 14)
find "$BACKUP_DIR" -name "openclaw-backup-*.tar.gz" -type f -print0 | 
    xargs -0 ls -t | 
    tail -n +15 | 
    xargs rm -f

echo "🗑️ Cleaned up old backups"
```

**Make backup script executable:**
```bash
chmod +x ~/.openclaw/scripts/backup.sh
```

### Automated Backup Schedule

**Windows (Task Scheduler):**
```powershell
# Create scheduled backup task
$TaskName = "OpenClawBackup"
$ScriptPath = "C:\Users\$env:USERNAME\.openclaw\scripts\backup.ps1"
$BackupDir = "C:\Backups\OpenClaw"

$Action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -File `"$ScriptPath`" -BackupPath `"$BackupDir`""

$Trigger = New-ScheduledTaskTrigger -Daily -At "2:00 AM"

$Settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries

Register-ScheduledTask -TaskName $TaskName -Action $Action -Trigger $Trigger -Settings $Settings -Description "Daily OpenClaw backup"
```

**macOS/Linux (cron):**
```bash
# Add to cron (daily at 2 AM)
crontab -e

# Add this line:
0 2 * * * $HOME/.openclaw/scripts/backup.sh --backup-dir="$HOME/Backups/OpenClaw" >/dev/null 2>&1
```

### Cloud Backup Integration

**Sync to Google Drive (using rclone):**
```bash
# Install rclone and configure Google Drive
# Follow: https://rclone.org/drive/

# Modify backup script to upload after local backup
rclone copy "$BACKUP_DIR/$BACKUP_NAME.tar.gz" gdrive:OpenClaw/Backups/
```

**Sync to Dropbox:**
```bash
# Using official Dropbox CLI
dropbox_uploader upload "$BACKUP_DIR/$BACKUP_NAME.tar.gz" "/OpenClaw/Backups/"
```

### Restore Procedure

**From local backup:**
```bash
# Stop OpenClaw service first
# (use appropriate service stop command)

# Backup current state (in case restore fails)
mv ~/.openclaw ~/.openclaw-broken-$(date +%Y%m%d)

# Extract backup
# Windows:
Expand-Archive "C:\Backups\OpenClaw\openclaw-backup-20241216-140523.zip" -DestinationPath "C:\Users\$env:USERNAME\"

# macOS/Linux:
tar -xzf "$HOME/Backups/OpenClaw/openclaw-backup-20241216-140523.tar.gz" -C "$HOME/"

# Verify restore
ls ~/.openclaw/
openclaw --version

# Restart service
# (use appropriate service start command)

# Verify functionality
openclaw status
```

## Troubleshooting

### Problem: Service Won't Start

**Symptoms:**
- Service fails to start at boot
- Manual start attempts fail
- Error messages in logs about missing files or permissions

**Diagnosis:**
```bash
# Check service configuration
# Windows:
nssm status OpenClawGateway
Get-EventLog -LogName Application -Source "OpenClawGateway" -Newest 10

# macOS:
launchctl print gui/$(id -u)/com.openclaw.gateway
grep openclaw /var/log/system.log

# Linux:  
systemctl --user status openclaw-gateway
journalctl --user -u openclaw-gateway -n 20
```

**Common solutions:**

**Wrong file paths:**
```bash
# Verify OpenClaw installation path
which openclaw
ls -la $(which node)
ls -la $(npm root -g)/openclaw

# Update service configuration with correct paths
```

**Permission issues:**
```bash
# Fix file permissions
chmod +x ~/.openclaw/scripts/*
chown -R $(whoami) ~/.openclaw/

# Windows: Run as Administrator
# Linux: Check user service vs system service
```

**Missing dependencies:**
```bash
# Verify Node.js installation
node --version
npm --version

# Reinstall OpenClaw if needed
npm install -g openclaw
```

### Problem: Port Conflicts

**Symptoms:**
- "Port already in use" errors
- Service starts but web interface inaccessible
- Multiple instances running simultaneously

**Diagnosis:**
```bash
# Check what's using OpenClaw's port (default 3000)
# Windows:
netstat -an | findstr :3000

# macOS/Linux:
lsof -i :3000
netstat -tulpn | grep :3000
```

**Solutions:**
```bash
# Kill conflicting process
# Windows:
taskkill /F /PID <process_id>

# macOS/Linux:
kill -9 <process_id>

# Change OpenClaw port
echo "PORT=3001" >> ~/.openclaw/.env
# Then restart service

# Ensure only one instance
# Check for multiple service configurations
# Remove duplicate cron jobs or services
```

### Problem: Permission Errors

**Symptoms:**
- Cannot read/write files
- "Access denied" errors
- Service runs but cannot access workspace

**Diagnosis:**
```bash
# Check file ownership and permissions
ls -la ~/.openclaw/
ls -la ~/.openclaw/workspace/

# Check service user
# Windows:
whoami
# Linux:
systemctl --user show openclaw-gateway -p User
```

**Solutions:**
```bash
# Fix ownership
chown -R $(whoami):$(whoami) ~/.openclaw/

# Fix permissions
chmod 755 ~/.openclaw/
chmod 644 ~/.openclaw/*.json ~/.openclaw/.env
chmod -R 755 ~/.openclaw/workspace/

# Windows: Check User Account Control (UAC) settings
# Ensure service runs under correct user account
```

### Problem: Memory or CPU Issues

**Symptoms:**
- High CPU usage from openclaw processes
- System becomes slow or unresponsive
- Out of memory errors

**Diagnosis:**
```bash
# Monitor resource usage
# Windows:
Get-Process | Where-Object ProcessName -like "*node*" | Select-Object ProcessName,CPU,WorkingSet

# macOS/Linux:
top -p $(pgrep -f openclaw)
htop -p $(pgrep -f openclaw)
```

**Solutions:**
```bash
# Limit service resources (Linux systemd)
# Add to service file:
# MemoryMax=1G
# CPUQuota=50%

# Optimize OpenClaw configuration
echo "MAX_MEMORY=512" >> ~/.openclaw/.env
echo "WORKER_THREADS=2" >> ~/.openclaw/.env

# Review cron job frequency
openclaw cron list
# Reduce frequency of expensive jobs
```

## Pro Tips

### 1. Service Health Monitoring
Create a meta-service that monitors your OpenClaw service:

```bash
# Create health check script
cat > ~/.openclaw/scripts/health-check.sh << 'EOF'
#!/bin/bash

SERVICE_NAME="openclaw-gateway"
ALERT_EMAIL="your-email@example.com"

if ! systemctl --user is-active --quiet $SERVICE_NAME; then
    echo "⚠️ OpenClaw service is down! Attempting restart..."
    systemctl --user restart $SERVICE_NAME
    
    # Send alert (if mail configured)
    echo "OpenClaw service was down and has been restarted at $(date)" | \
        mail -s "OpenClaw Service Alert" $ALERT_EMAIL
fi
EOF

# Schedule health check every 5 minutes
crontab -e
# Add: */5 * * * * ~/.openclaw/scripts/health-check.sh
```

### 2. Remote Management Setup
Access your OpenClaw instance from anywhere:

```bash
# Enable SSH tunnel for remote access
ssh -L 3000:localhost:3000 user@your-home-server

# Or configure reverse proxy (nginx example)
server {
    listen 80;
    server_name openclaw.yourdomain.com;
    
    location / {
        proxy_pass http://localhost:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

### 3. Multi-Environment Setup
Run different OpenClaw instances for different purposes:

```bash
# Development instance (port 3001)
echo "PORT=3001" > ~/.openclaw-dev/.env
echo "NODE_ENV=development" >> ~/.openclaw-dev/.env

# Production instance (port 3000)  
echo "PORT=3000" > ~/.openclaw/.env
echo "NODE_ENV=production" >> ~/.openclaw/.env

# Create separate services for each
# Modify service configurations to use different directories
```

### 4. Automated Updates
Set up automatic updates with safety checks:

```bash
# Create update script with rollback capability
cat > ~/.openclaw/scripts/auto-update.sh << 'EOF'
#!/bin/bash

BACKUP_DIR="$HOME/Backups/OpenClaw"
CURRENT_VERSION=$(openclaw --version)

echo "Starting auto-update from version: $CURRENT_VERSION"

# Create backup
~/.openclaw/scripts/backup.sh --backup-dir="$BACKUP_DIR"

# Stop service
systemctl --user stop openclaw-gateway

# Update
npm update -g openclaw

# Test new version
if openclaw gateway start --test; then
    echo "✅ Update successful"
    systemctl --user start openclaw-gateway
else
    echo "❌ Update failed, rolling back"
    # Restore from backup
    # (implement rollback logic here)
fi
EOF

# Schedule monthly updates
crontab -e  
# Add: 0 3 1 * * ~/.openclaw/scripts/auto-update.sh
```

With proper deployment and persistence, your OpenClaw AI agent becomes a true 24/7 system that survives reboots, crashes, and updates. The initial setup takes effort, but the result is an autonomous system that works even when you don't.

Next, we'll cover the complete reference guide with every command, configuration option, and troubleshooting resource you'll need.