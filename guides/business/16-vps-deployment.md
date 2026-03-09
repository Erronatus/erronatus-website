# Chapter 16: VPS Deployment & 24/7 Operations
## Build Bulletproof Infrastructure That Scales

*Running AI automation locally is fine for testing. Running a business requires infrastructure that never sleeps, never fails, and scales with your growth. This chapter transforms you from someone who "plays with AI" to someone who runs production systems that handle millions in revenue. We're building enterprise-grade infrastructure using VPS deployment, monitoring, security hardening, and automated backup systems.*

### Why This Matters

Local development is a toy. Production infrastructure is a business weapon.

When you deploy to a VPS properly:
- **24/7 Availability**: Your automations run even when your laptop is closed
- **Scalability**: Handle 1000x more requests than your local machine
- **Reliability**: Professional uptime with monitoring and automatic restarts
- **Security**: Hardened systems that resist attacks and breaches
- **Compliance**: Infrastructure that meets business requirements

The businesses making serious money online run on serious infrastructure. This chapter shows you how to build yours.

## VPS Provider Comparison

### DigitalOcean
**Pros:**
- Excellent documentation and tutorials
- Simple pricing ($4/month basic droplet)
- Great API for automation
- Reliable network and uptime
- Strong community support

**Cons:**
- More expensive than some competitors
- Limited free tier
- Fewer global regions than AWS/GCP

**Best for:** Startups and small businesses who value simplicity

### Hetzner
**Pros:**
- Exceptional price/performance ratio
- Dedicated servers at VPS prices
- European data centers with GDPR compliance
- Generous bandwidth allowances
- Solid hardware specifications

**Cons:**
- Primarily Europe-focused
- Less extensive API ecosystem
- Smaller community than major providers

**Best for:** Cost-conscious businesses with European customers

### Vultr
**Pros:**
- Wide range of server sizes
- Global presence (25+ locations)
- NVMe SSD storage standard
- Competitive pricing
- Good performance benchmarks

**Cons:**
- Mixed customer support reviews
- Less extensive documentation
- Occasional billing issues reported

**Best for:** Performance-focused applications needing global reach

### Linode (Akamai)
**Pros:**
- Long-established with proven reliability
- Excellent customer support
- Transparent pricing structure
- Strong developer tools and API
- Good balance of features and simplicity

**Cons:**
- Slightly higher pricing than budget providers
- Interface less modern than competitors
- Fewer managed services than major clouds

**Best for:** Businesses needing reliable hosting with great support

### Recommendation: DigitalOcean

For this guide, we'll use DigitalOcean because:
1. Best documentation for beginners
2. Reliable infrastructure
3. Excellent automation API
4. Strong community and tutorials
5. Transparent pricing

## Complete VPS Setup from Scratch

### Step 1: Provision Your Server

```bash
#!/bin/bash
# ~/.openclaw/workspace/scripts/provision-digitalocean.sh

# Install DigitalOcean CLI (doctl)
curl -sL https://github.com/digitalocean/doctl/releases/download/v1.94.0/doctl-1.94.0-linux-amd64.tar.gz | tar -xzv
sudo mv doctl /usr/local/bin

# Authenticate with DigitalOcean
# Get your API token from: https://cloud.digitalocean.com/account/api/tokens
echo "Enter your DigitalOcean API token:"
read -s DO_TOKEN
doctl auth init --access-token $DO_TOKEN

# Create SSH key pair if it doesn't exist
if [ ! -f ~/.ssh/id_rsa ]; then
    ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N ""
fi

# Upload SSH key to DigitalOcean
SSH_KEY_ID=$(doctl compute ssh-key create "openclaw-$(date +%Y%m%d)" --public-key-file ~/.ssh/id_rsa.pub --format ID --no-header)
echo "SSH Key ID: $SSH_KEY_ID"

# Create droplet
DROPLET_NAME="openclaw-production"
REGION="nyc3" # New York datacenter
SIZE="s-2vcpu-2gb" # 2 CPU, 2GB RAM - good starting point
IMAGE="ubuntu-22-04-x64"

echo "Creating droplet: $DROPLET_NAME"
DROPLET_ID=$(doctl compute droplet create $DROPLET_NAME \
    --region $REGION \
    --size $SIZE \
    --image $IMAGE \
    --ssh-keys $SSH_KEY_ID \
    --enable-monitoring \
    --enable-backups \
    --format ID \
    --no-header \
    --wait)

echo "Droplet created with ID: $DROPLET_ID"

# Get droplet IP address
DROPLET_IP=$(doctl compute droplet get $DROPLET_ID --format PublicIPv4 --no-header)
echo "Droplet IP: $DROPLET_IP"

# Save connection details
cat > ~/.openclaw/server-details.txt << EOF
Server: $DROPLET_NAME
ID: $DROPLET_ID
IP: $DROPLET_IP
SSH Key ID: $SSH_KEY_ID
Region: $REGION
Size: $SIZE
Created: $(date)
SSH Command: ssh root@$DROPLET_IP
EOF

echo "Server details saved to ~/.openclaw/server-details.txt"
echo "Wait 2-3 minutes for the server to fully initialize, then connect with:"
echo "ssh root@$DROPLET_IP"
```

### Step 2: Initial Server Configuration

```bash
#!/bin/bash
# ~/.openclaw/workspace/scripts/server-setup.sh
# Run this script ON the VPS after initial connection

set -e  # Exit on any error

echo "🚀 Starting OpenClaw server setup..."

# Update system packages
echo "📦 Updating system packages..."
apt update && apt upgrade -y

# Install essential packages
echo "🛠️ Installing essential packages..."
apt install -y \
    curl \
    wget \
    unzip \
    git \
    htop \
    nginx \
    ufw \
    fail2ban \
    certbot \
    python3-certbot-nginx \
    build-essential \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release

# Install Node.js 20.x LTS
echo "📦 Installing Node.js..."
curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
apt install -y nodejs

# Verify installations
echo "✅ Verifying installations..."
node_version=$(node --version)
npm_version=$(npm --version)
echo "Node.js: $node_version"
echo "npm: $npm_version"

# Create application user (don't run as root)
echo "👤 Creating application user..."
useradd -m -s /bin/bash openclaw
usermod -aG sudo openclaw

# Set up directory structure
echo "📁 Setting up directory structure..."
mkdir -p /opt/openclaw/{app,logs,backups,config}
chown -R openclaw:openclaw /opt/openclaw

# Install PM2 for process management
echo "🔄 Installing PM2..."
npm install -g pm2

# Configure log rotation
echo "📝 Setting up log rotation..."
cat > /etc/logrotate.d/openclaw << 'EOF'
/opt/openclaw/logs/*.log {
    daily
    missingok
    rotate 14
    compress
    notifempty
    create 644 openclaw openclaw
    postrotate
        pm2 reloadLogs
    endscript
}
EOF

echo "✅ Basic server setup completed!"
echo "Next steps:"
echo "1. Configure SSH key authentication"
echo "2. Set up firewall"
echo "3. Install and configure OpenClaw"
```

### Step 3: Security Hardening

```bash
#!/bin/bash
# ~/.openclaw/workspace/scripts/security-hardening.sh
# Run as root on the VPS

echo "🔒 Starting security hardening..."

# Configure SSH security
echo "🔐 Configuring SSH security..."
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup

cat > /etc/ssh/sshd_config << 'EOF'
# OpenClaw SSH Configuration - Hardened

# Basic Configuration
Port 22
Protocol 2
HostKey /etc/ssh/ssh_host_rsa_key
HostKey /etc/ssh/ssh_host_ecdsa_key
HostKey /etc/ssh/ssh_host_ed25519_key

# Authentication
PermitRootLogin no
PubkeyAuthentication yes
PasswordAuthentication no
PermitEmptyPasswords no
ChallengeResponseAuthentication no
UsePAM yes

# Security Settings
X11Forwarding no
PrintMotd no
AcceptEnv LANG LC_*
Subsystem sftp /usr/lib/openssh/sftp-server

# Connection Settings
ClientAliveInterval 300
ClientAliveCountMax 2
MaxAuthTries 3
MaxSessions 10
LoginGraceTime 60

# Restrict users
AllowUsers openclaw
DenyUsers root

# Banner
Banner /etc/ssh/banner
EOF

# Create SSH banner
cat > /etc/ssh/banner << 'EOF'
***************************************************************************
                    AUTHORIZED ACCESS ONLY
                    
This system is for authorized users only. All activities may be monitored
and recorded. Unauthorized access is prohibited and may result in criminal
and/or civil penalties.
***************************************************************************
EOF

# Set up SSH keys for openclaw user
echo "🔑 Setting up SSH keys for openclaw user..."
sudo -u openclaw mkdir -p /home/openclaw/.ssh
sudo -u openclaw chmod 700 /home/openclaw/.ssh

# Copy root's authorized_keys to openclaw user
cp /root/.ssh/authorized_keys /home/openclaw/.ssh/authorized_keys
chown openclaw:openclaw /home/openclaw/.ssh/authorized_keys
chmod 600 /home/openclaw/.ssh/authorized_keys

# Restart SSH service
systemctl restart sshd

# Configure UFW firewall
echo "🛡️ Configuring firewall..."
ufw --force reset
ufw default deny incoming
ufw default allow outgoing

# Allow essential services
ufw allow ssh
ufw allow 80/tcp   # HTTP
ufw allow 443/tcp  # HTTPS

# Enable firewall
ufw --force enable

# Configure fail2ban
echo "🚫 Configuring fail2ban..."
cat > /etc/fail2ban/jail.local << 'EOF'
[DEFAULT]
# Ban IPs for 10 minutes after 5 failed attempts within 10 minutes
bantime = 600
findtime = 600
maxretry = 5
backend = systemd

[sshd]
enabled = true
port = ssh
filter = sshd
logpath = /var/log/auth.log
maxretry = 3
bantime = 3600

[nginx-http-auth]
enabled = true
port = http,https
filter = nginx-http-auth
logpath = /var/log/nginx/error.log
maxretry = 3

[nginx-noscript]
enabled = true
port = http,https
filter = nginx-noscript
logpath = /var/log/nginx/access.log
maxretry = 6

[nginx-badbots]
enabled = true
port = http,https
filter = nginx-badbots
logpath = /var/log/nginx/access.log
maxretry = 2
EOF

systemctl enable fail2ban
systemctl restart fail2ban

# Configure automatic security updates
echo "🔄 Configuring automatic security updates..."
apt install -y unattended-upgrades apt-listchanges
dpkg-reconfigure -plow unattended-upgrades

cat > /etc/apt/apt.conf.d/20auto-upgrades << 'EOF'
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Download-Upgradeable-Packages "1";
APT::Periodic::AutocleanInterval "7";
APT::Periodic::Unattended-Upgrade "1";
EOF

cat > /etc/apt/apt.conf.d/50unattended-upgrades << 'EOF'
Unattended-Upgrade::Allowed-Origins {
    "${distro_id}:${distro_codename}";
    "${distro_id}:${distro_codename}-security";
    "${distro_id}:${distro_codename}-updates";
};

Unattended-Upgrade::Package-Blacklist {
};

Unattended-Upgrade::DevRelease "false";
Unattended-Upgrade::Remove-Unused-Dependencies "true";
Unattended-Upgrade::Automatic-Reboot "false";
Unattended-Upgrade::Mail "root";
EOF

# Set up system monitoring user
echo "📊 Setting up system monitoring..."
useradd -r -s /bin/false monitor

# Configure sysctl for better security
cat > /etc/sysctl.d/99-security.conf << 'EOF'
# IP Spoofing protection
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1

# Ignore ICMP redirects
net.ipv4.conf.all.accept_redirects = 0
net.ipv6.conf.all.accept_redirects = 0
net.ipv4.conf.all.send_redirects = 0

# Ignore ping requests
net.ipv4.icmp_echo_ignore_all = 0

# Disable source packet routing
net.ipv4.conf.all.accept_source_route = 0
net.ipv6.conf.all.accept_source_route = 0

# Log Martians
net.ipv4.conf.all.log_martians = 1

# Disable IPv6 if not needed
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
EOF

sysctl -p /etc/sysctl.d/99-security.conf

echo "✅ Security hardening completed!"
echo "⚠️  IMPORTANT: Test SSH connection with openclaw user before closing this session!"
echo "   ssh openclaw@$(curl -s ifconfig.me)"
```

### Step 4: OpenClaw Installation

```bash
#!/bin/bash
# ~/.openclaw/workspace/scripts/install-openclaw.sh
# Run as openclaw user on the VPS

set -e

echo "🦅 Installing OpenClaw on VPS..."

cd /opt/openclaw/app

# Install OpenClaw
npm install -g @openclaw/cli

# Create OpenClaw configuration directory
mkdir -p ~/.openclaw/workspace

# Initialize OpenClaw
openclaw init --production

# Create systemd service configuration
echo "🔧 Creating systemd service..."

# Create environment file
sudo tee /opt/openclaw/config/environment << 'EOF'
# OpenClaw Environment Configuration
NODE_ENV=production
OPENCLAW_LOG_LEVEL=info
OPENCLAW_LOG_FILE=/opt/openclaw/logs/openclaw.log
OPENCLAW_WORKSPACE=/opt/openclaw/app/workspace
OPENCLAW_CONFIG_DIR=/opt/openclaw/config

# API Keys (set these values)
OPENAI_API_KEY=
ANTHROPIC_API_KEY=
STRIPE_SECRET_KEY=
STRIPE_WEBHOOK_SECRET=
RESEND_API_KEY=
SUPABASE_URL=
SUPABASE_ANON_KEY=
TELEGRAM_BOT_TOKEN=
TELEGRAM_CHAT_ID=

# Server Configuration
PORT=3000
HOST=0.0.0.0
EOF

# Set secure permissions on environment file
sudo chmod 600 /opt/openclaw/config/environment
sudo chown openclaw:openclaw /opt/openclaw/config/environment

# Create systemd service file
sudo tee /etc/systemd/system/openclaw.service << 'EOF'
[Unit]
Description=OpenClaw AI Automation Service
Documentation=https://openclaw.com/docs
After=network.target
Wants=network.target

[Service]
Type=simple
User=openclaw
Group=openclaw
WorkingDirectory=/opt/openclaw/app
EnvironmentFile=/opt/openclaw/config/environment
ExecStart=/usr/bin/node /usr/local/bin/openclaw daemon
ExecReload=/bin/kill -HUP $MAINPID
Restart=always
RestartSec=10
StandardOutput=append:/opt/openclaw/logs/openclaw.log
StandardError=append:/opt/openclaw/logs/openclaw-error.log

# Security settings
NoNewPrivileges=yes
PrivateTmp=yes
ProtectHome=yes
ProtectSystem=strict
ReadWritePaths=/opt/openclaw
ProtectKernelTunables=yes
ProtectKernelModules=yes
ProtectControlGroups=yes

# Resource limits
LimitNOFILE=65536
LimitNPROC=4096

[Install]
WantedBy=multi-user.target
EOF

# Enable and start the service
sudo systemctl daemon-reload
sudo systemctl enable openclaw
echo "✅ OpenClaw service configured"

# Create log directory and files
mkdir -p /opt/openclaw/logs
touch /opt/openclaw/logs/openclaw.log
touch /opt/openclaw/logs/openclaw-error.log

echo "📝 Creating management scripts..."

# Create service management script
tee /opt/openclaw/manage.sh << 'EOF'
#!/bin/bash
# OpenClaw Service Management Script

case "$1" in
    start)
        echo "Starting OpenClaw..."
        sudo systemctl start openclaw
        ;;
    stop)
        echo "Stopping OpenClaw..."
        sudo systemctl stop openclaw
        ;;
    restart)
        echo "Restarting OpenClaw..."
        sudo systemctl restart openclaw
        ;;
    status)
        sudo systemctl status openclaw --no-pager
        ;;
    logs)
        if [ "$2" = "error" ]; then
            tail -f /opt/openclaw/logs/openclaw-error.log
        else
            tail -f /opt/openclaw/logs/openclaw.log
        fi
        ;;
    health)
        echo "=== OpenClaw Health Check ==="
        echo "Service Status:"
        sudo systemctl is-active openclaw
        echo "Memory Usage:"
        ps aux | grep openclaw | grep -v grep | awk '{print $4"% Memory, "$3"% CPU"}'
        echo "Log Errors (last 10):"
        tail -n 10 /opt/openclaw/logs/openclaw-error.log | grep -i error || echo "No recent errors"
        echo "Disk Usage:"
        df -h /opt/openclaw
        ;;
    update)
        echo "Updating OpenClaw..."
        sudo systemctl stop openclaw
        npm install -g @openclaw/cli@latest
        sudo systemctl start openclaw
        echo "Update completed"
        ;;
    *)
        echo "Usage: $0 {start|stop|restart|status|logs|health|update}"
        echo "  logs [error]  - Show logs (add 'error' for error logs)"
        exit 1
        ;;
esac
EOF

chmod +x /opt/openclaw/manage.sh

echo "✅ OpenClaw installation completed!"
echo ""
echo "Next steps:"
echo "1. Edit environment variables: sudo nano /opt/openclaw/config/environment"
echo "2. Start the service: /opt/openclaw/manage.sh start"
echo "3. Check status: /opt/openclaw/manage.sh status"
echo "4. View logs: /opt/openclaw/manage.sh logs"
```

### Step 5: Nginx Reverse Proxy Setup

```bash
#!/bin/bash
# ~/.openclaw/workspace/scripts/setup-nginx.sh
# Run as openclaw user, will use sudo when needed

echo "🌐 Setting up Nginx reverse proxy..."

# Create Nginx configuration
sudo tee /etc/nginx/sites-available/openclaw << 'EOF'
# OpenClaw Nginx Configuration

# Rate limiting
limit_req_zone $binary_remote_addr zone=openclaw:10m rate=10r/m;
limit_req_zone $binary_remote_addr zone=api:10m rate=60r/m;

# Upstream configuration
upstream openclaw_backend {
    server 127.0.0.1:3000 max_fails=3 fail_timeout=30s;
    keepalive 32;
}

# HTTP server (redirects to HTTPS)
server {
    listen 80;
    server_name yourdomain.com www.yourdomain.com;
    
    # Security headers
    add_header X-Frame-Options DENY always;
    add_header X-Content-Type-Options nosniff always;
    add_header X-XSS-Protection "1; mode=block" always;
    
    # Redirect to HTTPS
    return 301 https://$server_name$request_uri;
}

# HTTPS server
server {
    listen 443 ssl http2;
    server_name yourdomain.com www.yourdomain.com;
    
    # SSL Configuration (Let's Encrypt)
    ssl_certificate /etc/letsencrypt/live/yourdomain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/yourdomain.com/privkey.pem;
    ssl_trusted_certificate /etc/letsencrypt/live/yourdomain.com/chain.pem;
    
    # SSL Security
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES128-SHA256:ECDHE-RSA-AES256-SHA384;
    ssl_prefer_server_ciphers on;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;
    ssl_stapling on;
    ssl_stapling_verify on;
    
    # Security Headers
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    add_header X-Frame-Options DENY always;
    add_header X-Content-Type-Options nosniff always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;
    add_header Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline';" always;
    
    # Logging
    access_log /opt/openclaw/logs/nginx-access.log;
    error_log /opt/openclaw/logs/nginx-error.log;
    
    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1000;
    gzip_types text/plain application/json application/javascript text/css text/xml application/xml;
    
    # Main application
    location / {
        limit_req zone=openclaw burst=20 nodelay;
        
        proxy_pass http://openclaw_backend;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
        
        # Timeouts
        proxy_connect_timeout 5s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }
    
    # API endpoints with different rate limiting
    location /api/ {
        limit_req zone=api burst=100 nodelay;
        
        proxy_pass http://openclaw_backend;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # Longer timeouts for API calls
        proxy_connect_timeout 10s;
        proxy_send_timeout 300s;
        proxy_read_timeout 300s;
    }
    
    # Webhook endpoints (no rate limiting)
    location /webhooks/ {
        proxy_pass http://openclaw_backend;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # Quick timeouts for webhooks
        proxy_connect_timeout 5s;
        proxy_send_timeout 30s;
        proxy_read_timeout 30s;
    }
    
    # Health check endpoint
    location /health {
        proxy_pass http://openclaw_backend;
        access_log off;
    }
    
    # Static files (if any)
    location /static/ {
        alias /opt/openclaw/app/public/;
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
    
    # Block common attacks
    location ~ /\.ht {
        deny all;
    }
    
    location ~ /\. {
        deny all;
    }
    
    # Block access to sensitive files
    location ~* \.(env|log|bak)$ {
        deny all;
    }
}
EOF

# Enable the site
sudo ln -sf /etc/nginx/sites-available/openclaw /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default

# Test Nginx configuration
echo "🧪 Testing Nginx configuration..."
sudo nginx -t

if [ $? -eq 0 ]; then
    echo "✅ Nginx configuration is valid"
    sudo systemctl restart nginx
    sudo systemctl enable nginx
else
    echo "❌ Nginx configuration has errors"
    exit 1
fi

echo "📝 Setting up SSL certificate..."
echo "Run this command to get SSL certificate (replace yourdomain.com):"
echo "sudo certbot --nginx -d yourdomain.com -d www.yourdomain.com"
```

## Monitoring and Health Checks

### System Health Monitor

```bash
#!/bin/bash
# ~/.openclaw/workspace/scripts/health-monitor.sh
# Comprehensive system health monitoring

# Configuration
ALERT_EMAIL="admin@yourdomain.com"
LOG_FILE="/opt/openclaw/logs/health-monitor.log"
ALERT_THRESHOLD_CPU=80
ALERT_THRESHOLD_MEM=85
ALERT_THRESHOLD_DISK=90

# Functions
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

send_alert() {
    local subject="$1"
    local message="$2"
    
    # Send email alert (requires mailutils)
    if command -v mail >/dev/null 2>&1; then
        echo "$message" | mail -s "$subject" "$ALERT_EMAIL"
    fi
    
    # Log the alert
    log_message "ALERT: $subject - $message"
}

check_service() {
    local service_name="$1"
    
    if systemctl is-active --quiet "$service_name"; then
        return 0
    else
        return 1
    fi
}

check_disk_usage() {
    local partition="$1"
    local usage=$(df "$partition" | awk 'NR==2 {gsub(/%/, "", $5); print $5}')
    
    if [ "$usage" -gt "$ALERT_THRESHOLD_DISK" ]; then
        send_alert "Disk Usage Alert" "Disk usage on $partition is ${usage}% (threshold: ${ALERT_THRESHOLD_DISK}%)"
        return 1
    fi
    
    return 0
}

check_memory_usage() {
    local mem_usage=$(free | awk 'NR==2{printf "%.0f", $3*100/$2}')
    
    if [ "$mem_usage" -gt "$ALERT_THRESHOLD_MEM" ]; then
        send_alert "Memory Usage Alert" "Memory usage is ${mem_usage}% (threshold: ${ALERT_THRESHOLD_MEM}%)"
        return 1
    fi
    
    return 0
}

check_cpu_usage() {
    local cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | awk -F'%' '{print $1}')
    
    if (( $(echo "$cpu_usage > $ALERT_THRESHOLD_CPU" | bc -l) )); then
        send_alert "CPU Usage Alert" "CPU usage is ${cpu_usage}% (threshold: ${ALERT_THRESHOLD_CPU}%)"
        return 1
    fi
    
    return 0
}

check_load_average() {
    local load_1min=$(uptime | awk -F'load average:' '{print $2}' | awk '{print $1}' | tr -d ',')
    local cpu_cores=$(nproc)
    local load_threshold=$(echo "$cpu_cores * 2" | bc)
    
    if (( $(echo "$load_1min > $load_threshold" | bc -l) )); then
        send_alert "Load Average Alert" "Load average (${load_1min}) exceeds threshold (${load_threshold})"
        return 1
    fi
    
    return 0
}

check_network_connectivity() {
    if ! ping -c 1 8.8.8.8 >/dev/null 2>&1; then
        send_alert "Network Connectivity Alert" "Unable to reach external network (ping to 8.8.8.8 failed)"
        return 1
    fi
    
    return 0
}

check_ssl_certificate() {
    local domain="$1"
    
    if [ -z "$domain" ]; then
        return 0
    fi
    
    local expiry_date=$(echo | openssl s_client -servername "$domain" -connect "$domain:443" 2>/dev/null | openssl x509 -noout -dates | grep notAfter | cut -d= -f2)
    local expiry_timestamp=$(date -d "$expiry_date" +%s)
    local current_timestamp=$(date +%s)
    local days_until_expiry=$(( (expiry_timestamp - current_timestamp) / 86400 ))
    
    if [ "$days_until_expiry" -lt 30 ]; then
        send_alert "SSL Certificate Alert" "SSL certificate for $domain expires in $days_until_expiry days"
        return 1
    fi
    
    return 0
}

# Main health check
run_health_check() {
    log_message "Starting health check..."
    
    local issues=0
    
    # Check critical services
    services=("openclaw" "nginx" "fail2ban")
    for service in "${services[@]}"; do
        if ! check_service "$service"; then
            send_alert "Service Down Alert" "$service is not running"
            ((issues++))
        fi
    done
    
    # Check system resources
    check_disk_usage "/" || ((issues++))
    check_memory_usage || ((issues++))
    check_cpu_usage || ((issues++))
    check_load_average || ((issues++))
    
    # Check network connectivity
    check_network_connectivity || ((issues++))
    
    # Check SSL certificate (uncomment and set your domain)
    # check_ssl_certificate "yourdomain.com" || ((issues++))
    
    if [ "$issues" -eq 0 ]; then
        log_message "Health check completed - All systems operational"
    else
        log_message "Health check completed - $issues issues detected"
    fi
    
    return $issues
}

# Generate system report
generate_system_report() {
    local report_file="/opt/openclaw/logs/system-report-$(date +%Y%m%d-%H%M%S).log"
    
    {
        echo "=== OpenClaw System Report ==="
        echo "Generated: $(date)"
        echo ""
        
        echo "=== System Information ==="
        uname -a
        uptime
        echo ""
        
        echo "=== Resource Usage ==="
        echo "CPU Usage:"
        top -bn1 | grep "Cpu(s)"
        echo ""
        echo "Memory Usage:"
        free -h
        echo ""
        echo "Disk Usage:"
        df -h
        echo ""
        echo "Load Average:"
        uptime | awk -F'load average:' '{print "Load Average:" $2}'
        echo ""
        
        echo "=== Service Status ==="
        for service in openclaw nginx fail2ban ufw; do
            status=$(systemctl is-active $service 2>/dev/null || echo "not-found")
            echo "$service: $status"
        done
        echo ""
        
        echo "=== Network Information ==="
        echo "Active connections:"
        ss -tuln | head -10
        echo ""
        echo "Firewall status:"
        ufw status
        echo ""
        
        echo "=== Recent Log Entries ==="
        echo "OpenClaw errors (last 5):"
        tail -5 /opt/openclaw/logs/openclaw-error.log 2>/dev/null || echo "No error log found"
        echo ""
        echo "System authentication failures (last 5):"
        tail -5 /var/log/auth.log | grep "Failed\|failure" | tail -5
        echo ""
        
        echo "=== Process Information ==="
        echo "OpenClaw processes:"
        ps aux | grep openclaw | grep -v grep
        echo ""
        echo "Top processes by CPU:"
        ps aux --sort=-%cpu | head -6
        echo ""
        echo "Top processes by memory:"
        ps aux --sort=-%mem | head -6
        
    } > "$report_file"
    
    log_message "System report generated: $report_file"
    echo "$report_file"
}

# CLI interface
case "${1:-health}" in
    health)
        run_health_check
        ;;
    report)
        generate_system_report
        ;;
    services)
        echo "Service Status Check:"
        for service in openclaw nginx fail2ban ufw; do
            status=$(systemctl is-active $service 2>/dev/null || echo "not-found")
            printf "%-12s %s\n" "$service:" "$status"
        done
        ;;
    resources)
        echo "Resource Usage:"
        echo "CPU: $(top -bn1 | grep "Cpu(s)" | awk '{print $2}')"
        echo "Memory: $(free | awk 'NR==2{printf "%.0f%%", $3*100/$2}')"
        echo "Disk (/): $(df / | awk 'NR==2 {print $5}')"
        echo "Load: $(uptime | awk -F'load average:' '{print $2}')"
        ;;
    *)
        echo "Usage: $0 [health|report|services|resources]"
        echo "  health     - Run complete health check (default)"
        echo "  report     - Generate detailed system report"
        echo "  services   - Check service status"
        echo "  resources  - Show resource usage"
        exit 1
        ;;
esac
```

### Automated Health Check Cron

```bash
#!/bin/bash
# ~/.openclaw/workspace/scripts/setup-monitoring.sh

echo "📊 Setting up automated monitoring..."

# Make health monitor executable
chmod +x /opt/openclaw/scripts/health-monitor.sh

# Create monitoring cron jobs
crontab_content="# OpenClaw Monitoring Cron Jobs

# Health check every 5 minutes
*/5 * * * * /opt/openclaw/scripts/health-monitor.sh health >/dev/null 2>&1

# Generate daily system report at 6 AM
0 6 * * * /opt/openclaw/scripts/health-monitor.sh report >/dev/null 2>&1

# Cleanup old logs weekly (Sunday at 3 AM)
0 3 * * 0 find /opt/openclaw/logs -name '*.log' -type f -mtime +30 -delete

# Restart OpenClaw service daily at 4 AM (optional)
# 0 4 * * * /opt/openclaw/manage.sh restart >/dev/null 2>&1
"

# Install cron jobs
echo "$crontab_content" | crontab -

echo "✅ Monitoring cron jobs installed"
crontab -l
```

## Backup Strategy

### Comprehensive Backup System

```bash
#!/bin/bash
# ~/.openclaw/workspace/scripts/backup-system.sh
# Automated backup system for OpenClaw VPS

# Configuration
BACKUP_DIR="/opt/openclaw/backups"
REMOTE_BACKUP_HOST="backup.yourdomain.com"
REMOTE_BACKUP_USER="backup"
REMOTE_BACKUP_PATH="/backups/openclaw"
RETENTION_DAYS=30
LOG_FILE="/opt/openclaw/logs/backup.log"

# Create backup directory
mkdir -p "$BACKUP_DIR"

log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

create_backup() {
    local backup_type="$1"
    local timestamp=$(date +%Y%m%d-%H%M%S)
    local backup_name="openclaw-${backup_type}-${timestamp}"
    local backup_path="$BACKUP_DIR/$backup_name"
    
    log_message "Starting $backup_type backup: $backup_name"
    
    case "$backup_type" in
        "full")
            create_full_backup "$backup_path"
            ;;
        "config")
            create_config_backup "$backup_path"
            ;;
        "database")
            create_database_backup "$backup_path"
            ;;
        *)
            log_message "Error: Unknown backup type: $backup_type"
            return 1
            ;;
    esac
    
    if [ $? -eq 0 ]; then
        log_message "Backup completed successfully: $backup_path"
        
        # Compress the backup
        tar -czf "${backup_path}.tar.gz" -C "$BACKUP_DIR" "$backup_name"
        rm -rf "$backup_path"
        
        # Upload to remote storage (if configured)
        upload_to_remote "${backup_path}.tar.gz"
        
        # Cleanup old backups
        cleanup_old_backups "$backup_type"
        
        return 0
    else
        log_message "Backup failed: $backup_name"
        return 1
    fi
}

create_full_backup() {
    local backup_path="$1"
    mkdir -p "$backup_path"
    
    # Stop OpenClaw service for consistent backup
    log_message "Stopping OpenClaw service for backup..."
    sudo systemctl stop openclaw
    
    # Backup application files
    log_message "Backing up application files..."
    cp -r /opt/openclaw/app "$backup_path/"
    cp -r /opt/openclaw/config "$backup_path/"
    
    # Backup logs (last 7 days only)
    log_message "Backing up recent logs..."
    mkdir -p "$backup_path/logs"
    find /opt/openclaw/logs -name "*.log" -mtime -7 -exec cp {} "$backup_path/logs/" \;
    
    # Backup system configuration
    log_message "Backing up system configuration..."
    mkdir -p "$backup_path/system"
    sudo cp /etc/systemd/system/openclaw.service "$backup_path/system/"
    sudo cp /etc/nginx/sites-available/openclaw "$backup_path/system/"
    sudo cp /etc/fail2ban/jail.local "$backup_path/system/" 2>/dev/null || true
    
    # Backup SSL certificates
    if [ -d /etc/letsencrypt ]; then
        log_message "Backing up SSL certificates..."
        sudo cp -r /etc/letsencrypt "$backup_path/system/"
    fi
    
    # Create backup manifest
    cat > "$backup_path/MANIFEST.txt" << EOF
OpenClaw Full Backup
Created: $(date)
Hostname: $(hostname)
OpenClaw Version: $(openclaw --version 2>/dev/null || echo "Unknown")
Node Version: $(node --version)
System: $(uname -a)

Contents:
- Application files (/opt/openclaw/app)
- Configuration files (/opt/openclaw/config)
- Recent logs (last 7 days)
- System service files
- SSL certificates
- Database exports

Restore Instructions:
1. Stop OpenClaw: sudo systemctl stop openclaw
2. Restore files to appropriate locations
3. Update file permissions: sudo chown -R openclaw:openclaw /opt/openclaw
4. Start OpenClaw: sudo systemctl start openclaw
EOF
    
    # Restart OpenClaw service
    log_message "Restarting OpenClaw service..."
    sudo systemctl start openclaw
    
    return 0
}

create_config_backup() {
    local backup_path="$1"
    mkdir -p "$backup_path"
    
    log_message "Backing up configuration files..."
    
    # Application configuration
    cp -r /opt/openclaw/config "$backup_path/"
    
    # System configuration
    mkdir -p "$backup_path/system"
    sudo cp /etc/systemd/system/openclaw.service "$backup_path/system/"
    sudo cp /etc/nginx/sites-available/openclaw "$backup_path/system/"
    sudo cp /etc/fail2ban/jail.local "$backup_path/system/" 2>/dev/null || true
    
    # SSH configuration
    sudo cp /etc/ssh/sshd_config "$backup_path/system/"
    
    # Create manifest
    cat > "$backup_path/MANIFEST.txt" << EOF
OpenClaw Configuration Backup
Created: $(date)
Hostname: $(hostname)

Contents:
- OpenClaw configuration files
- Systemd service configuration
- Nginx configuration
- SSH configuration
- Security configurations
EOF
    
    return 0
}

create_database_backup() {
    local backup_path="$1"
    mkdir -p "$backup_path"
    
    log_message "Backing up databases..."
    
    # If using local SQLite databases
    if [ -d /opt/openclaw/app/database ]; then
        cp -r /opt/openclaw/app/database "$backup_path/"
    fi
    
    # If using PostgreSQL
    if command -v pg_dump >/dev/null 2>&1; then
        log_message "Creating PostgreSQL dump..."
        pg_dump openclaw > "$backup_path/postgresql_dump.sql" 2>/dev/null || true
    fi
    
    # Export application data
    log_message "Exporting application data..."
    # Add your database export commands here
    
    return 0
}

upload_to_remote() {
    local backup_file="$1"
    
    if [ -z "$REMOTE_BACKUP_HOST" ]; then
        log_message "No remote backup host configured, skipping upload"
        return 0
    fi
    
    log_message "Uploading backup to remote storage..."
    
    # Upload via SCP
    if scp "$backup_file" "$REMOTE_BACKUP_USER@$REMOTE_BACKUP_HOST:$REMOTE_BACKUP_PATH/" >/dev/null 2>&1; then
        log_message "Remote upload successful"
        return 0
    else
        log_message "Remote upload failed"
        return 1
    fi
}

cleanup_old_backups() {
    local backup_type="$1"
    
    log_message "Cleaning up old backups (keeping last $RETENTION_DAYS days)..."
    
    # Remove local backups older than retention period
    find "$BACKUP_DIR" -name "openclaw-${backup_type}-*.tar.gz" -mtime +$RETENTION_DAYS -delete
    
    # Remove old backups from remote storage (if configured)
    if [ -n "$REMOTE_BACKUP_HOST" ]; then
        ssh "$REMOTE_BACKUP_USER@$REMOTE_BACKUP_HOST" \
            "find $REMOTE_BACKUP_PATH -name 'openclaw-${backup_type}-*.tar.gz' -mtime +$RETENTION_DAYS -delete" \
            >/dev/null 2>&1 || true
    fi
}

restore_backup() {
    local backup_file="$1"
    
    if [ ! -f "$backup_file" ]; then
        log_message "Error: Backup file not found: $backup_file"
        return 1
    fi
    
    log_message "Restoring from backup: $backup_file"
    
    # Create restore directory
    local restore_dir="/tmp/openclaw-restore-$$"
    mkdir -p "$restore_dir"
    
    # Extract backup
    tar -xzf "$backup_file" -C "$restore_dir"
    
    # Stop OpenClaw service
    sudo systemctl stop openclaw
    
    # Restore files
    if [ -d "$restore_dir/app" ]; then
        log_message "Restoring application files..."
        sudo rm -rf /opt/openclaw/app
        sudo cp -r "$restore_dir/app" /opt/openclaw/
        sudo chown -R openclaw:openclaw /opt/openclaw/app
    fi
    
    if [ -d "$restore_dir/config" ]; then
        log_message "Restoring configuration files..."
        sudo cp -r "$restore_dir/config"/* /opt/openclaw/config/
        sudo chown -R openclaw:openclaw /opt/openclaw/config
        sudo chmod 600 /opt/openclaw/config/environment
    fi
    
    if [ -d "$restore_dir/system" ]; then
        log_message "Restoring system configuration..."
        sudo cp "$restore_dir/system/openclaw.service" /etc/systemd/system/
        sudo cp "$restore_dir/system/openclaw" /etc/nginx/sites-available/
        sudo systemctl daemon-reload
    fi
    
    # Start OpenClaw service
    sudo systemctl start openclaw
    
    # Cleanup restore directory
    rm -rf "$restore_dir"
    
    log_message "Restore completed successfully"
    return 0
}

# CLI interface
case "${1:-full}" in
    full)
        create_backup "full"
        ;;
    config)
        create_backup "config"
        ;;
    database)
        create_backup "database"
        ;;
    restore)
        if [ -z "$2" ]; then
            echo "Usage: $0 restore <backup_file>"
            exit 1
        fi
        restore_backup "$2"
        ;;
    list)
        echo "Available backups:"
        ls -lh "$BACKUP_DIR"/*.tar.gz 2>/dev/null || echo "No backups found"
        ;;
    cleanup)
        cleanup_old_backups "full"
        cleanup_old_backups "config"
        cleanup_old_backups "database"
        ;;
    *)
        echo "Usage: $0 [full|config|database|restore|list|cleanup]"
        echo "  full      - Create full system backup (default)"
        echo "  config    - Create configuration backup only"
        echo "  database  - Create database backup only"
        echo "  restore   - Restore from backup file"
        echo "  list      - List available backups"
        echo "  cleanup   - Remove old backups"
        exit 1
        ;;
esac
```

### Automated Backup Schedule

```bash
#!/bin/bash
# Add backup jobs to cron

# Full backup weekly (Sunday at 2 AM)
(crontab -l 2>/dev/null; echo "0 2 * * 0 /opt/openclaw/scripts/backup-system.sh full >/dev/null 2>&1") | crontab -

# Configuration backup daily (1 AM)
(crontab -l 2>/dev/null; echo "0 1 * * * /opt/openclaw/scripts/backup-system.sh config >/dev/null 2>&1") | crontab -

# Database backup every 6 hours
(crontab -l 2>/dev/null; echo "0 */6 * * * /opt/openclaw/scripts/backup-system.sh database >/dev/null 2>&1") | crontab -

# Cleanup old backups weekly (Monday at 3 AM)
(crontab -l 2>/dev/null; echo "0 3 * * 1 /opt/openclaw/scripts/backup-system.sh cleanup >/dev/null 2>&1") | crontab -

echo "✅ Backup schedule installed"
```

## Scaling Considerations

### Load Balancing Setup

```bash
#!/bin/bash
# ~/.openclaw/workspace/scripts/setup-load-balancer.sh
# Setup for multiple OpenClaw instances

echo "⚖️ Setting up load balancing for multiple OpenClaw instances..."

# Install HAProxy
sudo apt install -y haproxy

# Configure HAProxy
sudo tee /etc/haproxy/haproxy.cfg << 'EOF'
global
    daemon
    log stdout local0
    maxconn 4096
    user haproxy
    group haproxy

defaults
    mode http
    log global
    option httplog
    option dontlognull
    option log-health-checks
    option forwardfor
    option http-server-close
    option http-keep-alive
    timeout connect 5000ms
    timeout client 50000ms
    timeout server 50000ms
    timeout http-keep-alive 4s
    timeout http-request 15s
    timeout queue 30s
    
    # Error pages
    errorfile 400 /etc/haproxy/errors/400.http
    errorfile 403 /etc/haproxy/errors/403.http
    errorfile 408 /etc/haproxy/errors/408.http
    errorfile 500 /etc/haproxy/errors/500.http
    errorfile 502 /etc/haproxy/errors/502.http
    errorfile 503 /etc/haproxy/errors/503.http
    errorfile 504 /etc/haproxy/errors/504.http

# Stats page
listen stats
    bind *:8404
    stats enable
    stats uri /stats
    stats refresh 30s
    stats admin if TRUE

# Frontend
frontend openclaw_frontend
    bind *:80
    bind *:443 ssl crt /etc/ssl/certs/yourdomain.com.pem
    
    # Redirect HTTP to HTTPS
    redirect scheme https if !{ ssl_fc }
    
    # Health check endpoint
    acl health_check path_beg /health
    use_backend health_backend if health_check
    
    # Default backend
    default_backend openclaw_backend

# Backend for health checks
backend health_backend
    http-request return status 200 content-type "text/plain" string "OK"

# Main backend
backend openclaw_backend
    balance roundrobin
    option httpchk GET /health
    http-check expect status 200
    
    # Backend servers (add more as needed)
    server openclaw1 127.0.0.1:3000 check weight 100
    server openclaw2 127.0.0.1:3001 check weight 100 backup
    # server openclaw3 10.0.0.3:3000 check weight 100
    # server openclaw4 10.0.0.4:3000 check weight 100
EOF

# Enable and start HAProxy
sudo systemctl enable haproxy
sudo systemctl restart haproxy

# Update Nginx to proxy to HAProxy instead
sudo tee /etc/nginx/sites-available/openclaw << 'EOF'
# OpenClaw with HAProxy Load Balancer

upstream openclaw_lb {
    server 127.0.0.1:80 max_fails=3 fail_timeout=30s;
    keepalive 32;
}

server {
    listen 80;
    server_name yourdomain.com www.yourdomain.com;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name yourdomain.com www.yourdomain.com;
    
    # SSL configuration
    ssl_certificate /etc/letsencrypt/live/yourdomain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/yourdomain.com/privkey.pem;
    
    location / {
        proxy_pass http://openclaw_lb;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
    
    # HAProxy stats
    location /admin/stats {
        proxy_pass http://127.0.0.1:8404/stats;
        auth_basic "HAProxy Statistics";
        auth_basic_user_file /etc/nginx/.htpasswd;
    }
}
EOF

sudo nginx -t && sudo systemctl restart nginx

echo "✅ Load balancing setup completed"
echo "📊 HAProxy stats available at: https://yourdomain.com/admin/stats"
echo "🔧 Add more OpenClaw instances by editing /etc/haproxy/haproxy.cfg"
```

### Database Scaling

```sql
-- Setup for PostgreSQL with read replicas
-- ~/.openclaw/workspace/sql/setup-postgres-scaling.sql

-- Create database for OpenClaw
CREATE DATABASE openclaw_production;
CREATE USER openclaw_user WITH PASSWORD 'secure_password_here';
GRANT ALL PRIVILEGES ON DATABASE openclaw_production TO openclaw_user;

-- Connect to openclaw_production database
\c openclaw_production

-- Create tables with proper indexing for scale
CREATE TABLE IF NOT EXISTS sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    data JSONB NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL
);

CREATE INDEX idx_sessions_user_id ON sessions(user_id);
CREATE INDEX idx_sessions_expires_at ON sessions(expires_at);

-- Partitioned logs table for performance
CREATE TABLE logs (
    id BIGSERIAL,
    level VARCHAR(20) NOT NULL,
    message TEXT NOT NULL,
    metadata JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
) PARTITION BY RANGE (created_at);

-- Create monthly partitions
CREATE TABLE logs_2024_01 PARTITION OF logs
    FOR VALUES FROM ('2024-01-01') TO ('2024-02-01');

-- Add more partitions as needed...

-- Indexes for logs
CREATE INDEX idx_logs_level ON logs(level);
CREATE INDEX idx_logs_created_at ON logs(created_at);

-- Create read replica connection (for read-only queries)
-- This would be configured in your application connection pool
-- Example connection string: postgresql://readonly_user:password@replica-host:5432/openclaw_production
```

## Pro Tips

**🔍 Monitor Everything:** Set up monitoring before you need it. When things break at 3 AM, you need to know immediately.

**🔐 Security First:** A hacked server costs more than proper security. Invest in firewalls, fail2ban, and regular updates.

**💾 Backup Religiously:** Test your backups. A backup you can't restore is worthless. Schedule regular restoration tests.

**📊 Capacity Planning:** Monitor resource usage trends. Scale before you hit limits, not after your service crashes.

**🔄 Automation:** Automate deployment, monitoring, backups, and scaling. Manual processes don't scale with your business.

## Troubleshooting

### Issue 1: Service Won't Start
**Symptoms:** `systemctl start openclaw` fails
**Diagnosis:** Configuration or permission issues
**Fix:**
```bash
# Check service logs
journalctl -u openclaw -f

# Verify file permissions
sudo chown -R openclaw:openclaw /opt/openclaw
sudo chmod 600 /opt/openclaw/config/environment

# Check environment variables
sudo -u openclaw env | grep -E "(NODE|OPENCLAW|API)"

# Test manual startup
sudo -u openclaw node /usr/local/bin/openclaw daemon
```

### Issue 2: High Memory Usage
**Symptoms:** Server running out of memory, OOM kills
**Diagnosis:** Memory leak or insufficient resources
**Fix:**
```bash
# Monitor memory usage
watch -n 1 'free -m'

# Check OpenClaw memory usage
ps aux | grep openclaw | grep -v grep

# Add swap space (temporary solution)
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

# Add to /etc/fstab for permanent swap
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
```

### Issue 3: SSL Certificate Issues
**Symptoms:** HTTPS not working, certificate errors
**Diagnosis:** Certificate expired or misconfigured
**Fix:**
```bash
# Check certificate status
sudo certbot certificates

# Renew certificates
sudo certbot renew --dry-run
sudo certbot renew

# Test automatic renewal
sudo systemctl status certbot.timer
sudo systemctl enable certbot.timer
```

### Issue 4: Database Connection Failures
**Symptoms:** Application can't connect to database
**Diagnosis:** Database down, connection limit exceeded, or network issues
**Fix:**
```bash
# Check database status (if using PostgreSQL)
sudo systemctl status postgresql

# Check connection limits
sudo -u postgres psql -c "SHOW max_connections;"
sudo -u postgres psql -c "SELECT count(*) FROM pg_stat_activity;"

# Test connection from application server
psql -h database-host -U openclaw_user -d openclaw_production -c "SELECT 1;"
```

### Issue 5: Load Balancer Health Checks Failing
**Symptoms:** Backend servers marked as down in HAProxy stats
**Diagnosis:** Health check endpoint not responding or misconfigured
**Fix:**
```bash
# Test health check endpoint directly
curl -I http://localhost:3000/health

# Check HAProxy logs
sudo tail -f /var/log/haproxy.log

# Verify backend server status
sudo systemctl status openclaw

# Test backend connectivity
telnet localhost 3000
```

Production infrastructure separates professionals from hobbyists. When your AI systems are processing millions of dollars in transactions, handling thousands of customers, and running critical business operations, you need infrastructure that never fails.

This chapter gave you the blueprint for bulletproof VPS deployment that scales with your success. Build it right once, and it becomes the foundation for everything you achieve in business automation.

The most successful AI entrepreneurs don't just build great products — they build unshakeable infrastructure that customers can depend on. Now you can too.