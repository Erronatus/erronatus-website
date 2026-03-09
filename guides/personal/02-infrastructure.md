# Chapter 2: Infrastructure
*Installing Node.js and OpenClaw on Windows, Mac, and Linux*

## What You're Building

By the end of this chapter, you'll have:
- Node.js installed and verified on your system
- OpenClaw running as a global command-line tool
- A complete `.openclaw` directory structure with all configuration files
- Your first successful test conversation with an AI model
- Understanding of how the gateway architecture routes messages
- A `.env` file configured with starter API keys
- Confidence troubleshooting common installation issues

This is your foundation layer - everything else builds on getting this right.

## Why Infrastructure Matters

Most people want to skip straight to the "fun stuff" - talking to AI, building automations, creating magic. But here's what happens without solid infrastructure:

- Your AI randomly stops responding (Node.js process died)
- Commands work sometimes but not others (PATH issues)
- You get cryptic error messages (missing dependencies)
- Your setup breaks when you restart your computer (no auto-start)
- API costs spiral out of control (no monitoring)

Infrastructure is the difference between a working system and an expensive tech demo.

**Think of it like building a house:** You can have the most beautiful furniture and decor, but if the foundation is cracked, the plumbing leaks, and the electrical shorts out, you'll be miserable.

## Node.js Installation: The Platform

OpenClaw runs on Node.js - a JavaScript runtime that lets you run JavaScript programs outside of web browsers. You need Node.js version 18 or higher.

### Windows Installation

#### Method 1: Official Installer (Recommended)

1. **Download Node.js**
   - Go to https://nodejs.org
   - Download the LTS version (Long Term Support) - currently v18.19.0 or newer
   - Choose "Windows Installer (.msi)" for your system (64-bit for most computers)

2. **Run the installer**
   - Double-click the downloaded `.msi` file
   - Click "Next" through the welcome screens
   - **IMPORTANT:** Check "Automatically install the necessary tools" when prompted
   - This installs Python and Visual Studio build tools needed for some packages
   - Accept the license agreement
   - Choose the default installation directory: `C:\Program Files\nodejs\`
   - Click "Install" and enter your password when prompted

3. **Verify the installation**
   - Press `Win + R`, type `cmd`, press Enter
   - Type: `node --version`
   - Expected output: `v18.19.0` (or newer)
   - Type: `npm --version` 
   - Expected output: `9.2.0` (or newer)

If both commands show version numbers, you're ready to proceed.

#### Method 2: Winget (Alternative)

If you prefer command-line installation:

```powershell
# Open PowerShell as Administrator
# Press Win + X, choose "Windows PowerShell (Admin)"

winget install OpenJS.NodeJS
```

#### Method 3: Chocolatey (Alternative)

If you use Chocolatey package manager:

```powershell
# In Administrator PowerShell
choco install nodejs
```

### macOS Installation

#### Method 1: Official Installer (Recommended)

1. **Download Node.js**
   - Go to https://nodejs.org
   - Download the LTS version 
   - Choose "macOS Installer (.pkg)"

2. **Run the installer**
   - Double-click the downloaded `.pkg` file
   - Follow the installation wizard
   - Enter your password when prompted
   - Node.js installs to `/usr/local/bin/node`

3. **Verify the installation**
   - Press `Cmd + Space`, type "Terminal", press Enter
   - Type: `node --version`
   - Type: `npm --version`

#### Method 2: Homebrew (Alternative)

If you use Homebrew:

```bash
# Install Homebrew first if you don't have it
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install Node.js
brew install node
```

#### Method 3: Node Version Manager (Advanced)

For managing multiple Node.js versions:

```bash
# Install NVM
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash

# Restart terminal or run:
source ~/.bashrc

# Install and use latest LTS
nvm install --lts
nvm use --lts
```

### Linux Installation

#### Ubuntu/Debian

```bash
# Method 1: Official NodeSource repository (recommended)
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt-get install -y nodejs

# Verify installation
node --version
npm --version
```

#### CentOS/RHEL/Fedora

```bash  
# Method 1: Official NodeSource repository
curl -fsSL https://rpm.nodesource.com/setup_lts.x | sudo bash -
sudo dnf install -y nodejs npm

# Method 2: DNF package manager (Fedora)
sudo dnf install npm nodejs
```

#### Arch Linux

```bash
sudo pacman -S nodejs npm
```

#### Generic Linux (Alternative)

```bash
# Download and extract Node.js binary
wget https://nodejs.org/dist/v18.19.0/node-v18.19.0-linux-x64.tar.xz
tar -xf node-v18.19.0-linux-x64.tar.xz
sudo mv node-v18.19.0-linux-x64 /opt/nodejs
sudo ln -s /opt/nodejs/bin/node /usr/local/bin/node  
sudo ln -s /opt/nodejs/bin/npm /usr/local/bin/npm
```

## Installing OpenClaw: Your AI Command Center

Once Node.js is installed, OpenClaw installation is identical across all platforms.

### Global Installation

```bash
# Install OpenClaw globally
npm install -g openclaw

# Verify installation  
openclaw --version
```

Expected output: `openclaw v2.1.0` (or newer)

If you see a version number, OpenClaw is installed correctly.

### What Just Happened

The `npm install -g openclaw` command:

1. **Downloaded OpenClaw** from the npm registry (the official Node.js package repository)
2. **Installed it globally** so you can run `openclaw` from any directory
3. **Added it to your PATH** so your terminal can find the command
4. **Installed all dependencies** - about 200 packages that OpenClaw needs

The `-g` flag means "global" - install this as a system-wide command, not just in the current folder.

### First Run: Creating Your Workspace

```bash  
# Create and navigate to your workspace directory
# Windows
mkdir C:\Users\%USERNAME%\.openclaw\workspace
cd C:\Users\%USERNAME%\.openclaw\workspace

# macOS/Linux  
mkdir -p ~/.openclaw/workspace
cd ~/.openclaw/workspace

# Initialize OpenClaw
openclaw init
```

The `openclaw init` command creates your workspace structure:

```
~/.openclaw/
├── workspace/           ← Your working directory
│   ├── AGENTS.md       ← Instructions for AI behavior  
│   ├── SOUL.md         ← AI personality and rules
│   ├── USER.md         ← Information about you
│   ├── MEMORY.md       ← Long-term memory storage
│   └── memory/         ← Daily logs directory
├── gateway.log         ← Service logs
├── config.json         ← OpenClaw configuration
└── .env                ← API keys and secrets
```

### Understanding the Directory Structure

Let's examine each file and directory:

#### `workspace/` Directory

This is your AI's home directory - where it lives, works, and stores memory.

**`AGENTS.md`** - Instructions for AI behavior
- How to handle different types of requests
- When to ask permission vs act autonomously  
- Memory management rules
- Security boundaries

**`SOUL.md`** - AI personality and communication style
- Tone and voice preferences
- How formal or casual to be
- Expertise areas to emphasize
- Communication preferences

**`USER.md`** - Information about you
- Your name, timezone, preferences
- Context about your work and interests
- How you like to receive information
- Important personal details

**`MEMORY.md`** - Long-term memory storage
- Important decisions and their reasoning
- Lessons learned from past interactions
- Recurring themes and patterns
- Strategic context that should persist

**`memory/`** - Daily logs directory
- Separate file for each day: `2024-03-08.md`
- Raw logs of conversations and events
- Searchable history of all interactions
- Automatic cleanup of old files

#### Configuration Files

**`config.json`** - OpenClaw system configuration
```json
{
  "defaultModel": "anthropic/claude-sonnet-3-5",
  "maxTokens": 4096,
  "temperature": 0.7,
  "logLevel": "info"
}
```

**`.env`** - Secrets and API keys (never share this file!)
```bash
# AI Model Providers
OPENAI_API_KEY=sk-...
ANTHROPIC_API_KEY=sk-ant-...
OPENROUTER_API_KEY=sk-or-...

# Communication Channels  
TELEGRAM_BOT_TOKEN=123456:ABC-DEF...
DISCORD_BOT_TOKEN=MTk4...

# Data Sources
BRAVE_SEARCH_API_KEY=BSA...
ALPHA_VANTAGE_API_KEY=ABC123...
```

**`gateway.log`** - Service logs
- All system events and errors
- API request/response logs
- Performance metrics
- Debugging information

### Why This Matters: The Gateway Architecture

OpenClaw uses a "gateway" architecture that separates communication from processing:

```
[Your Message] → [Gateway] → [AI Model] → [Tools] → [Response] → [You]
                     ↓
                [Workspace]
                [Memory] 
                [Logs]
```

**The Gateway handles:**
- Receiving messages from Telegram/Discord/CLI
- Routing to appropriate AI models
- Managing conversation context and memory
- Executing tool calls (file operations, web searches, etc.)
- Formatting and delivering responses

**Why this architecture matters:**
- **Reliability:** Gateway runs continuously, AI models are called as needed
- **Cost efficiency:** Only pay for AI when actually processing
- **Multi-channel:** Same AI accessible via Telegram, Discord, web interface
- **Offline capability:** Gateway queues messages when models are unavailable
- **Debugging:** All interactions logged and traceable

## Creating Your First .env File

The `.env` file stores your API keys and configuration secrets. OpenClaw needs at least one AI model provider to function.

### Starter Configuration

Create `~/.openclaw/.env` with these contents:

```bash
# === REQUIRED: AI Model Provider ===
# Get one of these to start - OpenRouter is recommended for beginners

# Option 1: OpenRouter (easiest - access to many models)  
OPENROUTER_API_KEY=your_key_here
OPENROUTER_DEFAULT_MODEL=anthropic/claude-sonnet-3-5

# Option 2: Anthropic Direct
# ANTHROPIC_API_KEY=your_key_here

# Option 3: OpenAI Direct  
# OPENAI_API_KEY=your_key_here

# === OPTIONAL: Communication Channels ===
# TELEGRAM_BOT_TOKEN=your_bot_token_here
# DISCORD_BOT_TOKEN=your_discord_token_here

# === OPTIONAL: Data Sources ===
# BRAVE_SEARCH_API_KEY=your_brave_key_here  
# ALPHA_VANTAGE_API_KEY=your_alphav_key_here
# NEWS_API_KEY=your_newsapi_key_here

# === SYSTEM CONFIGURATION ===
LOG_LEVEL=info
MAX_CONTEXT_TOKENS=100000
DEFAULT_TEMPERATURE=0.7
```

### Getting Your First API Key

For getting started, I recommend OpenRouter - it provides access to many AI models through one API key:

1. **Sign up at OpenRouter**
   - Go to https://openrouter.ai
   - Click "Sign Up" and create an account
   - Verify your email address

2. **Add payment method**
   - Go to Account → Billing  
   - Add a credit card
   - Set a spending limit (start with $10-20)

3. **Generate API key**
   - Go to Account → Keys
   - Click "Create Key"
   - Copy the key starting with `sk-or-`
   - Paste it in your `.env` file as `OPENROUTER_API_KEY=sk-or-...`

### File Security Warning

⚠️ **NEVER commit `.env` files to version control or share them publicly.** They contain API keys worth real money.

**Secure your .env file:**

```bash
# Windows
attrib +h C:\Users\%USERNAME%\.openclaw\.env

# macOS/Linux
chmod 600 ~/.openclaw/.env
```

This makes the file hidden (Windows) or readable only by you (macOS/Linux).

## Verification: Testing Your Installation

Let's verify everything is working with a series of tests.

### Test 1: OpenClaw Command Access

```bash  
# Should show version information
openclaw --version

# Should show help menu
openclaw --help
```

Expected output includes command list and usage examples.

### Test 2: Workspace Structure

```bash
# Navigate to workspace
cd ~/.openclaw/workspace

# List files (should show AGENTS.md, SOUL.md, etc.)
# Windows
dir

# macOS/Linux
ls -la
```

You should see all the workspace files created by `openclaw init`.

### Test 3: Configuration Loading

```bash
# Test configuration loading
openclaw config show
```

This should display your current configuration without errors.

### Test 4: API Connection

```bash
# Test AI model connection  
openclaw chat "Hello! Can you confirm you're working?"
```

Expected response: A greeting from your AI confirming the connection works.

If you get an error, check that:
- Your `.env` file is in the right location (`~/.openclaw/.env`)
- Your API key is valid and has credit balance
- Your internet connection is working

### Test 5: Gateway Status

```bash
# Check gateway status
openclaw gateway status
```

Expected output: Gateway status information including uptime and configuration.

## Understanding Message Flow

When you send a message through OpenClaw, here's what happens:

```
1. Message Received
   ↓
2. Authentication Check  
   ↓
3. Context Loading (workspace files, memory)
   ↓
4. AI Model Selection (based on task type)
   ↓  
5. Prompt Construction (system message + context + user message)
   ↓
6. API Request to Model Provider
   ↓
7. Response Processing  
   ↓
8. Tool Execution (if AI requests file operations, web searches, etc.)
   ↓
9. Memory Logging (conversation saved to daily log)
   ↓
10. Response Delivery (back to you via same channel)
```

**Why this matters:** Understanding the flow helps you debug issues and optimize performance. If responses are slow, the bottleneck might be at step 6 (API request) or step 8 (tool execution).

### Performance Optimization

**Fast responses (< 2 seconds):**
- Use lighter models for simple questions
- Keep context files concise
- Minimize tool usage for quick queries

**Quality responses (5-15 seconds):**
- Use premium models for complex reasoning
- Include rich context from memory files
- Allow multiple tool calls for comprehensive answers

## Pro Tips: Infrastructure Best Practices

💡 **Use a dedicated directory for workspace files.** Don't mix OpenClaw files with your regular documents. The AI needs clean, organized context.

💡 **Start with one AI provider, add others later.** Getting OpenRouter working is easier than configuring multiple providers simultaneously. 

💡 **Monitor your API usage from day one.** Set spending limits on your AI provider accounts. A runaway automation can cost hundreds of dollars.

💡 **Keep workspace files small initially.** Large MEMORY.md or SOUL.md files slow down every interaction. Start minimal, expand as needed.

💡 **Use environment variables for anything that might change.** Paths, model names, cost limits - anything that differs between development and production.

## Troubleshooting: Common Installation Issues

### Problem: "node: command not found"

**Diagnosis:** Node.js not installed or not in PATH.
**Fix:**
```bash
# Check if Node.js is actually installed
# Windows
where node

# macOS/Linux  
which node
```

If no path is returned, reinstall Node.js using the official installer.

If a path is returned but the command doesn't work, add Node.js to your PATH:

```bash
# Windows - add to PATH environment variable
C:\Program Files\nodejs\

# macOS/Linux - add to shell profile
echo 'export PATH="/usr/local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

### Problem: "npm: permission denied" (macOS/Linux)

**Diagnosis:** npm trying to install to system directories without permission.
**Fix:**
```bash
# Option 1: Fix npm permissions (recommended)
mkdir ~/.npm-global
npm config set prefix '~/.npm-global'
echo 'export PATH="~/.npm-global/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc

# Then reinstall OpenClaw
npm install -g openclaw

# Option 2: Use sudo (not recommended)
sudo npm install -g openclaw
```

### Problem: "openclaw: command not found" after installation

**Diagnosis:** npm global bin directory not in PATH.
**Fix:**
```bash
# Find npm global bin directory
npm bin -g

# Add that directory to your PATH
# The exact command varies by shell and OS
echo 'export PATH="$(npm bin -g):$PATH"' >> ~/.bashrc
source ~/.bashrc
```

### Problem: "EACCES: permission denied" on Windows

**Diagnosis:** Antivirus or Windows Defender blocking npm installation.
**Fix:**
1. Temporarily disable real-time protection in Windows Defender
2. Run PowerShell as Administrator
3. Install OpenClaw: `npm install -g openclaw`
4. Re-enable Windows Defender
5. Add npm and node directories to Defender exclusions

### Problem: Node.js version too old

**Diagnosis:** OpenClaw requires Node.js 18+, you have an older version.
**Fix:**
```bash
# Check current version
node --version

# If less than v18.0.0, uninstall and reinstall
# Windows: Use Add/Remove Programs
# macOS: Use installer to upgrade
# Linux: Use package manager to upgrade

# Or use Node Version Manager
nvm install 18
nvm use 18
```

### Problem: ".env file not found" errors

**Diagnosis:** `.env` file in wrong location or wrong permissions.
**Fix:**
```bash
# Verify .env location
# Should be in ~/.openclaw/.env, NOT ~/.openclaw/workspace/.env

# Check file exists
# Windows  
dir %USERPROFILE%\.openclaw\.env

# macOS/Linux
ls -la ~/.openclaw/.env

# If missing, create with starter configuration
cd ~/.openclaw
notepad .env    # Windows
nano .env       # Linux  
open .env       # macOS
```

## Try This: Installation Verification Checklist

Work through this checklist to verify your installation is bulletproof:

### ✅ Phase 1: Basic Installation

- [ ] `node --version` returns v18+ 
- [ ] `npm --version` returns 9+
- [ ] `openclaw --version` returns version number
- [ ] `openclaw --help` shows command list

### ✅ Phase 2: Directory Structure  

- [ ] `~/.openclaw/workspace/` directory exists
- [ ] AGENTS.md, SOUL.md, USER.md files present
- [ ] `memory/` subdirectory exists
- [ ] `.env` file exists in `~/.openclaw/` (not workspace!)

### ✅ Phase 3: Configuration

- [ ] `.env` file contains at least one AI provider key
- [ ] `openclaw config show` runs without errors
- [ ] API key has positive credit balance
- [ ] Spending limits set on AI provider account

### ✅ Phase 4: Connectivity

- [ ] `openclaw chat "test"` returns AI response
- [ ] `openclaw gateway status` shows running status
- [ ] Response time < 30 seconds for simple queries
- [ ] No error messages in terminal output

### ✅ Phase 5: Security

- [ ] `.env` file permissions restricted (600 on Unix)
- [ ] API keys not visible in shell history
- [ ] Spending alerts configured on AI accounts
- [ ] Backup of configuration files created

If any item fails, review the troubleshooting section above.

## What's Next

Chapter 3 covers setting up communication channels - connecting Telegram and Discord so you can access your AI from anywhere. You'll learn how to create bots, configure webhooks, and have your first real conversation with your AI assistant.

But first, make sure your infrastructure is solid. Run through the verification checklist above. Fix any issues now - they only get harder to debug once you add more complexity.

The next chapter assumes you have a working OpenClaw installation that responds to `openclaw chat` commands. If that's not working, don't proceed - go back and fix the infrastructure first.

Strong foundations make everything else possible.

---

*Next: Chapter 3 - Command Interface*