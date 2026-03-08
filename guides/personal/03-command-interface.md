# Chapter 3: Your Command Interface
## Telegram & Discord Setup

---

### Why a Messaging Channel Matters

Your AI gateway is running. Your models are connected. But right now, interacting with it requires sitting at your computer and using the command line.

A messaging channel changes everything:
- **Message your AI from your phone** while walking, commuting, or lying in bed
- **Receive proactive alerts** when your AI detects something important
- **Get scheduled reports** delivered to your pocket automatically
- **Voice messages** — speak your requests instead of typing them
- **Rich formatting** — code blocks, images, files, inline buttons

We support both Telegram and Discord. Pick whichever you prefer. This chapter covers both.

---

## Option A: Telegram Setup

Telegram is our recommended channel. It's fast, supports rich formatting, works on every platform, and the bot API is excellent.

### Step 1: Create Your Bot

1. Open Telegram and search for `@BotFather`
2. Send `/newbot`
3. Choose a display name (e.g., "My AI Assistant")
4. Choose a username (must end in `bot`, e.g., `myai_automation_bot`)
5. BotFather will give you an API token — **copy it immediately**

The token looks like: `7123456789:AAH1234567890abcdefghijklmnop`

> ⚠️ **Security:** This token controls your bot. Never share it publicly, commit it to git, or post it anywhere.

### Step 2: Configure the Bot

Send these commands to @BotFather to customize your bot:

```
/setdescription - Set a description for your bot
/setabouttext - Set the about text
/setuserpic - Upload a profile picture
/setcommands - Set the command menu
```

For the command menu, send:
```
status - Check system status
new - Start a new session
reset - Reset conversation context
```

### Step 3: Connect to OpenClaw

Add your Telegram bot token to the OpenClaw configuration:

```bash
openclaw gateway config
```

Navigate to the Telegram channel section and enter your bot token. Or edit `config.yaml` directly:

```yaml
channels:
  telegram:
    token: "7123456789:AAH1234567890abcdefghijklmnop"
```

### Step 4: Start Talking

Restart the gateway to apply changes:

```bash
openclaw gateway restart
```

Open Telegram, find your bot, and send a message:

```
Hello! What can you do?
```

Your AI should respond within seconds. If it does — congratulations. You now have a personal AI assistant in your pocket.

### Step 5: Secure Your Bot

By default, anyone who finds your bot can message it. Lock it down:

In your `config.yaml`, add authorized senders:

```yaml
channels:
  telegram:
    token: "your-token"
    allowedSenders:
      - 123456789    # Your Telegram user ID
```

To find your Telegram user ID:
1. Message @userinfobot on Telegram
2. It will reply with your numeric ID
3. Add that number to `allowedSenders`

Now only you can interact with your AI.

---

## Option B: Discord Setup

Discord is ideal if you're already in Discord communities or want your AI in a server with other people.

### Step 1: Create a Discord Application

1. Go to discord.com/developers/applications
2. Click "New Application" → name it → Create
3. Go to the "Bot" section in the left sidebar
4. Click "Add Bot" → Confirm
5. Under the bot's token section, click "Reset Token" → Copy it

### Step 2: Configure Bot Permissions

In the "Bot" section:
- Enable "Message Content Intent" (required for reading messages)
- Enable "Server Members Intent" if you want member info

In the "OAuth2" → "URL Generator" section:
- Select scopes: `bot`, `applications.commands`
- Select permissions: `Send Messages`, `Read Message History`, `Embed Links`, `Attach Files`, `Add Reactions`
- Copy the generated URL and open it to invite the bot to your server

### Step 3: Connect to OpenClaw

Edit your `config.yaml`:

```yaml
channels:
  discord:
    token: "your-discord-bot-token"
    allowedGuilds:
      - "your-server-id"    # Right-click server → Copy ID
```

### Step 4: Start and Test

```bash
openclaw gateway restart
```

Go to your Discord server and message the bot or mention it:

```
@YourBot What's the weather today?
```

---

## Testing Your Setup

Regardless of which channel you chose, run through these tests:

### Test 1: Basic Response
Send: "What is 2 + 2?"
Expected: A clear answer (probably with some personality based on your SOUL.md)

### Test 2: Memory Check
Send: "My favorite color is blue. Remember that."
Then send: "What's my favorite color?"
Expected: It should remember "blue" within the same session

### Test 3: Tool Usage
Send: "Search the web for today's top tech news"
Expected: Your AI searches the web and returns results

### Test 4: File Access
Send: "Read my SOUL.md file and tell me what it says"
Expected: It reads the file from your workspace and summarizes it

### Test 5: Status Check
Send: "/status"
Expected: A status card showing model, tokens used, session info

If all five tests pass, your command interface is fully operational.

## What's Possible Now

With a messaging channel connected, you can:

📱 **Message from anywhere** — Phone, tablet, desktop, web browser
🔔 **Receive alerts** — Your AI can proactively send you messages
📎 **Share files** — Send documents, images, or data for your AI to process
🎤 **Voice messages** — Speak your requests (Telegram supports this natively)
🔘 **Inline buttons** — Your AI can present clickable options
📊 **Rich formatting** — Code blocks, bold, italic, links, and more

This is your command and control channel. Everything we build from here — APIs, memory, automation — feeds through this interface.

---

*Next Chapter: Engine Configuration — Choosing Your AI Models →*
