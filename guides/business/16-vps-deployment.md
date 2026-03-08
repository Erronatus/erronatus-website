# Chapter 16: 24/7 Operations
## VPS Deployment & Monitoring

---

### Why Go 24/7

Running OpenClaw on your laptop works until you close the lid. For a business operation — automated trading monitors, client reports, email sequences, market analysis — you need 24/7 uptime.

A VPS (Virtual Private Server) costs $5-20/month and runs your AI system around the clock.

### Choosing a VPS Provider

| Provider | Starting Price | Best For |
|----------|---------------|----------|
| **DigitalOcean** | $6/month | Simplicity, great docs |
| **Hetzner** | €4.50/month | Best value in Europe |
| **Vultr** | $6/month | Global locations |
| **Linode** | $5/month | Reliable, developer-friendly |
| **AWS Lightsail** | $5/month | AWS ecosystem |

**Recommended specs for OpenClaw:**
- 2 GB RAM (minimum)
- 1 vCPU
- 50 GB SSD
- Ubuntu 22.04 LTS

### Server Setup

**1. Create and connect to your VPS:**
```bash
ssh root@your-server-ip
```

**2. Create a non-root user:**
```bash
adduser openclaw
usermod -aG sudo openclaw
su - openclaw
```

**3. Install Node.js:**
```bash
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs
```

**4. Install OpenClaw:**
```bash
npm install -g openclaw
```

**5. Transfer your configuration:**
Copy your local `~/.openclaw/` directory to the server:
```bash
scp -r ~/.openclaw/ openclaw@your-server-ip:~/.openclaw/
```

**6. Start as a system service:**

Create `/etc/systemd/system/openclaw.service`:
```ini
[Unit]
Description=OpenClaw AI Gateway
After=network.target

[Service]
Type=simple
User=openclaw
WorkingDirectory=/home/openclaw
ExecStart=/usr/bin/openclaw gateway start
Restart=always
RestartSec=10
Environment=NODE_ENV=production

[Install]
WantedBy=multi-user.target
```

Enable and start:
```bash
sudo systemctl enable openclaw
sudo systemctl start openclaw
sudo systemctl status openclaw
```

### Monitoring

**Check status remotely:**
Message your AI on Telegram — if it responds, it's running.

**System health check cron:**
Set up a cron job that checks gateway health every 15 minutes and alerts you if it's down.

**Log monitoring:**
```bash
journalctl -u openclaw -f    # Live logs
journalctl -u openclaw --since "1 hour ago"    # Recent logs
```

### Security Hardening

1. **SSH keys only** — Disable password authentication
2. **Firewall** — Allow only ports 22 (SSH) and 443 (HTTPS)
3. **Automatic updates** — Enable unattended-upgrades
4. **Fail2ban** — Block brute force attempts
5. **Regular backups** — Snapshot your VPS weekly

### What You've Built

✅ VPS provisioned and configured
✅ OpenClaw running as a system service with auto-restart
✅ 24/7 uptime for all automations
✅ Remote monitoring via Telegram
✅ Security hardening applied
✅ A production-grade AI operations infrastructure

---

*Congratulations. You've built a complete business automation system.*

*For the ultimate package — pre-built workspace, scraping engines, lead generation, email outreach, and 50+ cron templates ready to deploy — upgrade to Enterprise at erronatus.com.*
