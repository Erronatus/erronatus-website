---
title: "Automated Trading with AI: Building a Paper Trading Bot That Monitors Markets 24/7"
excerpt: "How to build an AI-powered trading monitor using OpenClaw, Alpaca, and Alpha Vantage. Paper trading, RSI alerts, and automated position analysis."
date: "2026-03-04"
category: "Trading Bots"
readTime: "14 min read"
author: "Erronatus"
image: "/images/blog-trading.png"
featured: false
tags: ["trading", "alpaca", "automation", "finance"]
seoTitle: "Automated Trading with AI — Build a Paper Trading Bot in 2026"
seoDescription: "Build an AI-powered paper trading bot with OpenClaw and Alpaca. RSI monitoring, automated alerts, position sizing, and 24/7 market surveillance."
---

Let's be clear upfront: this is not financial advice. This is a technical guide about building automated monitoring and paper trading systems. We're trading with fake money on Alpaca's paper trading API. What you do with live capital is your decision and your risk.

With that said — the system we're building is real, the architecture is production-grade, and the principles apply whether you're paper trading or managing a real portfolio.

## Why AI + Trading Automation

Traditional algorithmic trading requires you to be a programmer who also understands quantitative finance. You write rigid rules in Python, backtest against historical data, and deploy bots that execute predetermined strategies. When market conditions change, your bot doesn't adapt — it breaks.

AI-powered trading automation is different. Instead of rigid if-then rules, you have an intelligent agent that:

- **Monitors multiple indicators** across your entire watchlist
- **Contextualizes signals** with news, sector trends, and historical patterns
- **Adapts analysis** based on market conditions (volatile vs. ranging vs. trending)
- **Explains its reasoning** in plain English before you execute
- **Remembers** what worked and what didn't across weeks and months

You're not replacing human judgment. You're augmenting it with a system that never sleeps, never forgets, and processes data faster than you can refresh a chart.

## The Architecture

Our system has four components:

1. **Alpaca Paper Trading API** — Execute trades, check positions, monitor account status
2. **Alpha Vantage API** — Technical indicators (RSI, MACD, moving averages)
3. **OpenClaw AI Agent** — The brain that analyzes data and makes recommendations
4. **Cron Scheduler** — Automated monitoring on a fixed schedule

Data flows like this: Cron triggers AI agent → Agent calls Alpha Vantage for indicators → Agent calls Alpaca for current positions → Agent analyzes everything → Agent sends alert or executes paper trade → Agent logs results to memory.

## Setting Up Alpaca Paper Trading

Alpaca offers free paper trading with the same API as their live platform. Sign up at alpaca.markets and grab your paper trading API keys.

Your `.env` file needs:

```
ALPACA_API_KEY=your_paper_key_here
ALPACA_SECRET_KEY=your_paper_secret_here
```

Note: These should be **paper trading** keys, not live keys. Alpaca provides separate credentials for each.

The API toolchain script wraps Alpaca into a simple function:

```javascript
const price = await alpaca_get_price('AAPL');
// Returns: { symbol: 'AAPL', price: 178.52, timestamp: '...' }
```

Your AI can check prices, view positions, place orders, and monitor account status through clean function calls instead of raw HTTP.

## Configuring Technical Indicators

Alpha Vantage provides technical indicators through a REST API. We're primarily using:

- **RSI (Relative Strength Index)** — Overbought/oversold detection
- **MACD** — Trend direction and momentum
- **SMA/EMA** — Moving averages for trend confirmation

RSI is our primary signal. The classic interpretation:
- RSI > 70: Potentially overbought → Consider selling or avoiding new long positions
- RSI < 30: Potentially oversold → Consider buying opportunity
- RSI 30-70: Neutral zone → Hold or watch for directional breakout

The toolchain function:

```javascript
const rsi = await alphavantage_rsi('AAPL');
// Returns latest RSI value plus full time series
```

Your AI doesn't just check the raw number. It contextualizes: "AAPL RSI at 72.3, crossed above 70 two hours ago, with declining volume. Previous time RSI hit 72 this quarter, the stock pulled back 3.2% over 5 days."

That's the difference between an alert system and an AI analyst.

## Building the Watchlist Monitor

Define your watchlist — the symbols your AI actively monitors. Start with 5-10 that you actually care about. More isn't better if you can't act on the signals.

Create a cron job that runs every 2 hours during market hours:

**Schedule**: `0 */2 9-16 * * 1-5` (every 2 hours, 9 AM - 4 PM, weekdays)

**Task**: For each symbol in the watchlist, pull current price, RSI, and any open positions. Analyze the data. If any signal crosses a threshold, send an immediate alert via Telegram. Log everything to the daily memory file.

The AI's analysis includes:
- Current RSI value and direction (rising, falling, flat)
- Price relative to 20-day and 50-day moving averages
- Any existing position size and P&L
- Recent news that might affect the symbol
- A plain-English assessment: "Watchlist scan complete. AAPL RSI trending overbought (71.2↑). TSLA neutral (48.7). NVDA approaching oversold territory (33.1↓) — worth watching for entry."

This runs automatically. You get a Telegram message only when something needs attention.

## Position Sizing with AI

One of the most underrated advantages of AI in trading is dynamic position sizing. Instead of fixed lot sizes, your AI calculates optimal position size based on:

- **Account equity** — Current paper trading balance
- **Risk per trade** — Percentage of account you're willing to risk (typically 1-2%)
- **Stop-loss distance** — How far the stop is from entry price
- **Correlation** — Whether you already have exposure to the same sector
- **Volatility** — Current ATR (Average True Range) of the symbol

The formula is straightforward:

```
Position Size = (Account Equity × Risk %) / (Entry Price - Stop Price)
```

But the AI adds judgment. If you already hold three tech stocks and AAPL triggers, it might recommend half the calculated size due to sector concentration. If volatility is elevated, it might widen the stop and reduce size accordingly.

This is where AI beats rigid algorithms. It applies quantitative rules with qualitative context.

## Building the Alert System

Alerts should be actionable, not noisy. Configure three tiers:

**🟢 Info (logged, not sent)**
Regular watchlist scans with no signals. Written to daily memory for pattern tracking. You can review these anytime but they don't interrupt your day.

**🟡 Watch (sent via Telegram)**
A signal is developing. RSI approaching 70 or 30. Price testing a key level. Something to be aware of but not yet actionable.

**🔴 Action (sent with priority)**
Signal confirmed. RSI crossed threshold. Price broke support/resistance. Your AI includes a specific recommendation: "NVDA RSI crossed below 30 (29.4). 50-day SMA support at $112. Recommend paper buy: 45 shares at market ($5,040) with stop at $108. Risk: $180 (1.2% of account)."

You reply "execute" and the trade is placed. Or you reply "pass" and the AI logs your decision for future reference. Either way, the analysis is preserved in memory.

## Logging and Performance Tracking

Every trade, every alert, every decision gets logged. Your AI maintains:

- **Trade log**: Entry/exit prices, P&L, reasoning, outcome
- **Signal log**: Every RSI crossing, every alert sent, whether you acted on it
- **Performance metrics**: Win rate, average gain/loss, risk-adjusted returns
- **Lessons learned**: Patterns the AI identifies over time

After a month of paper trading, your AI can generate a performance report:

"March 2026 Paper Trading Summary: 23 trades executed. Win rate: 61%. Average gain: +2.3%. Average loss: -1.1%. Best trade: NVDA +8.7% (held 5 days, entered on RSI < 30 signal). Worst trade: AMZN -3.2% (RSI signal was contradicted by earnings miss). Observation: RSI < 30 signals on tech stocks with positive sector momentum had an 78% success rate. RSI > 70 short signals underperformed."

That's not just data. That's institutional-quality analysis running on a $10/month infrastructure.

## Risk Management Automation

The most important automation isn't entry signals — it's risk management. Configure your AI to:

1. **Enforce maximum position sizes** — Never allocate more than 5% of account to a single trade
2. **Monitor portfolio heat** — Total open risk across all positions shouldn't exceed 6%
3. **Track correlation** — Alert if sector concentration exceeds 40%
4. **Automate stop management** — Trail stops as positions move in your favor
5. **Circuit breaker** — If daily P&L drops below -3%, suspend all new entries and alert you

These rules run continuously. Your AI doesn't get emotional after a loss and double down. It doesn't get greedy after a win and oversize the next trade. It follows the system.

## Going Live (When You're Ready)

Paper trading is practice. When your system has a track record you trust, transitioning to live trading is a configuration change — swap paper API keys for live ones.

But before you do:

- **Paper trade for at least 3 months** with consistent profitability
- **Verify position sizing** handles real slippage and fees
- **Start small** — 10% of the capital you plan to eventually deploy
- **Keep all safety automation running** — Stops, circuit breakers, risk limits
- **Monitor actively for the first month** — Trust but verify

The beauty of this architecture is that everything else stays the same. Same analysis, same alerts, same risk management. The only change is real money at stake.

## The Compound Advantage

Every day your AI monitors markets, it gets better. Not through model training — through accumulated context. It remembers which signals worked. It remembers your risk preferences. It remembers that AAPL tends to bounce off certain RSI levels in this market regime.

A human trader forgets. They get emotional. They deviate from the system after a loss. An AI with persistent memory and strict risk rules doesn't. It just executes, logs, and learns.

Start with paper trading. Build confidence in the system. Let the data show you what works. Then, when you're ready, let it run.

The market never sleeps. Neither should your analysis.
