# Chapter 3: Command Interface
*Connecting Telegram and Discord for anywhere access to your AI*

## What You're Building

By the end of this chapter, you'll have:
- A Telegram bot connected to your OpenClaw system
- Mobile access to your AI from anywhere with internet
- Understanding of slash commands for system control
- Discord bot configured as a backup channel
- Your first real conversation showing AI capabilities
- Session management working across multiple devices
- Troubleshooting skills for connection issues

You'll transform from command-line only to having a personal AI assistant in your pocket.

## Why Communication Channels Matter

Command-line chat (`openclaw chat "hello"`) works for testing, but it's not practical for daily use. You need to access your AI:

- **From your phone** while commuting or traveling
- **From any device** without installing OpenClaw
- **In group contexts** where others can interact with your AI
- **Asynchronously** - send a request, get response later
- **With rich formatting** - images, files, interactive buttons

Communication channels bridge the gap between a local CLI tool and a truly useful personal assistant.

**Think of channels as interfaces to the same brain.** Whether you message via Telegram, Discord, or command line, you're talking to the same AI with the same memory and capabilities.

## Telegram Setup: Your Primary Interface

Telegram is ideal for personal AI access because:
- Excellent mobile apps for iOS/Android  
- Desktop apps for Windows/Mac/Linux
- Instant delivery and notification system
- Support for files, images, and rich formatting
- Privacy-focused (messages encrypted)
- Works reliably in most countries

### Step 1: Create Your Telegram Bot

Telegram bots are created through @BotFather - Telegram's official bot management system.

1. **Start conversation with BotFather**
   - Open Telegram app or go to https://web.telegram.org
   - Search for `@BotFather` (verified account with blue checkmark)
   - Click "START" or send `/start`

2. **Create new bot**
   - Send command: `/newbot`
   - BotFather responds: "Alright, a new bot. How are we going to call it? Please choose a name for your bot."

3. **Choose bot name**
   - Send your bot's display name, for example: `My AI Assistant`
   - This is what users see in chat - can be anything descriptive

4. **Choose bot username**  
   - BotFather responds: "Good. Now let's choose a username for your bot. It must end in 'bot'. Like this, for example: TetrisBot or tetris_bot."
   - Send username ending in 'bot', for example: `jackson_ai_bot`
   - Must be unique across all Telegram - try variations if taken

5. **Save your bot token**
   - BotFather responds with success message including bot token
   - Example token: `123456789:AAHdqTcvCH1vGWJxfSeofSAs0K5PALDsaw`
   - **CRITICAL:** Copy this token immediately - you can't see it again without regenerating

**Expected BotFather conversation:**
```
BotFather: Alright, a new bot. How are we going to call it?
You: My AI Assistant

BotFather: Good. Now let's choose a username for your bot.  
You: jackson_ai_bot

BotFather: Done! Congratulations on your new bot. You will find it at 
t.me/jackson_ai_bot. You can now add a description, about section and 
profile picture for your bot.

Use this token to access the HTTP API:
123456789:AAHdqTcvCH1vGWJxfSeofSAs0K5PALDsaw
```

### Step 2: Configure OpenClaw with Bot Token

Add your bot token to the `.env` file:

```bash
# Navigate to OpenClaw directory
cd ~/.openclaw

# Edit .env file (use your preferred editor)
# Windows
notepad .env

# macOS  
open .env

# Linux
nano .env
```

Add this line to your `.env` file:
```bash
TELEGRAM_BOT_TOKEN=123456789:AAHdqTcvCH1vGWJxfSeofSAs0K5PALDsaw
```

Replace with your actual token from BotFather.

### Step 3: Start the Gateway

The OpenClaw gateway handles incoming messages from Telegram:

```bash
# Start the gateway service
openclaw gateway start

# Verify it's running  
openclaw gateway status
```

Expected output:
```
✅ OpenClaw Gateway Status
Status: Running (PID: 12345)
Uptime: 0h 2m 15s
Channels: telegram, cli
Active sessions: 0
Memory usage: 45.2 MB
```

If status shows "Stopped" or errors, check the troubleshooting section below.

### Step 4: Test Your Bot Connection

1. **Find your bot in Telegram**
   - Search for your bot username (e.g., `@jackson_ai_bot`)
   - Click on it to start a conversation
   - Click "START" button

2. **Send first message**
   - Type: `Hello! Are you working?`
   - Send the message

3. **Expected response**
   Within 5-30 seconds, your AI should respond with something like:
   ```
   Hello! Yes, I'm working perfectly. I'm your AI assistant running through 
   OpenClaw. I can help you with research, analysis, automation, and much more. 
   
   Try sending /status to see my capabilities or just ask me anything!
   ```

If you don't get a response, see the troubleshooting section.

### Why This Matters: Understanding Bot Architecture

When you message your Telegram bot, here's the technical flow:

```
[Your Phone] → [Telegram Servers] → [OpenClaw Gateway] → [AI Model] → [Response Path]
     ↑                                        ↓
[Response] ←  [Telegram Servers] ← [OpenClaw Gateway] ← [AI Processing]
```

**Key concepts:**

**Webhooks vs Polling:** OpenClaw uses webhooks by default - Telegram pushes messages to your gateway immediately. This is faster and more efficient than polling (repeatedly asking "any new messages?").

**Session Management:** Each Telegram user gets a unique session. Your conversations with the AI are separate from anyone else who might message your bot.

**Security:** Only users you approve can access your AI. By default, it's private to your Telegram account.

## Understanding Slash Commands

Slash commands are special messages that control your AI system rather than having normal conversations. They start with `/` and provide system-level functions.

### Essential Slash Commands

**`/status`** - System information
```
🤖 OpenClaw Status Report

Model: anthropic/claude-sonnet-3-5
Session: telegram-123456789 (active 2h 15m)
Workspace: ~/.openclaw/workspace
Memory files: 145 entries
Today's conversations: 23 messages
API costs today: $2.47
```

**`/model`** - Switch AI models
```
# See available models
/model list

# Switch to different model
/model anthropic/claude-opus-3
/model openai/gpt-4-turbo
```

**`/reasoning`** - Toggle detailed thinking
```
/reasoning on   # Show AI's step-by-step reasoning
/reasoning off  # Hide reasoning (default)
```

**`/memory`** - Memory operations
```
/memory search "stock analysis"  # Find past conversations about stocks
/memory clear session           # Clear current session context
/memory backup                  # Create memory backup
```

**`/help`** - Command reference
Shows all available commands with examples.

### Advanced Slash Commands

**`/cost`** - Usage and billing tracking
```
💰 API Cost Summary

Today: $3.47
This week: $18.32
This month: $67.89

Top expense: Model calls (78%)
Avg cost per conversation: $0.23
```

**`/export`** - Data export functions
```
/export chat                    # Export this conversation
/export memory                  # Export all memory files  
/export config                  # Export configuration (keys removed)
```

**`/session`** - Session management
```
/session new                    # Start fresh session (clear context)
/session save "market analysis" # Save session with name
/session load "market analysis" # Load saved session
```

### Why Slash Commands Matter

**System Control:** Direct access to AI configuration without command line
**Debugging:** Quick diagnostics when something isn't working right
**Cost Management:** Real-time visibility into API spending
**Power User Features:** Access advanced functionality through simple commands

Most users rely on slash commands for 80% of system management tasks.

## Your First Real Conversation

Let's have a conversation that demonstrates your AI's capabilities beyond simple question/answer:

### Conversation Example

**You:** `/status`

**AI:** 
```
🤖 OpenClaw Status Report

Model: anthropic/claude-sonnet-3-5
Session: telegram-987654321 (started 5m ago)
Workspace: ~/.openclaw/workspace  
Memory: Active, 3 files loaded
Gateway: Running, 2h uptime
API costs today: $1.23
```

**You:** `Can you help me research Tesla's recent earnings? I want to know if it's a good buy right now.`

**AI:**
```
I'll research Tesla's recent earnings for you. Let me gather the latest information.

📊 Tesla (TSLA) Research Summary

Recent Earnings (Q4 2023):
• Revenue: $96.8B (+3% YoY, beat estimates)  
• EPS: $2.27 (beat by $0.05)
• Vehicle deliveries: 1.81M (+35% YoY)
• Energy storage deployments: 14.7 GWh (record)

Key Positives:
✅ Cybertruck production ramping (11k delivered)
✅ Full Self Driving revenue up 20% QoQ  
✅ Supercharger network expansion (50,000+ stations)
✅ Cost reduction initiatives showing results

Key Concerns:
⚠️ Auto gross margin compressed to 16.9%
⚠️ Price cuts impacting profitability
⚠️ China competition intensifying (BYD, NIO)
⚠️ Regulatory scrutiny on FSD claims

Analyst Consensus:
• Price targets: $180-280 (currently $198)
• 12 Buy, 8 Hold, 2 Sell ratings
• Average target: $235 (+18% upside)

My Assessment: Cautiously optimistic. Strong fundamentals but valuation requires perfect execution. Consider dollar-cost averaging rather than large position.

Would you like me to set up alerts for TSLA price movements or earnings updates?
```

**You:** `Yes, set up alerts. Tell me if it drops below $180 or goes above $220.`

**AI:**
```
✅ Tesla (TSLA) Alerts Configured

I've set up price monitoring for:
• Below $180: Strong buy signal alert
• Above $220: Take profits consideration alert

I'll check prices every hour during market hours and send immediate notifications if these levels are hit.

Also monitoring:
• Earnings announcement dates
• Major analyst upgrades/downgrades  
• Significant news events

These alerts are now active and will persist across sessions. You can modify them anytime with "/alerts TSLA" or disable with "/alerts off TSLA".

Should I also monitor any other positions in your portfolio?
```

### What Just Happened

This conversation demonstrates several advanced capabilities:

1. **Real-time research** - AI searched multiple data sources
2. **Structured analysis** - Organized findings into actionable insights  
3. **Persistent monitoring** - Set up ongoing price alerts
4. **Context retention** - Remembered your interest in Tesla for future conversations
5. **Proactive suggestions** - Offered additional monitoring options

This is AI automation in action - not just answering questions, but taking ongoing responsibility for tasks you care about.

## Discord Setup: Backup Channel

Discord provides an alternative interface, especially useful for:
- Team collaboration (multiple users)
- Server-based access control
- Rich embed formatting
- Voice channel integration
- Bot commands in shared spaces

### Step 1: Create Discord Application

1. **Go to Discord Developer Portal**
   - Visit https://discord.com/developers/applications
   - Log in with your Discord account
   - Click "New Application"

2. **Configure Application**
   - Name: `My AI Assistant`
   - Description: `Personal AI automation system`
   - Click "Create"

3. **Create Bot User**
   - Go to "Bot" section in sidebar
   - Click "Add Bot"
   - Confirm: "Yes, do it!"

### Step 2: Configure Bot Permissions

1. **Bot Settings**
   - Username: Choose a name like `AIAssistant`
   - Check "Message Content Intent" (required for reading messages)
   - Uncheck "Public Bot" (keep it private)

2. **Generate Bot Token**
   - Click "Reset Token" 
   - Copy the token (starts with `MTk4...`)
   - Add to your `.env` file:
   ```bash
   DISCORD_BOT_TOKEN=MTk4NjIyNDgzNDcxMDI1NjY0.Gk7QdG.example_token_here
   ```

### Step 3: Invite Bot to Server

1. **Generate Invite Link**
   - Go to "OAuth2" → "URL Generator"
   - Scopes: Check "bot"
   - Bot Permissions: 
     - Send Messages
     - Read Message History  
     - Use Slash Commands
     - Attach Files
     - Embed Links

2. **Install Bot**
   - Copy generated URL
   - Open in browser
   - Select your Discord server
   - Click "Authorize"

### Step 4: Test Discord Connection

```bash
# Restart gateway to pick up Discord config
openclaw gateway restart

# Check status includes Discord
openclaw gateway status
```

In Discord:
- Type `@YourBotName hello`
- Should get same response as Telegram

## Session Management: Multiple Devices

Your AI maintains separate sessions for each interface:

**Session Types:**
- **`telegram-123456789`** - Your personal Telegram chat
- **`discord-987654321-456`** - Discord channel interactions
- **`cli-localhost`** - Command line interface
- **`web-session-abc123`** - Web interface (if configured)

### Why Separate Sessions Matter

**Privacy:** Your personal conversations don't leak into Discord servers
**Context:** Each session has appropriate context for its environment  
**Customization:** Different personalities/capabilities per channel
**Cost Control:** Different model routing per session type

### Session Persistence

Sessions automatically save:
- **Conversation history** (last 100 messages)
- **Context variables** (current projects, preferences)
- **Active monitoring tasks** (price alerts, scheduled reminders)
- **File references** (documents being worked on)

Sessions restore when you reconnect:
- Switch from phone to desktop → same context continues
- Gateway restart → all sessions restored from disk
- Network interruption → automatic reconnection with full context

## Message Routing: How It All Works

Understanding message routing helps you optimize performance and debug issues.

### The Complete Flow

```
1. Message Input
   ├── Telegram → webhook → gateway:8080/telegram
   ├── Discord → websocket → gateway process
   └── CLI → direct → gateway function

2. Session Resolution  
   ├── Load session context (last 50 messages)
   ├── Load workspace files (AGENTS.md, SOUL.md, etc.)
   └── Apply channel-specific formatting rules

3. AI Processing
   ├── Model selection (based on complexity/cost settings)
   ├── Prompt construction (system + context + message)  
   ├── API request with retry logic
   └── Response parsing and validation

4. Tool Execution (if requested)
   ├── File operations (read, write, search)
   ├── Web searches (Brave, Google)
   ├── API calls (stocks, weather, news)
   └── External integrations

5. Response Formatting
   ├── Channel-specific formatting (Telegram vs Discord)
   ├── File uploads (images, documents)
   └── Interactive elements (buttons, menus)

6. Response Delivery
   ├── Send via original channel
   ├── Log to daily memory file
   └── Update session context
```

### Performance Optimization

**Fast responses (< 3 seconds):**
- Use lightweight models for simple questions
- Minimize workspace file sizes  
- Cache frequently accessed data

**Rich responses (5-30 seconds):**
- Allow multiple tool calls for research
- Use premium models for complex reasoning
- Include comprehensive context from memory

### Cost Optimization

**Channel-based model routing:**
```bash
# In .env file
TELEGRAM_DEFAULT_MODEL=anthropic/claude-haiku-3    # Cheap for mobile  
DISCORD_DEFAULT_MODEL=anthropic/claude-sonnet-3-5  # Standard for groups
CLI_DEFAULT_MODEL=anthropic/claude-opus-3          # Premium for deep work
```

## Multi-Channel Configuration

Running multiple channels simultaneously requires careful resource management.

### Resource Allocation

**Gateway Memory Usage:**
- Base: 50MB
- +10MB per active Telegram session
- +15MB per Discord server connection
- +5MB per CLI session

**API Rate Limits:**
- Telegram: 30 messages/second
- Discord: 50 requests/second  
- AI providers: varies by plan

### Configuration Best Practices

**Environment Variables:**
```bash
# Channel priorities (1-10, higher = more resources)
TELEGRAM_PRIORITY=8
DISCORD_PRIORITY=6  
CLI_PRIORITY=10

# Response time targets (milliseconds)
TELEGRAM_TARGET_LATENCY=3000
DISCORD_TARGET_LATENCY=5000
CLI_TARGET_LATENCY=1000

# Concurrent processing limits
MAX_CONCURRENT_TELEGRAM=3
MAX_CONCURRENT_DISCORD=5
MAX_CONCURRENT_CLI=1
```

## Pro Tips: Communication Best Practices

💡 **Use Telegram for personal, Discord for collaboration.** Keep sensitive conversations in Telegram private chats. Use Discord for team projects where others need AI access.

💡 **Master slash commands early.** They're faster than natural language for system operations. `/status`, `/model`, and `/cost` will be your most-used commands.

💡 **Set up message templates for common requests.** Create shortcuts for frequent tasks like "daily briefing" or "portfolio update" to save typing.

💡 **Use session names for project organization.** `/session save "Q4 planning"` lets you switch contexts easily without losing important conversation history.

💡 **Configure different personalities per channel.** Make your AI more formal in Discord servers, casual in personal Telegram chats.

## Troubleshooting: Common Connection Issues

### Problem: Telegram bot doesn't respond

**Diagnosis steps:**
1. Check gateway status: `openclaw gateway status`
2. Check logs: `tail -f ~/.openclaw/gateway.log`
3. Verify token in `.env` file
4. Test network connectivity

**Common fixes:**
```bash
# Restart gateway
openclaw gateway restart

# Verify token format (should be numbers:letters)
grep TELEGRAM_BOT_TOKEN ~/.openclaw/.env

# Test webhook connectivity
curl -X GET "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/getMe"
```

### Problem: "Bot was blocked by user" error

**Diagnosis:** You blocked your own bot accidentally.
**Fix:**
1. In Telegram, search for your bot username
2. Click "RESTART" or "UNBLOCK"  
3. Send `/start` command
4. Try conversation again

### Problem: Discord bot shows offline

**Diagnosis:** Token expired or bot not properly invited.
**Fix:**
```bash
# Check Discord bot status
curl -X GET \
  -H "Authorization: Bot YOUR_DISCORD_TOKEN" \
  https://discord.com/api/v10/users/@me

# If error, regenerate token in Discord Developer Portal
# Update .env file with new token
# Restart gateway
```

### Problem: Messages delayed or out of order

**Diagnosis:** Network issues or rate limiting.
**Fix:**
- Check internet connection stability
- Reduce message frequency 
- Verify API rate limits aren't exceeded
- Consider upgrading to paid AI provider plan

### Problem: Different responses across channels

**Diagnosis:** Different session contexts or model configurations.
**Fix:**
```bash
# Check model settings per channel
openclaw config show | grep -i model

# Synchronize if needed
openclaw session sync telegram discord
```

## Try This: Channel Setup Verification

Work through this verification process to ensure your communication channels are bulletproof:

### ✅ Phase 1: Telegram Setup

- [ ] BotFather conversation completed successfully
- [ ] Bot token copied to `.env` file
- [ ] Bot responds to "hello" within 30 seconds
- [ ] `/status` command shows system information
- [ ] `/help` command lists available commands

### ✅ Phase 2: Advanced Telegram Features

- [ ] Slash commands work (`/model list`, `/cost`, `/memory`)
- [ ] File sharing works (send image, get analysis)
- [ ] Session persistence (restart phone app, context maintained)
- [ ] Error messages clear and actionable
- [ ] Response time acceptable for your usage

### ✅ Phase 3: Discord Setup (Optional)

- [ ] Discord application created
- [ ] Bot invited to server with correct permissions
- [ ] Bot shows online status
- [ ] Responds to @mentions
- [ ] Works in both DMs and channels

### ✅ Phase 4: Multi-Channel Testing

- [ ] Same AI memory accessible from both channels
- [ ] Different conversation contexts maintained
- [ ] No cross-channel information leakage
- [ ] Performance adequate with both channels active

### ✅ Phase 5: Advanced Features

- [ ] Session management commands work
- [ ] Cost tracking accurate
- [ ] Memory search finds past conversations
- [ ] Export functions generate correct files

If any verification fails, review the relevant setup section and troubleshooting guide.

## What's Next

Chapter 4 covers AI engine configuration - choosing the right models for different tasks, understanding costs, and building a model routing strategy that optimizes for both performance and budget.

You now have the communication infrastructure to access your AI anywhere. The next step is making sure you're using the most appropriate AI models for each type of request, which can dramatically impact both response quality and costs.

Before proceeding, ensure your communication channels are working reliably. The verification checklist above should all pass. If you're having intermittent connection issues, fix them now - they'll compound when you add more complexity in later chapters.

Your AI is now accessible 24/7 from any device with Telegram or Discord. That's the foundation for true AI automation.

---

*Next: Chapter 4 - Engine Configuration*