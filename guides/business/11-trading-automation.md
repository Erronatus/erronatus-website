# Chapter 11: Trading Automation
## Alpaca, RSI, and Paper Trading Bots

---

> ⚠️ **Disclaimer:** This chapter covers paper trading (simulated trades with fake money). Nothing in this guide constitutes financial advice. Trading real money involves significant risk of loss. Always paper trade extensively before considering live trading.

### Why AI + Trading

Traditional algorithmic trading uses rigid if-then rules. When market conditions change, rigid bots break.

AI-powered trading automation is different:
- **Contextualizes signals** with news, sector trends, and historical patterns
- **Adapts analysis** to current market conditions
- **Explains reasoning** in plain English before execution
- **Remembers** what worked and what didn't over weeks and months

You're not building a trading bot. You're building a trading *analyst* that never sleeps.

### Setting Up Alpaca Paper Trading

Alpaca provides free paper trading with the same API as live trading.

1. Go to alpaca.markets and create an account
2. Switch to "Paper Trading" in the dashboard
3. Go to API Keys → Generate New Key
4. Copy both the API Key ID and Secret Key

Add to `.env`:
```bash
ALPACA_API_KEY=your-paper-key
ALPACA_SECRET_KEY=your-paper-secret
ALPACA_BASE_URL=https://paper-api.alpaca.markets
```

**Verify the connection:**
```
You: Check my Alpaca paper trading account status
AI: Paper account active. Buying power: $100,000.00. No open positions.
```

### Building the Watchlist Monitor

Define 5-10 symbols you want to track:

```
You: Set up a watchlist monitor for AAPL, TSLA, NVDA, AMZN, GOOGL.
     Check RSI every 2 hours during market hours.
     Alert me only when RSI crosses above 70 or below 30.
```

Your AI creates a cron job:
- **Schedule:** Every 2 hours, 9 AM - 4 PM ET, weekdays
- **Task:** For each symbol: pull current price + RSI → analyze → alert if threshold crossed → log everything

### The Three-Tier Alert System

**🟢 Info (Logged, not sent)**
Regular scans with no signals. Written to daily memory for pattern analysis.
```
[Market Scan 10:00] AAPL RSI 52.3 (neutral) | TSLA RSI 61.8 (neutral) |
NVDA RSI 44.1 (neutral) | All clear.
```

**🟡 Watch (Telegram notification)**
A signal is developing. RSI approaching thresholds.
```
⚠️ NVDA RSI approaching oversold: 33.2 and falling.
50-day SMA support at $112. Watching for entry below 30.
```

**🔴 Action (Priority alert with recommendation)**
Signal confirmed with specific trade parameters.
```
🔴 NVDA RSI crossed below 30 (29.4)
📊 Analysis: Oversold on 5min RSI, price at 50-day SMA support ($112)
💡 Recommendation: Paper buy 45 shares at market (~$5,040)
🛑 Stop: $108 (-3.6%)
🎯 Target: $120 (+7.1%)
⚖️ Risk: $180 (0.18% of account)

Reply "execute" to place the paper trade.
```

### AI-Powered Position Sizing

Your AI calculates optimal position size for every trade:

```
Position Size = (Account Equity × Risk %) / (Entry Price - Stop Price)
```

But it adds judgment:
- **Sector concentration:** Already holding 3 tech stocks? Reduce size.
- **Volatility adjustment:** High ATR? Wider stop, smaller position.
- **Correlation check:** Correlated positions share risk — account for it.
- **Account heat:** Total portfolio risk shouldn't exceed 6%.

Example:
```
Account: $100,000
Risk per trade: 1% = $1,000
Entry: $112.00
Stop: $108.00
Stop distance: $4.00

Position size: $1,000 / $4.00 = 250 shares ($28,000)

Adjustments:
- Already holding GOOGL (+$15,000 tech exposure) → Reduce to 150 shares
- ATR elevated (1.5x normal) → Reduce to 120 shares
- Final: 120 shares × $112 = $13,440 (13.4% of account)
```

### Executing Paper Trades

When you confirm a trade:

```
You: Execute

AI: Placing paper trade...
    ✅ BUY 120 NVDA @ $112.03 (market order filled)
    📋 Order ID: abc123
    🛑 Stop-loss set: $108.00
    📊 Position: 120 shares, cost basis $13,443.60
    ⚖️ Portfolio risk: 2.3% (within limits)
    
    Monitoring for exit signals. Will alert at stop ($108) or target ($120).
```

### Performance Tracking

Every trade gets logged with full context:

```json
{
  "date": "2026-03-08",
  "symbol": "NVDA",
  "side": "buy",
  "shares": 120,
  "entry": 112.03,
  "stop": 108.00,
  "target": 120.00,
  "reasoning": "RSI oversold (29.4) at 50-day SMA support",
  "outcome": "pending"
}
```

After closing, your AI updates:
```json
{
  "exit": 118.50,
  "pnl": "+$776.40 (+5.8%)",
  "days_held": 4,
  "outcome": "win",
  "lesson": "RSI < 30 at major support = high probability bounce"
}
```

### Monthly Performance Report

Your AI generates automated performance analysis:

```
March 2026 Paper Trading Summary
─────────────────────────────────
Total trades: 23
Win rate: 61% (14W / 9L)
Average gain: +2.3%
Average loss: -1.1%
Profit factor: 1.88
Max drawdown: -4.2%

Best trade: NVDA +8.7% (RSI < 30 bounce)
Worst trade: AMZN -3.2% (earnings miss override)

Pattern Analysis:
• RSI < 30 at support: 78% win rate (7/9)
• RSI > 70 shorts: 42% win rate (3/7) — underperforming
• Recommendation: Increase allocation to oversold bounces,
  reduce or eliminate overbought short signals.
```

### Risk Management Automation

Configure automated risk rules:

1. **Max position size:** 5% of account per trade
2. **Max portfolio heat:** 6% total open risk
3. **Sector concentration:** No more than 40% in one sector
4. **Daily loss limit:** -3% → suspend new entries, alert
5. **Trailing stops:** Move stops to breakeven after +2% gain

These rules execute automatically. Your AI doesn't get emotional after losses or greedy after wins. It follows the system.

### What You've Built

✅ Paper trading bot with Alpaca integration
✅ RSI-based watchlist monitoring on cron
✅ Three-tier alert system (Info/Watch/Action)
✅ AI-powered position sizing with risk adjustments
✅ Automated trade execution via Telegram command
✅ Performance logging and monthly analysis
✅ Risk management automation with hard limits

---

*Next Chapter: Advanced Memory Systems →*
