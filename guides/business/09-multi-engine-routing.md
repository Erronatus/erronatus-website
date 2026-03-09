# Chapter 9: Multi-Engine Routing
## Stop Burning Money on Overkill Models

*Every time you use Claude Opus to parse a CSV file, you're essentially paying a brain surgeon to flip burgers. This chapter shows you how to route tasks intelligently across four model tiers, cutting your AI costs by 60-80% while maintaining — or even improving — performance.*

### Why This Matters

By the time you finish the Personal Edition, you're probably running $200-500/month in AI costs. Scale that to business operations, and you're looking at $2,000-10,000/month or more. The difference between smart routing and wasteful single-model usage isn't just money — it's the difference between sustainable growth and bleeding cash on infrastructure.

Most businesses fail at AI not because the technology doesn't work, but because they can't afford to keep it running. Multi-engine routing solves this by matching task complexity to model capability and cost.

## The Four-Tier System

### Tier 1: Free (Gemini Flash 1.5)
**Cost:** $0
**Speed:** 2-3 seconds
**Context:** 1M tokens

**Excellent for:**
- Data parsing and transformation
- Simple summarization
- Format conversion (JSON, CSV, XML)
- Basic text extraction
- Routine monitoring tasks
- Weather/status checks
- Log analysis

**Terrible for:**
- Complex reasoning
- Creative writing
- Nuanced decision-making
- Multi-step problem solving
- Code debugging

**Example optimal tasks:**
```bash
# Perfect for Gemini Flash
"Parse this CSV and return JSON"
"Extract email addresses from this text"
"What's the weather like tomorrow?"
"Check if this log contains errors"

# Don't waste it on:
"Write a comprehensive business plan"
"Debug this complex authentication flow"
"Design a microservices architecture"
```

### Tier 2: Budget (DeepSeek V3)
**Cost:** $0.14/$0.28 per 1M tokens (input/output)
**Speed:** 3-5 seconds  
**Context:** 128K tokens

**Excellent for:**
- Code review and refactoring
- Technical documentation
- System administration tasks
- Data analysis with interpretation
- Workflow automation
- API integration planning

**Limitations:**
- Inconsistent with very recent information
- Occasional logic gaps in complex chains
- Can be verbose when conciseness matters

**ROI Sweet Spot:**
DeepSeek V3 handles about 70% of development tasks at 1/10th the cost of premium models. Use it for the "thinking work" that's too complex for Gemini but doesn't need Opus-level reasoning.

### Tier 3: Standard (Claude Sonnet 3.5)
**Cost:** $3/$15 per 1M tokens
**Speed:** 4-8 seconds
**Context:** 200K tokens

**Excellent for:**
- Strategic planning
- Complex code architecture
- Business analysis
- Content creation
- Multi-step problem solving
- Research synthesis
- Customer communication

**This is your workhorse.** Sonnet 3.5 handles 80% of complex business tasks while staying cost-effective. Use it when you need reliable reasoning but don't need the absolute bleeding-edge performance.

### Tier 4: Premium (Claude Opus or GPT-4o)
**Cost:** $15/$75 per 1M tokens  
**Speed:** 8-15 seconds
**Context:** 200K tokens

**Reserve for:**
- Critical business decisions
- Complex system design
- High-stakes customer interactions
- Financial modeling
- Legal/compliance review
- Breakthrough problem-solving

**The 5% Rule:** Opus should handle less than 5% of your total requests. If it's higher, you're either not routing properly or you're solving problems too complex for automation.

## Configuring Multi-Engine Routing

### OpenClaw Configuration

Add this to your `~/.openclaw/config.json`:

```json
{
  "models": {
    "free": {
      "provider": "google",
      "model": "gemini-1.5-flash-latest",
      "apiKey": "env:GOOGLE_API_KEY",
      "maxTokens": 4096,
      "temperature": 0.3,
      "rateLimit": {
        "rpm": 15,
        "tpm": 1000000
      }
    },
    "budget": {
      "provider": "deepseek",
      "model": "deepseek-reasoner",
      "apiKey": "env:DEEPSEEK_API_KEY",
      "maxTokens": 8192,
      "temperature": 0.1,
      "rateLimit": {
        "rpm": 30,
        "tpm": 1000000
      }
    },
    "standard": {
      "provider": "anthropic",
      "model": "claude-3-5-sonnet-20241022",
      "apiKey": "env:ANTHROPIC_API_KEY",
      "maxTokens": 8192,
      "temperature": 0.1,
      "rateLimit": {
        "rpm": 50,
        "tpm": 40000
      }
    },
    "premium": {
      "provider": "anthropic", 
      "model": "claude-3-opus-20240229",
      "apiKey": "env:ANTHROPIC_API_KEY",
      "maxTokens": 8192,
      "temperature": 0.1,
      "rateLimit": {
        "rpm": 30,
        "tpm": 10000
      }
    }
  },
  "routing": {
    "defaultTier": "standard",
    "taskClassification": {
      "simple": ["parse", "extract", "format", "status", "weather", "basic"],
      "budget": ["code", "debug", "refactor", "analyze", "integrate"],
      "standard": ["plan", "design", "research", "write", "communicate"],
      "premium": ["critical", "financial", "legal", "complex", "breakthrough"]
    },
    "budgetLimits": {
      "daily": {
        "free": -1,
        "budget": 50.00,
        "standard": 200.00,
        "premium": 100.00
      },
      "warningThresholds": {
        "budget": 40.00,
        "standard": 160.00,
        "premium": 80.00
      }
    },
    "fallbackChain": ["premium", "standard", "budget", "free"]
  }
}
```

### Environment Setup

Add these to your `.env`:

```bash
# Model API Keys
GOOGLE_API_KEY=your_gemini_key_here
DEEPSEEK_API_KEY=your_deepseek_key_here  
ANTHROPIC_API_KEY=your_anthropic_key_here
OPENAI_API_KEY=your_openai_key_here

# Budget tracking
DAILY_BUDGET_LIMIT=350.00
MONTHLY_BUDGET_LIMIT=8000.00
BUDGET_ALERT_EMAIL=your-email@domain.com
```

## Budget Management System

### Daily Limits and Warnings

Create `~/.openclaw/workspace/scripts/budget-monitor.js`:

```javascript
#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

class BudgetMonitor {
    constructor() {
        this.budgetFile = path.join(process.env.HOME, '.openclaw/budget-tracking.json');
        this.config = this.loadConfig();
    }

    loadConfig() {
        const configPath = path.join(process.env.HOME, '.openclaw/config.json');
        return JSON.parse(fs.readFileSync(configPath, 'utf8'));
    }

    getCurrentUsage() {
        if (!fs.existsSync(this.budgetFile)) {
            return this.resetDailyUsage();
        }

        const budget = JSON.parse(fs.readFileSync(this.budgetFile, 'utf8'));
        const today = new Date().toISOString().split('T')[0];

        if (budget.date !== today) {
            return this.resetDailyUsage();
        }

        return budget;
    }

    resetDailyUsage() {
        const today = new Date().toISOString().split('T')[0];
        const initialBudget = {
            date: today,
            usage: {
                free: 0,
                budget: 0,
                standard: 0,
                premium: 0
            },
            requests: {
                free: 0,
                budget: 0,
                standard: 0,
                premium: 0
            },
            totalCost: 0
        };

        fs.writeFileSync(this.budgetFile, JSON.stringify(initialBudget, null, 2));
        return initialBudget;
    }

    recordUsage(tier, cost, inputTokens, outputTokens) {
        const budget = this.getCurrentUsage();
        
        budget.usage[tier] += cost;
        budget.requests[tier] += 1;
        budget.totalCost += cost;

        // Store token usage for analysis
        if (!budget.tokens) budget.tokens = {};
        if (!budget.tokens[tier]) budget.tokens[tier] = { input: 0, output: 0 };
        
        budget.tokens[tier].input += inputTokens;
        budget.tokens[tier].output += outputTokens;

        fs.writeFileSync(this.budgetFile, JSON.stringify(budget, null, 2));

        // Check if we're approaching limits
        this.checkWarnings(budget);
        
        return budget;
    }

    checkWarnings(budget) {
        const limits = this.config.routing.budgetLimits.daily;
        const warnings = this.config.routing.budgetLimits.warningThresholds;

        Object.keys(warnings).forEach(tier => {
            if (budget.usage[tier] >= warnings[tier]) {
                console.log(`⚠️  WARNING: ${tier} tier at $${budget.usage[tier].toFixed(2)} (${(budget.usage[tier]/limits[tier]*100).toFixed(1)}% of daily limit)`);
            }

            if (budget.usage[tier] >= limits[tier]) {
                console.log(`🚨 LIMIT REACHED: ${tier} tier at daily limit of $${limits[tier]}`);
                // Trigger fallback to lower tier
                this.triggerFallback(tier);
            }
        });
    }

    triggerFallback(exhaustedTier) {
        const fallbackChain = this.config.routing.fallbackChain;
        const fallbackIndex = fallbackChain.indexOf(exhaustedTier) + 1;
        
        if (fallbackIndex < fallbackChain.length) {
            const nextTier = fallbackChain[fallbackIndex];
            console.log(`📉 Falling back from ${exhaustedTier} to ${nextTier}`);
            return nextTier;
        }

        console.log('🔒 All tiers exhausted - operations restricted');
        return null;
    }

    getDailyReport() {
        const budget = this.getCurrentUsage();
        
        console.log('\n📊 Daily Usage Report');
        console.log('━━━━━━━━━━━━━━━━━━━━━━');
        
        Object.keys(budget.usage).forEach(tier => {
            const cost = budget.usage[tier];
            const requests = budget.requests[tier];
            const avgCost = requests > 0 ? cost / requests : 0;
            
            console.log(`${tier.padEnd(10)} $${cost.toFixed(2).padStart(8)} (${requests.toString().padStart(3)} requests, $${avgCost.toFixed(3)} avg)`);
        });
        
        console.log('━━━━━━━━━━━━━━━━━━━━━━');
        console.log(`Total:     $${budget.totalCost.toFixed(2).padStart(8)}`);
        
        return budget;
    }
}

// CLI usage
if (require.main === module) {
    const monitor = new BudgetMonitor();
    
    const command = process.argv[2];
    
    switch (command) {
        case 'report':
            monitor.getDailyReport();
            break;
        case 'reset':
            monitor.resetDailyUsage();
            console.log('✅ Daily budget reset');
            break;
        case 'record':
            const tier = process.argv[3];
            const cost = parseFloat(process.argv[4]);
            const inputTokens = parseInt(process.argv[5]) || 0;
            const outputTokens = parseInt(process.argv[6]) || 0;
            monitor.recordUsage(tier, cost, inputTokens, outputTokens);
            break;
        default:
            console.log('Usage: budget-monitor.js [report|reset|record <tier> <cost> <input_tokens> <output_tokens>]');
    }
}

module.exports = BudgetMonitor;
```

Make it executable:
```bash
chmod +x ~/.openclaw/workspace/scripts/budget-monitor.js
```

## The /model Command

Add dynamic model switching to your OpenClaw sessions:

```javascript
// Add to ~/.openclaw/workspace/commands/model.js
const BudgetMonitor = require('../scripts/budget-monitor.js');

async function modelCommand(args, context) {
    const monitor = new BudgetMonitor();
    const availableTiers = ['free', 'budget', 'standard', 'premium'];
    
    if (args.length === 0) {
        // Show current model and usage
        console.log(`Current model: ${context.currentTier || 'standard'}`);
        monitor.getDailyReport();
        return;
    }

    const requestedTier = args[0].toLowerCase();
    
    if (!availableTiers.includes(requestedTier)) {
        console.log(`❌ Invalid tier. Available: ${availableTiers.join(', ')}`);
        return;
    }

    // Check if tier is within budget
    const budget = monitor.getCurrentUsage();
    const limits = monitor.config.routing.budgetLimits.daily;
    
    if (budget.usage[requestedTier] >= limits[requestedTier] && limits[requestedTier] !== -1) {
        console.log(`🚫 ${requestedTier} tier has reached daily limit of $${limits[requestedTier]}`);
        const fallback = monitor.triggerFallback(requestedTier);
        if (fallback) {
            context.currentTier = fallback;
            console.log(`Switched to ${fallback} tier instead`);
        }
        return;
    }

    context.currentTier = requestedTier;
    console.log(`✅ Switched to ${requestedTier} tier`);
    
    // Show tier capabilities
    const tierInfo = {
        free: 'Fast parsing, extraction, simple tasks',
        budget: 'Code review, analysis, documentation',  
        standard: 'Planning, complex reasoning, business tasks',
        premium: 'Critical decisions, complex architecture, breakthrough problems'
    };
    
    console.log(`💡 Best for: ${tierInfo[requestedTier]}`);
}

module.exports = { modelCommand };
```

## Real Cost Comparison

### Before Multi-Engine Routing
**Single Model Usage (Claude Sonnet 3.5 for everything):**

```
Daily Tasks:
- 50 simple parsing tasks: $150 (should be $0)
- 30 code review tasks: $90 (could be $4.20)
- 15 complex reasoning: $45 (appropriate)
- 5 critical decisions: $15 (should be premium)

Daily Total: $300
Monthly Total: $9,000
```

### After Multi-Engine Routing
**Intelligent Tier Distribution:**

```
Daily Tasks:
- 50 simple tasks (Free): $0
- 30 code reviews (Budget): $4.20
- 15 complex reasoning (Standard): $45
- 5 critical decisions (Premium): $37.50

Daily Total: $86.70
Monthly Total: $2,601

Savings: $6,399/month (71% reduction)
```

## Task Classification Intelligence

### Automatic Routing Rules

Create `~/.openclaw/workspace/scripts/task-classifier.js`:

```javascript
class TaskClassifier {
    constructor() {
        this.patterns = {
            free: {
                keywords: ['parse', 'extract', 'format', 'convert', 'weather', 'status', 'list', 'find', 'search'],
                complexity: 1,
                reasoning: false,
                creativity: false
            },
            budget: {
                keywords: ['code', 'debug', 'refactor', 'analyze', 'review', 'test', 'integrate'],
                complexity: 2,
                reasoning: true,
                creativity: false
            },
            standard: {
                keywords: ['plan', 'design', 'strategy', 'write', 'create', 'explain', 'research'],
                complexity: 3,
                reasoning: true,
                creativity: true
            },
            premium: {
                keywords: ['critical', 'decision', 'financial', 'legal', 'architecture', 'complex', 'breakthrough'],
                complexity: 4,
                reasoning: true,
                creativity: true
            }
        };
    }

    classifyTask(prompt, context = {}) {
        const text = prompt.toLowerCase();
        let scores = { free: 0, budget: 0, standard: 0, premium: 0 };

        // Keyword matching
        Object.keys(this.patterns).forEach(tier => {
            const pattern = this.patterns[tier];
            pattern.keywords.forEach(keyword => {
                if (text.includes(keyword)) {
                    scores[tier] += 2;
                }
            });
        });

        // Length-based complexity
        const wordCount = prompt.split(' ').length;
        if (wordCount < 20) scores.free += 1;
        else if (wordCount < 100) scores.budget += 1;
        else if (wordCount < 300) scores.standard += 1;
        else scores.premium += 1;

        // Context clues
        if (text.includes('$') || text.includes('money') || text.includes('cost')) scores.premium += 2;
        if (text.includes('urgent') || text.includes('critical')) scores.premium += 3;
        if (text.includes('simple') || text.includes('quick')) scores.free += 2;

        // File type analysis
        if (context.fileTypes) {
            if (context.fileTypes.includes('.csv') || context.fileTypes.includes('.json')) scores.free += 2;
            if (context.fileTypes.includes('.js') || context.fileTypes.includes('.py')) scores.budget += 2;
        }

        // Return highest scoring tier
        const maxScore = Math.max(...Object.values(scores));
        const recommendedTier = Object.keys(scores).find(tier => scores[tier] === maxScore);

        return {
            tier: recommendedTier,
            confidence: maxScore / 10,
            scores: scores,
            reasoning: this.explainClassification(recommendedTier, scores)
        };
    }

    explainClassification(tier, scores) {
        const explanations = {
            free: 'Simple data processing or information retrieval task',
            budget: 'Technical task requiring analysis but not complex reasoning',
            standard: 'Complex task requiring planning, creativity, or multi-step reasoning',
            premium: 'Critical business decision or breakthrough problem-solving required'
        };

        return explanations[tier];
    }
}

module.exports = TaskClassifier;
```

## Custom Routing Workflows

### Workflow-Specific Routing

Create routing profiles for different business processes:

```json
{
  "workflowRouting": {
    "customer-support": {
      "initial-classification": "budget",
      "escalation-rules": {
        "refund-request": "premium",
        "technical-issue": "standard", 
        "general-inquiry": "budget"
      },
      "fallback": "standard"
    },
    "content-creation": {
      "research-phase": "standard",
      "writing-phase": "standard",
      "editing-phase": "budget",
      "fact-checking": "free"
    },
    "data-processing": {
      "extraction": "free",
      "analysis": "budget", 
      "insights": "standard",
      "recommendations": "premium"
    },
    "development": {
      "planning": "standard",
      "coding": "budget",
      "debugging": "budget",
      "architecture-review": "premium"
    }
  }
}
```

## Monthly Optimization Review

### Cost Analysis Script

```bash
#!/bin/bash
# ~/.openclaw/workspace/scripts/monthly-review.sh

echo "🔍 OpenClaw Monthly Cost Analysis"
echo "================================="

# Calculate monthly totals
month=$(date +%Y-%m)
budget_dir="$HOME/.openclaw/budget-history"
mkdir -p "$budget_dir"

# Aggregate daily usage files
total_free=0
total_budget=0
total_standard=0
total_premium=0

for file in ~/.openclaw/budget-tracking-*.json; do
    if [[ $file == *"$month"* ]]; then
        free=$(jq -r '.usage.free' "$file")
        budget=$(jq -r '.usage.budget' "$file")
        standard=$(jq -r '.usage.standard' "$file")
        premium=$(jq -r '.usage.premium' "$file")
        
        total_free=$(echo "$total_free + $free" | bc)
        total_budget=$(echo "$total_budget + $budget" | bc)
        total_standard=$(echo "$total_standard + $standard" | bc)
        total_premium=$(echo "$total_premium + $premium" | bc)
    fi
done

total_cost=$(echo "$total_free + $total_budget + $total_standard + $total_premium" | bc)

echo "Monthly Breakdown:"
echo "  Free (Gemini):    \$$total_free"
echo "  Budget (DeepSeek): \$$total_budget"
echo "  Standard (Sonnet): \$$total_standard"  
echo "  Premium (Opus):    \$$total_premium"
echo "  ─────────────────────"
echo "  Total:            \$$total_cost"

# Calculate efficiency metrics
if (( $(echo "$total_cost > 0" | bc -l) )); then
    free_pct=$(echo "scale=1; $total_free / $total_cost * 100" | bc)
    budget_pct=$(echo "scale=1; $total_budget / $total_cost * 100" | bc)
    standard_pct=$(echo "scale=1; $total_standard / $total_cost * 100" | bc)
    premium_pct=$(echo "scale=1; $total_premium / $total_cost * 100" | bc)
    
    echo ""
    echo "Cost Distribution:"
    echo "  Free: ${free_pct}%"
    echo "  Budget: ${budget_pct}%"
    echo "  Standard: ${standard_pct}%"
    echo "  Premium: ${premium_pct}%"
    
    # Optimization recommendations
    echo ""
    echo "💡 Optimization Opportunities:"
    
    if (( $(echo "$premium_pct > 15" | bc -l) )); then
        echo "  ⚠️  Premium usage at ${premium_pct}% - review if all tasks need Opus"
    fi
    
    if (( $(echo "$free_pct < 30" | bc -l) )); then
        echo "  💰 Only ${free_pct}% free tier usage - identify more tasks for Gemini"
    fi
    
    if (( $(echo "$budget_pct < 20" | bc -l) )); then
        echo "  🔧 Low budget tier usage - DeepSeek could handle more coding tasks"
    fi
fi

# Save monthly report
echo "{\"month\": \"$month\", \"costs\": {\"free\": $total_free, \"budget\": $total_budget, \"standard\": $total_standard, \"premium\": $total_premium}, \"total\": $total_cost}" > "$budget_dir/monthly-$month.json"
```

## Advanced Provider Configuration

### OpenRouter Integration

For access to even more models and competitive pricing:

```json
{
  "openrouter": {
    "provider": "openrouter",
    "apiKey": "env:OPENROUTER_API_KEY",
    "baseUrl": "https://openrouter.ai/api/v1",
    "models": {
      "ultra-budget": {
        "model": "meta-llama/llama-3.1-8b-instruct:free",
        "cost": 0
      },
      "smart-budget": {
        "model": "microsoft/wizardlm-2-8x22b", 
        "costPer1M": [0.63, 0.63]
      },
      "reasoning": {
        "model": "deepseek/deepseek-r1-distill-llama-70b",
        "costPer1M": [0.14, 0.28]
      }
    }
  },
  "fallbackProviders": ["openrouter", "anthropic", "openai"]
}
```

### Model Aliases

Create convenient shortcuts:

```json
{
  "aliases": {
    "parse": "free",
    "code": "budget", 
    "think": "standard",
    "decide": "premium",
    "write": "standard",
    "debug": "budget",
    "plan": "standard"
  }
}
```

Usage:
```bash
/model parse    # Switch to free tier
/model code     # Switch to budget tier  
/model decide   # Switch to premium tier
```

## Pro Tips

**🎯 The 80/20 Rule:** 80% of your tasks should run on budget tier or lower. If more than 20% needs standard/premium, your task classification needs work.

**⚡ Speed vs Cost:** Free tier (Gemini) is often faster than premium models. Use it for time-sensitive simple tasks.

**🔄 Fallback Testing:** Regularly test your fallback chains. Set artificial limits and verify degradation is graceful.

**📊 Usage Patterns:** Review your monthly reports. Seasonal patterns in usage can help you negotiate better rates with providers.

**🚫 Anti-Pattern Alert:** Never route based on request volume alone. A thousand simple parsing tasks should stay on free tier, not escalate to premium.

## Troubleshooting

### Issue 1: High Premium Tier Usage
**Symptoms:** Premium tier consistently >15% of daily cost
**Diagnosis:** Check task classification keywords
**Fix:**
```bash
# Review recent premium tasks
grep -r "tier.*premium" ~/.openclaw/logs/ | tail -20

# Look for misclassified simple tasks  
grep -r "parse\|extract\|format" ~/.openclaw/logs/ | grep "premium"
```

### Issue 2: Models Not Switching
**Symptoms:** /model command works but requests still go to default tier
**Diagnosis:** Context not persisting between requests
**Fix:**
```javascript
// Ensure context persistence in your session manager
function saveContext(context) {
    const contextFile = path.join(process.env.HOME, '.openclaw/session-context.json');
    fs.writeFileSync(contextFile, JSON.stringify(context, null, 2));
}
```

### Issue 3: Budget Limits Not Enforcing
**Symptoms:** Usage exceeds daily limits without fallback
**Diagnosis:** Budget monitor not integrated with request flow
**Fix:**
```javascript
// Add budget check to all model requests
async function checkBudgetBeforeRequest(tier, estimatedCost) {
    const monitor = new BudgetMonitor();
    const budget = monitor.getCurrentUsage();
    const limit = monitor.config.routing.budgetLimits.daily[tier];
    
    if (budget.usage[tier] + estimatedCost > limit && limit !== -1) {
        return monitor.triggerFallback(tier);
    }
    
    return tier;
}
```

### Issue 4: Slow Response Times
**Symptoms:** Requests taking >15 seconds consistently
**Diagnosis:** Premium model overuse or provider issues
**Fix:**
```bash
# Check model response times by tier
node -e "
const logs = require('fs').readFileSync('~/.openclaw/response-times.log', 'utf8');
const times = logs.split('\n').map(line => JSON.parse(line));
times.forEach(t => console.log(\`\${t.tier}: \${t.responseTime}ms\`));
"
```

### Issue 5: Classification Accuracy Issues  
**Symptoms:** Wrong tier selection for obvious task types
**Diagnosis:** Classification patterns need tuning
**Fix:**
```javascript
// Add manual classification override
function forceClassify(prompt, forcedTier) {
    return {
        tier: forcedTier,
        confidence: 1.0,
        manual: true,
        reasoning: `Manually classified as ${forcedTier}`
    };
}

// Usage
if (prompt.includes('CRITICAL:')) {
    return forceClassify(prompt, 'premium');
}
```

Multi-engine routing is the difference between sustainable AI operations and burning money. Master this system, and you'll cut costs by 60-80% while maintaining performance. Ignore it, and you'll price yourself out of the AI automation game.

The businesses that win with AI aren't the ones with the biggest budgets — they're the ones with the smartest routing.