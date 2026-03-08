# Chapter 2: Infrastructure
## Installing & Configuring OpenClaw

---

### What We're Building

By the end of this chapter, you'll have:
- OpenClaw installed on your machine
- A workspace directory initialized with all configuration files
- The gateway running and ready to accept connections
- Your first AI model connected and responding

Time required: 30-45 minutes.

### Step 1: Install Node.js

OpenClaw runs on Node.js. If you don't have it installed:

**Windows:**
1. Visit nodejs.org
2. Download the LTS version (20.x or higher)
3. Run the installer, accept all defaults
4. Open PowerShell and verify: `node --version`

**macOS:**
```bash
# Using Homebrew (recommended)
brew install node

# Verify
node --version
```

**Linux (Ubuntu/Debian):**
```bash
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs
node --version
```

You need Node.js 20 or higher. If `node --version` shows 20.x or above, you're good.

### Step 2: Install OpenClaw

Open your terminal (PowerShell on Windows, Terminal on macOS/Linux):

```bash
npm install -g openclaw
```

This installs OpenClaw globally. Verify the installation:

```bash
openclaw --version
```

You should see the version number (2026.3.x or similar).

### Step 3: Initialize Your Workspace

Your workspace is where OpenClaw stores all configuration, memory, and project files. Initialize it:

```bash
openclaw init
```

The initialization wizard will ask you several questions:
1. **Workspace location** — Accept the default (`~/.openclaw/workspace/`) or choose your own
2. **Channel** — Select Telegram or Discord (we'll configure this in Chapter 3)
3. **AI Provider** — Select your provider (OpenRouter recommended for beginners)
4. **API Key** — Enter your AI provider API key

> **Getting an API Key:**
> If you don't have an AI provider API key yet:
> 1. Go to openrouter.ai and create a free account
> 2. Navigate to Keys → Create Key
> 3. Copy the key (starts with `sk-or-v1-`)
> 4. Add $5-10 of credit to start
>
> OpenRouter gives you access to dozens of models (GPT-4, Claude, Gemini, DeepSeek, Llama, and more) through a single API key. This is the easiest way to get started.

After initialization, your workspace will contain:

```
~/.openclaw/
├── config.yaml          ← Gateway configuration
├── workspace/
│   ├── AGENTS.md        ← AI behavior rules
│   ├── SOUL.md          ← AI personality & guidelines
│   ├── USER.md          ← Information about you
│   ├── MEMORY.md        ← Long-term memory
│   ├── TOOLS.md         ← Local environment notes
│   └── memory/          ← Daily memory files
└── .env                 ← API keys and secrets
```

### Step 4: Configure Your AI's Identity

This is where OpenClaw differs from every other AI tool. Your AI reads these files every session to understand who it is and who you are.

**Edit `SOUL.md`** — This defines your AI's personality:

```markdown
# SOUL.md - Who I Am

I'm your personal AI automation assistant. I help you build
systems, automate tasks, and manage information efficiently.

## Core Principles
- Be direct and concise
- Solve problems, don't just describe them
- Ask before taking external actions
- Remember context across sessions

## Communication Style
- Clear, professional, no filler
- Use bullet points for lists
- Provide code examples when relevant
```

**Edit `USER.md`** — This tells your AI about you:

```markdown
# USER.md - About My Human

- **Name:** [Your name]
- **Timezone:** [Your timezone, e.g., America/New_York]
- **Goals:** [What you want to automate]
- **Preferences:** [Communication style, topics of interest]
```

**Edit `AGENTS.md`** — This defines operational rules. The default is well-crafted, but you can customize:

```markdown
# AGENTS.md

## Every Session
1. Read SOUL.md — who you are
2. Read USER.md — who you're helping  
3. Read recent memory files for context

## Memory
- Write daily notes to memory/YYYY-MM-DD.md
- Update MEMORY.md with important long-term information
- Capture decisions, context, lessons learned

## Safety
- Don't run destructive commands without asking
- Ask before sending emails or public posts
- Keep private information private
```

> **Pro Tip:** Don't overthink these files initially. Start with the basics and refine them as you learn what works. Your AI will read them every session, so changes take effect immediately.

### Step 5: Start the Gateway

The gateway is OpenClaw's core process. It handles all communication, model routing, and tool execution.

```bash
openclaw gateway start
```

You should see output like:

```
✓ Gateway started on port 18789
✓ Workspace loaded: ~/.openclaw/workspace/
✓ Model: anthropic/claude-sonnet-4-20250514
✓ Channel: telegram (pending configuration)
```

Check the status at any time:

```bash
openclaw status
```

This shows:
- Gateway version and uptime
- Active model and token usage
- Connected channels
- Session information
- Cost tracking

### Step 6: Verify Everything Works

Before we connect a messaging channel (next chapter), let's verify the AI is responding:

```bash
openclaw gateway status
```

If everything is green, your infrastructure is ready. The gateway is running, your workspace is configured, and your AI model is connected.

### Understanding the Configuration

Your `config.yaml` file controls everything. Here are the key settings:

```yaml
# Model Configuration
model: anthropic/claude-sonnet-4-20250514    # Default AI model
thinking: adaptive                            # Reasoning mode

# Workspace
workspace: ~/.openclaw/workspace/

# Gateway
gateway:
  port: 18789
  
# Channel (configured in Chapter 3)
channels:
  telegram:
    token: ""    # Your bot token goes here
```

You can edit this file directly or use:
```bash
openclaw gateway config
```

### Troubleshooting

**"Command not found" after installing:**
- Windows: Close and reopen PowerShell
- macOS/Linux: Run `source ~/.bashrc` or open a new terminal

**"Invalid API key" error:**
- Double-check your key has no extra spaces
- Verify the key is active at your provider's dashboard
- Make sure you have credit/balance on the account

**Gateway won't start:**
- Check if port 18789 is available: `netstat -an | grep 18789`
- Try a different port in config.yaml
- Check logs: `openclaw gateway logs`

**"Workspace not found" error:**
- Run `openclaw init` again
- Verify the path in config.yaml matches your workspace location

### What You've Built

At the end of this chapter, you have:

✅ Node.js installed and verified
✅ OpenClaw installed globally
✅ Workspace initialized with identity files
✅ AI personality and user information configured
✅ Gateway running and connected to an AI model

Your AI exists. It has an identity, it knows who you are, and it's ready to work. But right now, the only way to talk to it is through the command line.

In the next chapter, we'll give it a proper communication channel — so you can message it from your phone, your desktop, or anywhere in the world.

---

*Next Chapter: Your Command Interface — Telegram & Discord Setup →*
