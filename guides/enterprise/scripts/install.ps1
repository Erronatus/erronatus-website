# Erronatus Enterprise — Windows Install Script
# Run in PowerShell: .\install.ps1

Write-Host ""
Write-Host "⚡ ERRONATUS ENTERPRISE INSTALLER" -ForegroundColor Cyan
Write-Host "   Setting up your AI automation system..." -ForegroundColor Gray
Write-Host ""

# Check Node.js
Write-Host "[1/7] Checking Node.js..." -ForegroundColor Yellow
$nodeVersion = node --version 2>$null
if (-not $nodeVersion) {
    Write-Host "  ❌ Node.js not found. Install from https://nodejs.org (v20+)" -ForegroundColor Red
    exit 1
}
Write-Host "  ✅ Node.js $nodeVersion" -ForegroundColor Green

# Install OpenClaw
Write-Host "[2/7] Installing OpenClaw..." -ForegroundColor Yellow
npm install -g openclaw 2>$null
$ocVersion = openclaw --version 2>$null
if (-not $ocVersion) {
    Write-Host "  ❌ OpenClaw installation failed" -ForegroundColor Red
    exit 1
}
Write-Host "  ✅ OpenClaw $ocVersion" -ForegroundColor Green

# Create workspace directory structure
Write-Host "[3/7] Creating workspace structure..." -ForegroundColor Yellow
$workspace = "$HOME\.openclaw\workspace"
$dirs = @(
    "$workspace\memory",
    "$workspace\memory\daily",
    "$workspace\memory\tasks",
    "$workspace\memory\credentials",
    "$workspace\memory\projects",
    "$workspace\scripts",
    "$workspace\skills",
    "$workspace\templates\emails",
    "$workspace\templates\reports",
    "$workspace\projects"
)
foreach ($dir in $dirs) {
    New-Item -ItemType Directory -Force -Path $dir | Out-Null
}
Write-Host "  ✅ Directory structure created" -ForegroundColor Green

# Copy workspace template files
Write-Host "[4/7] Installing workspace template..." -ForegroundColor Yellow
$templateDir = Split-Path -Parent $PSScriptRoot
$templatePath = Join-Path $templateDir "workspace-template"

if (Test-Path $templatePath) {
    Copy-Item "$templatePath\*" -Destination $workspace -Force -Recurse
    Write-Host "  ✅ Template files installed" -ForegroundColor Green
} else {
    Write-Host "  ⚠️ Template directory not found — copy files manually" -ForegroundColor Yellow
}

# Copy API toolchain script
Write-Host "[5/7] Installing API toolchain..." -ForegroundColor Yellow
$scriptSrc = Join-Path $templateDir "scripts\api-tools.js"
if (Test-Path $scriptSrc) {
    Copy-Item $scriptSrc -Destination "$workspace\scripts\api-tools.js" -Force
    Write-Host "  ✅ api-tools.js installed" -ForegroundColor Green
} else {
    Write-Host "  ⚠️ api-tools.js not found — copy manually" -ForegroundColor Yellow
}

# Create .env template
Write-Host "[6/7] Creating .env template..." -ForegroundColor Yellow
$envPath = "$HOME\.openclaw\.env"
if (-not (Test-Path $envPath)) {
    $envTemplate = @"
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
"@
    Set-Content -Path $envPath -Value $envTemplate
    Write-Host "  ✅ .env template created — fill in your API keys" -ForegroundColor Green
} else {
    Write-Host "  ⚠️ .env already exists — skipping" -ForegroundColor Yellow
}

# Create initial memory files
Write-Host "[7/7] Initializing memory system..." -ForegroundColor Yellow
$today = Get-Date -Format "yyyy-MM-dd"
$dailyLog = "$workspace\memory\daily\$today.md"
if (-not (Test-Path $dailyLog)) {
    Set-Content -Path $dailyLog -Value "# $today`n`n## System Installed`nErronatus Enterprise workspace initialized."
}

$activeContext = "$workspace\memory\active-context.json"
if (-not (Test-Path $activeContext)) {
    $ctx = @"
{
  "lastSession": {
    "date": "$today",
    "summary": "Enterprise workspace initialized",
    "pendingFollowUp": ["Configure API keys in .env", "Set up Telegram bot", "Test API connections"]
  },
  "activeProjects": [],
  "dailyBudgetUsed": 0,
  "importantDates": []
}
"@
    Set-Content -Path $activeContext -Value $ctx
}

$taskQueue = "$workspace\memory\tasks\task-queue.json"
if (-not (Test-Path $taskQueue)) {
    $tq = @"
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
"@
    Set-Content -Path $taskQueue -Value $tq
}

$vault = "$workspace\memory\credentials\vault.json"
if (-not (Test-Path $vault)) {
    Set-Content -Path $vault -Value '{"credentials":[],"totalCredentials":0,"lastFullAudit":null}'
}

Write-Host "  ✅ Memory system initialized" -ForegroundColor Green

Write-Host ""
Write-Host "═══════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  ⚡ INSTALLATION COMPLETE" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor White
Write-Host "  1. Edit ~/.openclaw/.env — add your API keys" -ForegroundColor Gray
Write-Host "  2. Edit ~/.openclaw/workspace/USER.md — tell your AI about you" -ForegroundColor Gray
Write-Host "  3. Run: openclaw init — configure your gateway" -ForegroundColor Gray
Write-Host "  4. Run: openclaw gateway start — launch your AI" -ForegroundColor Gray
Write-Host "  5. Message your AI on Telegram and say hello!" -ForegroundColor Gray
Write-Host ""
Write-Host "Documentation: erronatus.com/blog" -ForegroundColor DarkGray
Write-Host "Support: @erronatus on Telegram" -ForegroundColor DarkGray
Write-Host ""
