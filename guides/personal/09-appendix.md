# Appendix A: Troubleshooting & FAQ

---

## Common Issues

### "OpenClaw command not found"
**Cause:** npm global bin directory not in PATH
**Fix (Windows):** Close PowerShell and reopen. If still failing: `npm config get prefix` — add that path + `/bin` to your system PATH.
**Fix (macOS/Linux):** Run `export PATH="$(npm config get prefix)/bin:$PATH"` and add it to your `~/.bashrc` or `~/.zshrc`.

### "Gateway fails to start"
**Cause:** Port already in use or configuration error
**Fix:**
1. Check if another process uses the port: `netstat -an | findstr 18789` (Windows) or `lsof -i :18789` (macOS/Linux)
2. Change the port in `config.yaml`
3. Check logs: `openclaw gateway logs`

### "AI doesn't respond on Telegram"
**Cause:** Bot token incorrect, gateway not running, or sender not authorized
**Fix:**
1. Verify gateway is running: `openclaw status`
2. Check bot token in config.yaml matches BotFather's token exactly
3. Verify your Telegram user ID is in `allowedSenders`
4. Restart gateway: `openclaw gateway restart`

### "API returns errors"
**Cause:** Invalid key, expired key, or rate limit exceeded
**Fix:**
1. Verify the key in `.env` has no extra spaces or newlines
2. Test the key directly at the provider's website
3. Check if you've exceeded the free tier limits
4. Ensure the key has the required permissions/scopes

### "Memory files aren't being created"
**Cause:** Directory doesn't exist or permissions issue
**Fix:**
1. Create the directory: `mkdir -p ~/.openclaw/workspace/memory`
2. Check permissions: your user should own the workspace directory
3. Verify AGENTS.md has memory instructions

### "Cron jobs don't fire"
**Cause:** Gateway not running, timezone mismatch, or job disabled
**Fix:**
1. Verify gateway is running continuously
2. Check timezone in your cron expression matches your timezone
3. List jobs and verify they're enabled
4. Run the job manually to test

---

## Frequently Asked Questions

**Q: Can I run OpenClaw on a Raspberry Pi?**
A: Yes. OpenClaw runs anywhere Node.js runs. A Raspberry Pi 4 with 4GB RAM handles it well for personal use.

**Q: How much does it cost per month?**
A: Infrastructure is free. AI model costs depend on usage — typically $30-150/month for active personal use. With smart engine routing, you can keep it under $50/month easily.

**Q: Can I use multiple AI providers?**
A: Yes. OpenClaw supports switching between providers. Use OpenRouter for multi-provider access through a single key.

**Q: Is my data private?**
A: Your data stays on your machine. OpenClaw doesn't send data to any Erronatus servers. The only external communication is between your gateway and the AI providers you configure.

**Q: Can I use this for my business?**
A: The Personal Edition is licensed for personal use. For business use, upgrade to the Business Edition at erronatus.com.

**Q: What happens if my computer shuts down?**
A: The gateway stops, but your configuration and memory persist on disk. When you restart the gateway, everything resumes. For 24/7 uptime, consider running on a VPS (covered in the Business Edition).

---

# Appendix B: Glossary

| Term | Definition |
|------|-----------|
| **API** | Application Programming Interface — a way for software to communicate with external services |
| **API Key** | A secret string that authenticates your access to an API |
| **Cron Job** | A scheduled task that runs automatically at specified times |
| **Gateway** | OpenClaw's core process that routes messages and manages AI interactions |
| **LLM** | Large Language Model — the AI models that generate responses (GPT, Claude, etc.) |
| **Model** | A specific AI system trained to process language (e.g., Claude Sonnet, GPT-4o) |
| **OpenRouter** | A service that provides access to multiple AI models through a single API key |
| **Provider** | A company that offers AI models (Anthropic, OpenAI, Google, etc.) |
| **Session** | A single conversation thread between you and your AI |
| **Token** | The unit AI models use to measure text — roughly 4 characters per token |
| **Webhook** | An HTTP callback that notifies your system when an event occurs |
| **Workspace** | The directory where OpenClaw stores configuration, memory, and project files |

---

*End of Personal Edition*

*For the complete system — multi-engine routing, full API toolchain, trading bots, email automation, and more — upgrade to the Business Edition at erronatus.com.*
