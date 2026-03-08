#!/bin/bash
# Erronatus Enterprise — macOS/Linux Install Script
# Run: chmod +x install.sh && ./install.sh

set -e

echo ""
echo "⚡ ERRONATUS ENTERPRISE INSTALLER"
echo "   Setting up your AI automation system..."
echo ""

# Check Node.js
echo "[1/7] Checking Node.js..."
if ! command -v node &> /dev/null; then
    echo "  ❌ Node.js not found. Install from https://nodejs.org (v20+)"
    exit 1
fi
NODE_VERSION=$(node --version)
echo "  ✅ Node.js $NODE_VERSION"

# Install OpenClaw
echo "[2/7] Installing OpenClaw..."
npm install -g openclaw 2>/dev/null
OC_VERSION=$(openclaw --version 2>/dev/null || echo "")
if [ -z "$OC_VERSION" ]; then
    echo "  ❌ OpenClaw installation failed"
    exit 1
fi
echo "  ✅ OpenClaw $OC_VERSION"

# Create workspace structure
echo "[3/7] Creating workspace structure..."
WORKSPACE="$HOME/.openclaw/workspace"
mkdir -p "$WORKSPACE/memory/daily"
mkdir -p "$WORKSPACE/memory/tasks"
mkdir -p "$WORKSPACE/memory/credentials"
mkdir -p "$WORKSPACE/memory/projects"
mkdir -p "$WORKSPACE/scripts"
mkdir -p "$WORKSPACE/skills"
mkdir -p "$WORKSPACE/templates/emails"
mkdir -p "$WORKSPACE/templates/reports"
mkdir -p "$WORKSPACE/projects"
echo "  ✅ Directory structure created"

# Copy workspace template
echo "[4/7] Installing workspace template..."
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TEMPLATE_DIR="$(dirname "$SCRIPT_DIR")/workspace-template"

if [ -d "$TEMPLATE_DIR" ]; then
    cp -r "$TEMPLATE_DIR"/* "$WORKSPACE/" 2>/dev/null || true
    echo "  ✅ Template files installed"
else
    echo "  ⚠️ Template directory not found — copy files manually"
fi

# Copy API toolchain
echo "[5/7] Installing API toolchain..."
API_SCRIPT="$(dirname "$SCRIPT_DIR")/scripts/api-tools.js"
if [ -f "$API_SCRIPT" ]; then
    cp "$API_SCRIPT" "$WORKSPACE/scripts/api-tools.js"
    echo "  ✅ api-tools.js installed"
else
    echo "  ⚠️ api-tools.js not found — copy manually"
fi

# Create .env template
echo "[6/7] Creating .env template..."
ENV_PATH="$HOME/.openclaw/.env"
if [ ! -f "$ENV_PATH" ]; then
    cat > "$ENV_PATH" << 'EOF'
# ═══════════════════════════════════════════
# ERRONATUS ENTERPRISE — API KEYS
# Fill in your keys below. Never share this file.
# ═══════════════════════════════════════════

# --- AI Provider (Required) ---
OPENROUTER_API_KEY=sk-or-v1-your-key-here

# --- Search ---
BRAVE_SEARCH_KEY=your-brave-key

# --- Trading & Finance ---
ALPACA_API_KEY=your-paper-key
ALPACA_SECRET_KEY=your-paper-secret
ALPACA_BASE_URL=https://paper-api.alpaca.markets
ALPHA_VANTAGE_KEY=your-key

# --- Development & Deployment ---
GITHUB_TOKEN=github_pat_your-token
VERCEL_TOKEN=your-vercel-token
CLOUDFLARE_API_TOKEN=your-cf-token
CLOUDFLARE_ACCOUNT_ID=your-account-id

# --- Database ---
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key

# --- Email ---
RESEND_API_KEY=re_your-key
EMAIL_FROM=hello@yourdomain.com

# --- Payments ---
STRIPE_SECRET_KEY=sk_test_your-key
STRIPE_PUBLISHABLE_KEY=pk_test_your-key

# --- News ---
NEWSAPI_KEY=your-newsapi-key
EOF
    echo "  ✅ .env template created — fill in your API keys"
else
    echo "  ⚠️ .env already exists — skipping"
fi

# Initialize memory
echo "[7/7] Initializing memory system..."
TODAY=$(date +%Y-%m-%d)

DAILY_LOG="$WORKSPACE/memory/daily/$TODAY.md"
if [ ! -f "$DAILY_LOG" ]; then
    echo "# $TODAY

## System Installed
Erronatus Enterprise workspace initialized." > "$DAILY_LOG"
fi

ACTIVE_CTX="$WORKSPACE/memory/active-context.json"
if [ ! -f "$ACTIVE_CTX" ]; then
    cat > "$ACTIVE_CTX" << EOF
{
  "lastSession": {
    "date": "$TODAY",
    "summary": "Enterprise workspace initialized",
    "pendingFollowUp": ["Configure API keys in .env", "Set up Telegram bot", "Test API connections"]
  },
  "activeProjects": [],
  "dailyBudgetUsed": 0,
  "importantDates": []
}
EOF
fi

TASK_QUEUE="$WORKSPACE/memory/tasks/task-queue.json"
if [ ! -f "$TASK_QUEUE" ]; then
    cat > "$TASK_QUEUE" << 'EOF'
{
  "queue": [
    {"id": "setup-001", "priority": "high", "title": "Add API keys to .env", "status": "pending"},
    {"id": "setup-002", "priority": "high", "title": "Create Telegram bot via @BotFather", "status": "pending"},
    {"id": "setup-003", "priority": "medium", "title": "Configure OpenClaw gateway", "status": "pending"},
    {"id": "setup-004", "priority": "medium", "title": "Test all API connections", "status": "pending"},
    {"id": "setup-005", "priority": "low", "title": "Set up first cron job", "status": "pending"}
  ],
  "completed": []
}
EOF
fi

VAULT="$WORKSPACE/memory/credentials/vault.json"
if [ ! -f "$VAULT" ]; then
    echo '{"credentials":[],"totalCredentials":0,"lastFullAudit":null}' > "$VAULT"
fi

echo "  ✅ Memory system initialized"

echo ""
echo "═══════════════════════════════════════════"
echo "  ⚡ INSTALLATION COMPLETE"
echo "═══════════════════════════════════════════"
echo ""
echo "Next steps:"
echo "  1. Edit ~/.openclaw/.env — add your API keys"
echo "  2. Edit ~/.openclaw/workspace/USER.md — tell your AI about you"
echo "  3. Run: openclaw init — configure your gateway"
echo "  4. Run: openclaw gateway start — launch your AI"
echo "  5. Message your AI on Telegram and say hello!"
echo ""
echo "Documentation: erronatus.com/blog"
echo "Support: @erronatus on Telegram"
echo ""
