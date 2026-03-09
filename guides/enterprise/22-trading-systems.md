# Chapter 22: Trading Systems

*Systematic Market Participation Through Automation*

**⚠️ CRITICAL DISCLAIMER: This chapter is for educational purposes only. All trading examples use paper trading accounts with virtual money. Real trading involves substantial risk of loss. Never trade with money you cannot afford to lose. This is not financial advice. Past performance does not guarantee future results. Consult a qualified financial advisor before making investment decisions.**

Trading systems represent automation at its most demanding—where precision, timing, and risk management can mean the difference between profit and significant loss. This chapter builds complete paper trading systems using real market data and production-grade risk controls.

Every system in this chapter uses paper trading only. We'll build the infrastructure for systematic market analysis, but you must make your own decisions about real money.

## Advanced Technical Analysis Setup

### Multi-Indicator Confluence System

```javascript
// Complete technical analysis engine with multiple indicators
class TechnicalAnalysisEngine {
    constructor(alpacaApiKey, alpacaSecret, paperTrading = true) {
        this.alpaca = new AlpacaApi({
            key: alpacaApiKey,
            secret: alpacaSecret,
            paper: paperTrading, // ALWAYS true for this guide
            baseUrl: paperTrading ? 'https://paper-api.alpaca.markets' : 'https://api.alpaca.markets'
        });
        
        this.indicators = new Map();
        this.confluenceThresholds = {
            strong_buy: 0.75,    // 75%+ indicators bullish
            buy: 0.60,           // 60%+ indicators bullish
            neutral: 0.40,       // 40-60% mixed signals
            sell: 0.40,          // 40%+ indicators bearish
            strong_sell: 0.25    // 25%+ indicators bearish
        };
    }
    
    async analyzeSymbol(symbol, timeframe = '1Day', period = 50) {
        try {
            // Get historical price data
            const bars = await this.alpaca.getBarsV2(symbol, {
                timeframe: timeframe,
                limit: period + 50, // Extra data for indicators
                asof: new Date().toISOString()
            });
            
            const priceData = this.formatPriceData(bars);
            
            // Calculate all technical indicators
            const analysis = {
                symbol: symbol,
                timestamp: new Date().toISOString(),
                currentPrice: priceData[priceData.length - 1].close,
                indicators: {},
                signals: {},
                confluenceScore: 0,
                overallSignal: 'NEUTRAL'
            };
            
            // RSI Analysis
            analysis.indicators.rsi = this.calculateRSI(priceData);
            analysis.signals.rsi = this.interpretRSI(analysis.indicators.rsi);
            
            // MACD Analysis  
            analysis.indicators.macd = this.calculateMACD(priceData);
            analysis.signals.macd = this.interpretMACD(analysis.indicators.macd);
            
            // Moving Averages
            analysis.indicators.movingAverages = this.calculateMovingAverages(priceData);
            analysis.signals.movingAverages = this.interpretMovingAverages(
                analysis.indicators.movingAverages, 
                analysis.currentPrice
            );
            
            // Bollinger Bands
            analysis.indicators.bollingerBands = this.calculateBollingerBands(priceData);
            analysis.signals.bollingerBands = this.interpretBollingerBands(
                analysis.indicators.bollingerBands,
                analysis.currentPrice
            );
            
            // Volume Analysis
            analysis.indicators.volume = this.analyzeVolume(priceData);
            analysis.signals.volume = this.interpretVolume(analysis.indicators.volume);
            
            // Support and Resistance
            analysis.indicators.supportResistance = this.findSupportResistance(priceData);
            analysis.signals.supportResistance = this.interpretSupportResistance(
                analysis.indicators.supportResistance,
                analysis.currentPrice
            );
            
            // Calculate confluence score
            analysis.confluenceScore = this.calculateConfluenceScore(analysis.signals);
            analysis.overallSignal = this.determineOverallSignal(analysis.confluenceScore);
            
            // Risk assessment
            analysis.riskAssessment = this.assessRisk(analysis);
            
            return analysis;
            
        } catch (error) {
            console.error(`Error analyzing ${symbol}:`, error.message);
            throw error;
        }
    }
    
    formatPriceData(bars) {
        return Array.from(bars).map(bar => ({
            timestamp: bar.Timestamp,
            open: parseFloat(bar.OpenPrice),
            high: parseFloat(bar.HighPrice),
            low: parseFloat(bar.LowPrice),
            close: parseFloat(bar.ClosePrice),
            volume: parseInt(bar.Volume)
        }));
    }
    
    calculateRSI(priceData, period = 14) {
        const gains = [];
        const losses = [];
        
        // Calculate price changes
        for (let i = 1; i < priceData.length; i++) {
            const change = priceData[i].close - priceData[i - 1].close;
            gains.push(Math.max(change, 0));
            losses.push(Math.abs(Math.min(change, 0)));
        }
        
        // Calculate average gains and losses
        let avgGain = gains.slice(0, period).reduce((a, b) => a + b, 0) / period;
        let avgLoss = losses.slice(0, period).reduce((a, b) => a + b, 0) / period;
        
        const rsiValues = [100 - (100 / (1 + avgGain / avgLoss))];
        
        // Calculate RSI for remaining periods using Wilder's smoothing
        for (let i = period; i < gains.length; i++) {
            avgGain = ((avgGain * (period - 1)) + gains[i]) / period;
            avgLoss = ((avgLoss * (period - 1)) + losses[i]) / period;
            
            const rs = avgGain / avgLoss;
            rsiValues.push(100 - (100 / (1 + rs)));
        }
        
        return {
            current: rsiValues[rsiValues.length - 1],
            previous: rsiValues[rsiValues.length - 2],
            values: rsiValues,
            period: period
        };
    }
    
    interpretRSI(rsi) {
        const current = rsi.current;
        const previous = rsi.previous;
        
        let signal = 'NEUTRAL';
        let strength = 0;
        let reasoning = '';
        
        if (current > 70) {
            signal = 'SELL';
            strength = Math.min((current - 70) / 20, 1); // 0-1 scale
            reasoning = `RSI ${current.toFixed(2)} indicates overbought conditions`;
        } else if (current < 30) {
            signal = 'BUY';
            strength = Math.min((30 - current) / 20, 1);
            reasoning = `RSI ${current.toFixed(2)} indicates oversold conditions`;
        } else if (current > 50 && current > previous) {
            signal = 'BUY';
            strength = 0.3;
            reasoning = `RSI ${current.toFixed(2)} showing bullish momentum`;
        } else if (current < 50 && current < previous) {
            signal = 'SELL';
            strength = 0.3;
            reasoning = `RSI ${current.toFixed(2)} showing bearish momentum`;
        } else {
            reasoning = `RSI ${current.toFixed(2)} in neutral zone`;
        }
        
        return { signal, strength, reasoning, current, previous };
    }
    
    calculateMACD(priceData, fastPeriod = 12, slowPeriod = 26, signalPeriod = 9) {
        const prices = priceData.map(d => d.close);
        
        // Calculate EMAs
        const fastEMA = this.calculateEMA(prices, fastPeriod);
        const slowEMA = this.calculateEMA(prices, slowPeriod);
        
        // Calculate MACD line
        const macdLine = fastEMA.map((fast, i) => fast - slowEMA[i]);
        
        // Calculate signal line (EMA of MACD)
        const signalLine = this.calculateEMA(macdLine, signalPeriod);
        
        // Calculate histogram
        const histogram = macdLine.map((macd, i) => macd - signalLine[i]);
        
        return {
            macd: macdLine[macdLine.length - 1],
            signal: signalLine[signalLine.length - 1],
            histogram: histogram[histogram.length - 1],
            previousHistogram: histogram[histogram.length - 2],
            values: {
                macd: macdLine,
                signal: signalLine,
                histogram: histogram
            }
        };
    }
    
    calculateEMA(prices, period) {
        const multiplier = 2 / (period + 1);
        const emaValues = [prices[0]];
        
        for (let i = 1; i < prices.length; i++) {
            const ema = (prices[i] * multiplier) + (emaValues[i - 1] * (1 - multiplier));
            emaValues.push(ema);
        }
        
        return emaValues;
    }
    
    interpretMACD(macd) {
        let signal = 'NEUTRAL';
        let strength = 0;
        let reasoning = '';
        
        // MACD line vs Signal line
        if (macd.macd > macd.signal) {
            if (macd.histogram > macd.previousHistogram) {
                signal = 'BUY';
                strength = 0.7;
                reasoning = 'MACD above signal line with increasing histogram (bullish)';
            } else {
                signal = 'BUY';
                strength = 0.4;
                reasoning = 'MACD above signal line but histogram decreasing';
            }
        } else {
            if (macd.histogram < macd.previousHistogram) {
                signal = 'SELL';
                strength = 0.7;
                reasoning = 'MACD below signal line with decreasing histogram (bearish)';
            } else {
                signal = 'SELL';
                strength = 0.4;
                reasoning = 'MACD below signal line but histogram increasing';
            }
        }
        
        // Zero line crossovers add strength
        if (macd.macd > 0 && signal === 'BUY') {
            strength = Math.min(strength + 0.2, 1.0);
            reasoning += ' with bullish zero-line cross';
        } else if (macd.macd < 0 && signal === 'SELL') {
            strength = Math.min(strength + 0.2, 1.0);
            reasoning += ' with bearish zero-line cross';
        }
        
        return { signal, strength, reasoning, macd: macd.macd, signal: macd.signal, histogram: macd.histogram };
    }
    
    calculateMovingAverages(priceData) {
        const closes = priceData.map(d => d.close);
        
        return {
            sma20: this.calculateSMA(closes, 20),
            sma50: this.calculateSMA(closes, 50),
            ema12: this.calculateEMA(closes, 12),
            ema26: this.calculateEMA(closes, 26)
        };
    }
    
    calculateSMA(prices, period) {
        const smaValues = [];
        
        for (let i = period - 1; i < prices.length; i++) {
            const sum = prices.slice(i - period + 1, i + 1).reduce((a, b) => a + b, 0);
            smaValues.push(sum / period);
        }
        
        return smaValues;
    }
    
    interpretMovingAverages(mas, currentPrice) {
        const sma20 = mas.sma20[mas.sma20.length - 1];
        const sma50 = mas.sma50[mas.sma50.length - 1];
        const ema12 = mas.ema12[mas.ema12.length - 1];
        const ema26 = mas.ema26[mas.ema26.length - 1];
        
        let bullishCount = 0;
        let bearishCount = 0;
        let totalWeight = 0;
        
        // Price vs EMAs
        if (currentPrice > ema12) { bullishCount += 0.8; totalWeight += 0.8; }
        else { bearishCount += 0.8; totalWeight += 0.8; }
        
        if (currentPrice > ema26) { bullishCount += 0.7; totalWeight += 0.7; }
        else { bearishCount += 0.7; totalWeight += 0.7; }
        
        // Price vs SMAs
        if (currentPrice > sma20) { bullishCount += 0.6; totalWeight += 0.6; }
        else { bearishCount += 0.6; totalWeight += 0.6; }
        
        if (currentPrice > sma50) { bullishCount += 1.0; totalWeight += 1.0; }
        else { bearishCount += 1.0; totalWeight += 1.0; }
        
        // EMA alignment
        if (ema12 > ema26) { bullishCount += 0.5; totalWeight += 0.5; }
        else { bearishCount += 0.5; totalWeight += 0.5; }
        
        // SMA alignment
        if (sma20 > sma50) { bullishCount += 0.5; totalWeight += 0.5; }
        else { bearishCount += 0.5; totalWeight += 0.5; }
        
        const bullishRatio = bullishCount / totalWeight;
        
        let signal, strength, reasoning;
        
        if (bullishRatio > 0.7) {
            signal = 'BUY';
            strength = bullishRatio;
            reasoning = `Strong bullish MA alignment (${(bullishRatio * 100).toFixed(1)}% bullish signals)`;
        } else if (bullishRatio < 0.3) {
            signal = 'SELL';
            strength = 1 - bullishRatio;
            reasoning = `Strong bearish MA alignment (${((1 - bullishRatio) * 100).toFixed(1)}% bearish signals)`;
        } else {
            signal = 'NEUTRAL';
            strength = 0;
            reasoning = `Mixed moving average signals (${(bullishRatio * 100).toFixed(1)}% bullish)`;
        }
        
        return {
            signal,
            strength,
            reasoning,
            values: { sma20, sma50, ema12, ema26 },
            bullishRatio
        };
    }
    
    calculateBollingerBands(priceData, period = 20, stdDev = 2) {
        const closes = priceData.map(d => d.close);
        const sma = this.calculateSMA(closes, period);
        
        const bands = [];
        
        for (let i = period - 1; i < closes.length; i++) {
            const slice = closes.slice(i - period + 1, i + 1);
            const mean = sma[i - period + 1];
            
            // Calculate standard deviation
            const variance = slice.reduce((sum, price) => sum + Math.pow(price - mean, 2), 0) / period;
            const standardDeviation = Math.sqrt(variance);
            
            bands.push({
                upper: mean + (standardDeviation * stdDev),
                middle: mean,
                lower: mean - (standardDeviation * stdDev),
                bandwidth: (standardDeviation * stdDev * 2) / mean
            });
        }
        
        return bands[bands.length - 1];
    }
    
    interpretBollingerBands(bands, currentPrice) {
        const { upper, middle, lower, bandwidth } = bands;
        const position = (currentPrice - lower) / (upper - lower);
        
        let signal, strength, reasoning;
        
        if (position > 0.8) {
            signal = 'SELL';
            strength = (position - 0.8) / 0.2;
            reasoning = `Price near upper Bollinger Band (${(position * 100).toFixed(1)}% of band range)`;
        } else if (position < 0.2) {
            signal = 'BUY';
            strength = (0.2 - position) / 0.2;
            reasoning = `Price near lower Bollinger Band (${(position * 100).toFixed(1)}% of band range)`;
        } else {
            signal = 'NEUTRAL';
            strength = 0;
            reasoning = `Price in middle of Bollinger Bands (${(position * 100).toFixed(1)}% of range)`;
        }
        
        // Adjust strength based on bandwidth (volatility)
        if (bandwidth < 0.1) { // Low volatility
            strength *= 1.2; // Breakouts from low volatility are more significant
        } else if (bandwidth > 0.3) { // High volatility
            strength *= 0.8; // Signals less reliable in high volatility
        }
        
        return {
            signal,
            strength: Math.min(strength, 1.0),
            reasoning,
            position,
            bandwidth,
            values: bands
        };
    }
    
    analyzeVolume(priceData, period = 20) {
        const volumes = priceData.map(d => d.volume);
        const avgVolume = volumes.slice(-period).reduce((a, b) => a + b, 0) / period;
        const currentVolume = volumes[volumes.length - 1];
        const volumeRatio = currentVolume / avgVolume;
        
        // Price-Volume relationship
        const priceChange = priceData[priceData.length - 1].close - priceData[priceData.length - 2].close;
        const priceChangePercent = (priceChange / priceData[priceData.length - 2].close) * 100;
        
        return {
            current: currentVolume,
            average: avgVolume,
            ratio: volumeRatio,
            priceChange: priceChangePercent,
            onBalanceVolume: this.calculateOBV(priceData)
        };
    }
    
    calculateOBV(priceData) {
        let obv = 0;
        const obvValues = [0];
        
        for (let i = 1; i < priceData.length; i++) {
            const currentClose = priceData[i].close;
            const previousClose = priceData[i - 1].close;
            const volume = priceData[i].volume;
            
            if (currentClose > previousClose) {
                obv += volume;
            } else if (currentClose < previousClose) {
                obv -= volume;
            }
            // No change in OBV if price unchanged
            
            obvValues.push(obv);
        }
        
        return {
            current: obvValues[obvValues.length - 1],
            previous: obvValues[obvValues.length - 2],
            trend: obvValues[obvValues.length - 1] > obvValues[obvValues.length - 2] ? 'UP' : 'DOWN'
        };
    }
    
    interpretVolume(volumeAnalysis) {
        const { ratio, priceChange, onBalanceVolume } = volumeAnalysis;
        
        let signal = 'NEUTRAL';
        let strength = 0;
        let reasoning = '';
        
        // High volume with price movement
        if (ratio > 1.5) {
            if (priceChange > 0.5) {
                signal = 'BUY';
                strength = Math.min(ratio - 1, 2) / 2;
                reasoning = `High volume (${ratio.toFixed(1)}x avg) supporting price increase`;
            } else if (priceChange < -0.5) {
                signal = 'SELL';
                strength = Math.min(ratio - 1, 2) / 2;
                reasoning = `High volume (${ratio.toFixed(1)}x avg) supporting price decrease`;
            } else {
                reasoning = `High volume (${ratio.toFixed(1)}x avg) with little price movement`;
            }
        } else if (ratio < 0.5) {
            strength = 0.2; // Low confidence in any signal
            reasoning = `Low volume (${ratio.toFixed(1)}x avg) - signals less reliable`;
        }
        
        // OBV confirmation
        if (onBalanceVolume.trend === 'UP' && priceChange > 0) {
            strength = Math.min(strength + 0.3, 1.0);
            reasoning += ' with OBV confirmation';
        } else if (onBalanceVolume.trend === 'DOWN' && priceChange < 0) {
            strength = Math.min(strength + 0.3, 1.0);
            reasoning += ' with OBV confirmation';
        }
        
        return { signal, strength, reasoning, ratio, obv: onBalanceVolume };
    }
    
    findSupportResistance(priceData, period = 20) {
        const highs = [];
        const lows = [];
        
        // Find local highs and lows
        for (let i = period; i < priceData.length - period; i++) {
            const currentHigh = priceData[i].high;
            const currentLow = priceData[i].low;
            
            // Check if current high is a local maximum
            let isLocalHigh = true;
            let isLocalLow = true;
            
            for (let j = i - period; j <= i + period; j++) {
                if (j !== i) {
                    if (priceData[j].high >= currentHigh) isLocalHigh = false;
                    if (priceData[j].low <= currentLow) isLocalLow = false;
                }
            }
            
            if (isLocalHigh) highs.push({ price: currentHigh, index: i });
            if (isLocalLow) lows.push({ price: currentLow, index: i });
        }
        
        // Cluster nearby levels
        const resistanceLevels = this.clusterLevels(highs);
        const supportLevels = this.clusterLevels(lows);
        
        return {
            resistance: resistanceLevels.slice(0, 3), // Top 3 resistance levels
            support: supportLevels.slice(0, 3), // Top 3 support levels
        };
    }
    
    clusterLevels(levels, threshold = 0.02) {
        const clusters = [];
        const used = new Set();
        
        for (let i = 0; i < levels.length; i++) {
            if (used.has(i)) continue;
            
            const cluster = [levels[i]];
            used.add(i);
            
            for (let j = i + 1; j < levels.length; j++) {
                if (used.has(j)) continue;
                
                const priceDiff = Math.abs(levels[i].price - levels[j].price) / levels[i].price;
                if (priceDiff < threshold) {
                    cluster.push(levels[j]);
                    used.add(j);
                }
            }
            
            // Calculate cluster strength and average price
            const avgPrice = cluster.reduce((sum, level) => sum + level.price, 0) / cluster.length;
            clusters.push({
                price: avgPrice,
                strength: cluster.length,
                occurrences: cluster.length,
                recentTouch: Math.max(...cluster.map(c => c.index))
            });
        }
        
        // Sort by strength (number of touches) and recency
        return clusters.sort((a, b) => {
            const strengthDiff = b.strength - a.strength;
            if (strengthDiff !== 0) return strengthDiff;
            return b.recentTouch - a.recentTouch;
        });
    }
    
    interpretSupportResistance(sr, currentPrice) {
        const nearestResistance = sr.resistance.find(r => r.price > currentPrice);
        const nearestSupport = sr.support.find(s => s.price < currentPrice);
        
        let signal = 'NEUTRAL';
        let strength = 0;
        let reasoning = '';
        
        if (nearestResistance) {
            const resistanceDistance = (nearestResistance.price - currentPrice) / currentPrice;
            if (resistanceDistance < 0.01) { // Within 1%
                signal = 'SELL';
                strength = (nearestResistance.strength - 1) / 4; // Normalize to 0-1
                reasoning = `Price near resistance at $${nearestResistance.price.toFixed(2)} (${nearestResistance.strength} touches)`;
            }
        }
        
        if (nearestSupport) {
            const supportDistance = (currentPrice - nearestSupport.price) / currentPrice;
            if (supportDistance < 0.01) { // Within 1%
                signal = 'BUY';
                strength = (nearestSupport.strength - 1) / 4;
                reasoning = `Price near support at $${nearestSupport.price.toFixed(2)} (${nearestSupport.strength} touches)`;
            }
        }
        
        if (signal === 'NEUTRAL') {
            reasoning = `Price in neutral zone - next resistance: $${nearestResistance?.price.toFixed(2) || 'N/A'}, next support: $${nearestSupport?.price.toFixed(2) || 'N/A'}`;
        }
        
        return {
            signal,
            strength: Math.min(strength, 1.0),
            reasoning,
            nearestResistance,
            nearestSupport
        };
    }
    
    calculateConfluenceScore(signals) {
        const weights = {
            rsi: 0.2,
            macd: 0.2,
            movingAverages: 0.25,
            bollingerBands: 0.15,
            volume: 0.1,
            supportResistance: 0.1
        };
        
        let bullishScore = 0;
        let bearishScore = 0;
        let totalWeight = 0;
        
        for (const [indicator, signal] of Object.entries(signals)) {
            const weight = weights[indicator] || 0;
            if (weight === 0) continue;
            
            totalWeight += weight;
            
            if (signal.signal === 'BUY') {
                bullishScore += weight * signal.strength;
            } else if (signal.signal === 'SELL') {
                bearishScore += weight * signal.strength;
            }
        }
        
        // Return net bullish score (-1 to +1, where +1 is most bullish)
        return (bullishScore - bearishScore) / totalWeight;
    }
    
    determineOverallSignal(confluenceScore) {
        if (confluenceScore >= this.confluenceThresholds.strong_buy) {
            return 'STRONG_BUY';
        } else if (confluenceScore >= this.confluenceThresholds.buy) {
            return 'BUY';
        } else if (confluenceScore <= -this.confluenceThresholds.strong_buy) {
            return 'STRONG_SELL';
        } else if (confluenceScore <= -this.confluenceThresholds.buy) {
            return 'SELL';
        } else {
            return 'NEUTRAL';
        }
    }
    
    assessRisk(analysis) {
        let riskScore = 0;
        const riskFactors = [];
        
        // Volatility risk (Bollinger Band width)
        const bandwidth = analysis.indicators.bollingerBands.bandwidth;
        if (bandwidth > 0.3) {
            riskScore += 0.3;
            riskFactors.push('High volatility detected');
        } else if (bandwidth < 0.05) {
            riskScore += 0.1;
            riskFactors.push('Very low volatility - potential for sudden moves');
        }
        
        // Overbought/Oversold risk
        const rsi = analysis.indicators.rsi.current;
        if (rsi > 80 || rsi < 20) {
            riskScore += 0.2;
            riskFactors.push(rsi > 80 ? 'Extremely overbought' : 'Extremely oversold');
        }
        
        // Volume risk
        const volumeRatio = analysis.indicators.volume.ratio;
        if (volumeRatio < 0.3) {
            riskScore += 0.2;
            riskFactors.push('Very low volume - poor liquidity');
        }
        
        // Signal clarity risk
        const absConfluence = Math.abs(analysis.confluenceScore);
        if (absConfluence < 0.3) {
            riskScore += 0.15;
            riskFactors.push('Mixed signals - low conviction');
        }
        
        let riskLevel;
        if (riskScore < 0.2) riskLevel = 'LOW';
        else if (riskScore < 0.4) riskLevel = 'MEDIUM';
        else if (riskScore < 0.6) riskLevel = 'HIGH';
        else riskLevel = 'EXTREME';
        
        return {
            score: riskScore,
            level: riskLevel,
            factors: riskFactors
        };
    }
}
```

## Building a Complete Paper Trading Bot

### Paper Trading System with Risk Management

```javascript
// Complete paper trading system with Alpaca integration
class PaperTradingBot {
    constructor(alpacaKey, alpacaSecret, supabaseClient) {
        this.alpaca = new AlpacaApi({
            key: alpacaKey,
            secret: alpacaSecret,
            paper: true, // ALWAYS paper trading
            baseUrl: 'https://paper-api.alpaca.markets'
        });
        
        this.supabase = supabaseClient;
        this.technicalAnalysis = new TechnicalAnalysisEngine(alpacaKey, alpacaSecret, true);
        
        // Risk management parameters
        this.riskParams = {
            maxPositionSize: 0.05,      // 5% of portfolio per position
            maxDailyLoss: 0.02,         // 2% maximum daily loss
            maxDrawdown: 0.10,          // 10% maximum drawdown
            stopLossPercent: 0.03,      // 3% stop loss
            takeProfitPercent: 0.06,    // 6% take profit (2:1 risk/reward)
            maxOpenPositions: 10,       // Maximum number of open positions
            cooldownPeriod: 3600000     // 1 hour cooldown after stop loss
        };
        
        this.watchlist = [
            'AAPL', 'GOOGL', 'MSFT', 'TSLA', 'NVDA',
            'AMD', 'META', 'NFLX', 'AMZN', 'SPY'
        ];
        
        this.positions = new Map();
        this.cooldowns = new Map();
        this.dailyStats = {
            startingBalance: 0,
            currentBalance: 0,
            dailyPnL: 0,
            tradesExecuted: 0,
            winnersCount: 0,
            losersCount: 0
        };
    }
    
    async initialize() {
        try {
            // Get account information
            const account = await this.alpaca.getAccount();
            this.dailyStats.currentBalance = parseFloat(account.portfolio_value);
            this.dailyStats.startingBalance = parseFloat(account.last_day_portfolio_value) || this.dailyStats.currentBalance;
            this.dailyStats.dailyPnL = this.dailyStats.currentBalance - this.dailyStats.startingBalance;
            
            // Load existing positions
            await this.loadPositions();
            
            console.log('Paper Trading Bot initialized');
            console.log(`Portfolio Value: $${this.dailyStats.currentBalance.toFixed(2)}`);
            console.log(`Daily P&L: $${this.dailyStats.dailyPnL.toFixed(2)}`);
            console.log(`Open Positions: ${this.positions.size}`);
            
            return true;
            
        } catch (error) {
            console.error('Failed to initialize trading bot:', error);
            throw error;
        }
    }
    
    async loadPositions() {
        try {
            const positions = await this.alpaca.getPositions();
            
            for (const position of positions) {
                const symbol = position.symbol;
                const qty = parseInt(position.qty);
                
                if (qty !== 0) {
                    this.positions.set(symbol, {
                        symbol: symbol,
                        quantity: qty,
                        entryPrice: parseFloat(position.avg_entry_price),
                        currentPrice: parseFloat(position.current_price),
                        marketValue: parseFloat(position.market_value),
                        unrealizedPnL: parseFloat(position.unrealized_pl),
                        entryTime: new Date(position.created_at),
                        side: qty > 0 ? 'long' : 'short',
                        stopLoss: null, // Will be set based on entry price
                        takeProfit: null
                    });
                    
                    // Set stop loss and take profit based on entry
                    this.setPositionLevels(symbol);
                }
            }
            
        } catch (error) {
            console.error('Error loading positions:', error);
        }
    }
    
    async runTradingCycle() {
        try {
            console.log('Starting trading cycle...');
            
            // Check if we should trade (market hours, risk limits, etc.)
            const canTrade = await this.canTrade();
            if (!canTrade.allowed) {
                console.log(`Trading not allowed: ${canTrade.reason}`);
                return;
            }
            
            // Update daily stats
            await this.updateDailyStats();
            
            // Process existing positions first
            await this.managePositions();
            
            // Look for new opportunities
            if (this.positions.size < this.riskParams.maxOpenPositions) {
                await this.scanForOpportunities();
            }
            
            // Log trading summary
            await this.logTradingSummary();
            
        } catch (error) {
            console.error('Error in trading cycle:', error);
            await this.logError('Trading cycle error', error);
        }
    }
    
    async canTrade() {
        try {
            // Check market hours
            const clock = await this.alpaca.getClock();
            if (!clock.is_open) {
                return { allowed: false, reason: 'Market is closed' };
            }
            
            // Check daily loss limit
            const lossPercent = Math.abs(this.dailyStats.dailyPnL / this.dailyStats.startingBalance);
            if (this.dailyStats.dailyPnL < 0 && lossPercent > this.riskParams.maxDailyLoss) {
                return { allowed: false, reason: `Daily loss limit exceeded (${(lossPercent * 100).toFixed(2)}%)` };
            }
            
            // Check drawdown limit
            const account = await this.alpaca.getAccount();
            const currentBalance = parseFloat(account.portfolio_value);
            const equity = parseFloat(account.equity);
            const drawdown = (this.dailyStats.startingBalance - equity) / this.dailyStats.startingBalance;
            
            if (drawdown > this.riskParams.maxDrawdown) {
                return { allowed: false, reason: `Maximum drawdown exceeded (${(drawdown * 100).toFixed(2)}%)` };
            }
            
            return { allowed: true, reason: 'All checks passed' };
            
        } catch (error) {
            console.error('Error checking trading conditions:', error);
            return { allowed: false, reason: 'Error checking conditions' };
        }
    }
    
    async updateDailyStats() {
        try {
            const account = await this.alpaca.getAccount();
            this.dailyStats.currentBalance = parseFloat(account.portfolio_value);
            this.dailyStats.dailyPnL = this.dailyStats.currentBalance - this.dailyStats.startingBalance;
            
        } catch (error) {
            console.error('Error updating daily stats:', error);
        }
    }
    
    async managePositions() {
        for (const [symbol, position] of this.positions) {
            try {
                // Get current price
                const quote = await this.alpaca.getLatestQuote(symbol);
                const currentPrice = parseFloat(quote.BidPrice + quote.AskPrice) / 2;
                
                position.currentPrice = currentPrice;
                position.unrealizedPnL = (currentPrice - position.entryPrice) * position.quantity;
                
                // Check stop loss
                if (this.shouldTriggerStopLoss(position, currentPrice)) {
                    await this.closePosi tion(symbol, 'STOP_LOSS');
                    continue;
                }
                
                // Check take profit
                if (this.shouldTriggerTakeProfit(position, currentPrice)) {
                    await this.closePosition(symbol, 'TAKE_PROFIT');
                    continue;
                }
                
                // Check for trailing stop adjustment
                await this.updateTrailingStop(symbol, position, currentPrice);
                
            } catch (error) {
                console.error(`Error managing position ${symbol}:`, error);
            }
        }
    }
    
    shouldTriggerStopLoss(position, currentPrice) {
        if (position.side === 'long') {
            const stopPrice = position.entryPrice * (1 - this.riskParams.stopLossPercent);
            return currentPrice <= stopPrice;
        } else {
            const stopPrice = position.entryPrice * (1 + this.riskParams.stopLossPercent);
            return currentPrice >= stopPrice;
        }
    }
    
    shouldTriggerTakeProfit(position, currentPrice) {
        if (position.side === 'long') {
            const targetPrice = position.entryPrice * (1 + this.riskParams.takeProfitPercent);
            return currentPrice >= targetPrice;
        } else {
            const targetPrice = position.entryPrice * (1 - this.riskParams.takeProfitPercent);
            return currentPrice <= targetPrice;
        }
    }
    
    async updateTrailingStop(symbol, position, currentPrice) {
        // Implement trailing stop logic
        if (position.side === 'long') {
            const unrealizedGainPercent = (currentPrice - position.entryPrice) / position.entryPrice;
            
            // Only trail if we have at least 2% gain
            if (unrealizedGainPercent > 0.02) {
                const newStopPrice = currentPrice * (1 - this.riskParams.stopLossPercent);
                const currentStopPrice = position.entryPrice * (1 - this.riskParams.stopLossPercent);
                
                if (newStopPrice > currentStopPrice) {
                    position.stopLoss = newStopPrice;
                    console.log(`Trailing stop updated for ${symbol}: $${newStopPrice.toFixed(2)}`);
                }
            }
        }
    }
    
    async closePosition(symbol, reason) {
        try {
            const position = this.positions.get(symbol);
            if (!position) return;
            
            // Submit market order to close position
            const side = position.quantity > 0 ? 'sell' : 'buy';
            const qty = Math.abs(position.quantity);
            
            const order = await this.alpaca.createOrder({
                symbol: symbol,
                qty: qty,
                side: side,
                type: 'market',
                time_in_force: 'day'
            });
            
            console.log(`Closing position ${symbol} (${reason}): ${side} ${qty} shares`);
            
            // Log the trade
            await this.logTrade({
                symbol: symbol,
                action: 'CLOSE',
                reason: reason,
                quantity: qty,
                side: side,
                entryPrice: position.entryPrice,
                exitPrice: position.currentPrice,
                pnl: position.unrealizedPnL,
                orderId: order.id
            });
            
            // Update statistics
            if (position.unrealizedPnL > 0) {
                this.dailyStats.winnersCount++;
            } else {
                this.dailyStats.losersCount++;
            }
            this.dailyStats.tradesExecuted++;
            
            // Set cooldown if it was a stop loss
            if (reason === 'STOP_LOSS') {
                this.cooldowns.set(symbol, Date.now() + this.riskParams.cooldownPeriod);
            }
            
            // Remove from positions
            this.positions.delete(symbol);
            
        } catch (error) {
            console.error(`Error closing position ${symbol}:`, error);
        }
    }
    
    async scanForOpportunities() {
        console.log('Scanning for trading opportunities...');
        
        for (const symbol of this.watchlist) {
            try {
                // Skip if in cooldown
                if (this.cooldowns.has(symbol) && Date.now() < this.cooldowns.get(symbol)) {
                    continue;
                }
                
                // Skip if already have position
                if (this.positions.has(symbol)) {
                    continue;
                }
                
                // Perform technical analysis
                const analysis = await this.technicalAnalysis.analyzeSymbol(symbol);
                
                // Check if signal meets our criteria
                const signal = this.evaluateSignal(analysis);
                
                if (signal.action !== 'HOLD') {
                    await this.executeSignal(symbol, signal, analysis);
                }
                
                // Rate limiting - don't hammer the API
                await new Promise(resolve => setTimeout(resolve, 1000));
                
            } catch (error) {
                console.error(`Error scanning ${symbol}:`, error);
            }
        }
    }
    
    evaluateSignal(analysis) {
        const { overallSignal, confluenceScore, riskAssessment } = analysis;
        
        // Don't trade in high risk conditions
        if (riskAssessment.level === 'EXTREME') {
            return { action: 'HOLD', reason: 'Risk too high' };
        }
        
        // Require strong signals
        if (overallSignal === 'STRONG_BUY' && confluenceScore > 0.6) {
            return { 
                action: 'BUY', 
                confidence: confluenceScore,
                reasoning: `Strong buy signal with ${(confluenceScore * 100).toFixed(1)}% confluence`
            };
        } else if (overallSignal === 'STRONG_SELL' && confluenceScore < -0.6) {
            return { 
                action: 'SELL', 
                confidence: Math.abs(confluenceScore),
                reasoning: `Strong sell signal with ${(Math.abs(confluenceScore) * 100).toFixed(1)}% confluence`
            };
        }
        
        return { action: 'HOLD', reason: 'Signal not strong enough' };
    }
    
    async executeSignal(symbol, signal, analysis) {
        try {
            // Calculate position size
            const account = await this.alpaca.getAccount();
            const buyingPower = parseFloat(account.buying_power);
            const currentPrice = analysis.currentPrice;
            
            const maxPositionValue = this.dailyStats.currentBalance * this.riskParams.maxPositionSize;
            const positionValue = Math.min(maxPositionValue, buyingPower * 0.95); // Leave some buffer
            const quantity = Math.floor(positionValue / currentPrice);
            
            if (quantity < 1) {
                console.log(`Position size too small for ${symbol}`);
                return;
            }
            
            // Submit order
            const order = await this.alpaca.createOrder({
                symbol: symbol,
                qty: quantity,
                side: signal.action.toLowerCase(),
                type: 'market',
                time_in_force: 'day'
            });
            
            console.log(`Opening position ${symbol}: ${signal.action} ${quantity} shares at ~$${currentPrice.toFixed(2)}`);
            console.log(`Reasoning: ${signal.reasoning}`);
            
            // Create position tracking
            this.positions.set(symbol, {
                symbol: symbol,
                quantity: signal.action === 'BUY' ? quantity : -quantity,
                entryPrice: currentPrice,
                currentPrice: currentPrice,
                marketValue: quantity * currentPrice,
                unrealizedPnL: 0,
                entryTime: new Date(),
                side: signal.action === 'BUY' ? 'long' : 'short',
                stopLoss: null,
                takeProfit: null,
                orderId: order.id
            });
            
            // Set stop loss and take profit levels
            this.setPositionLevels(symbol);
            
            // Log the trade
            await this.logTrade({
                symbol: symbol,
                action: 'OPEN',
                reason: signal.reasoning,
                quantity: quantity,
                side: signal.action.toLowerCase(),
                entryPrice: currentPrice,
                confidence: signal.confidence,
                analysis: {
                    confluenceScore: analysis.confluenceScore,
                    overallSignal: analysis.overallSignal,
                    riskLevel: analysis.riskAssessment.level
                },
                orderId: order.id
            });
            
        } catch (error) {
            console.error(`Error executing signal for ${symbol}:`, error);
        }
    }
    
    setPositionLevels(symbol) {
        const position = this.positions.get(symbol);
        if (!position) return;
        
        if (position.side === 'long') {
            position.stopLoss = position.entryPrice * (1 - this.riskParams.stopLossPercent);
            position.takeProfit = position.entryPrice * (1 + this.riskParams.takeProfitPercent);
        } else {
            position.stopLoss = position.entryPrice * (1 + this.riskParams.stopLossPercent);
            position.takeProfit = position.entryPrice * (1 - this.riskParams.takeProfitPercent);
        }
        
        console.log(`${symbol} levels set - Stop: $${position.stopLoss.toFixed(2)}, Target: $${position.takeProfit.toFixed(2)}`);
    }
    
    async logTrade(tradeData) {
        try {
            await this.supabase
                .from('paper_trades')
                .insert({
                    symbol: tradeData.symbol,
                    action: tradeData.action,
                    reason: tradeData.reason,
                    quantity: tradeData.quantity,
                    side: tradeData.side,
                    entry_price: tradeData.entryPrice,
                    exit_price: tradeData.exitPrice || null,
                    pnl: tradeData.pnl || null,
                    confidence: tradeData.confidence || null,
                    analysis_data: tradeData.analysis || null,
                    order_id: tradeData.orderId,
                    executed_at: new Date().toISOString()
                });
            
        } catch (error) {
            console.error('Error logging trade:', error);
        }
    }
    
    async logTradingSummary() {
        const summary = {
            timestamp: new Date().toISOString(),
            portfolio_value: this.dailyStats.currentBalance,
            daily_pnl: this.dailyStats.dailyPnL,
            open_positions: this.positions.size,
            trades_today: this.dailyStats.tradesExecuted,
            winners: this.dailyStats.winnersCount,
            losers: this.dailyStats.losersCount,
            win_rate: this.dailyStats.tradesExecuted > 0 ? 
                (this.dailyStats.winnersCount / this.dailyStats.tradesExecuted) * 100 : 0
        };
        
        try {
            await this.supabase
                .from('trading_summaries')
                .insert(summary);
            
        } catch (error) {
            console.error('Error logging trading summary:', error);
        }
        
        console.log('\n=== Trading Summary ===');
        console.log(`Portfolio Value: $${summary.portfolio_value.toFixed(2)}`);
        console.log(`Daily P&L: $${summary.daily_pnl.toFixed(2)}`);
        console.log(`Open Positions: ${summary.open_positions}`);
        console.log(`Trades Today: ${summary.trades_today}`);
        console.log(`Win Rate: ${summary.win_rate.toFixed(1)}%`);
        console.log('=====================\n');
    }
    
    async logError(message, error) {
        try {
            await this.supabase
                .from('trading_errors')
                .insert({
                    error_message: message,
                    error_details: error.message,
                    stack_trace: error.stack,
                    occurred_at: new Date().toISOString()
                });
            
        } catch (logError) {
            console.error('Error logging error:', logError);
        }
    }
}
```

### Database Schema for Trade Journal

```sql
-- Trading system database schema for Supabase
-- Run this in your Supabase SQL editor

-- Paper trades table
CREATE TABLE paper_trades (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    symbol TEXT NOT NULL,
    action TEXT CHECK (action IN ('OPEN', 'CLOSE')) NOT NULL,
    reason TEXT NOT NULL,
    quantity INTEGER NOT NULL,
    side TEXT CHECK (side IN ('buy', 'sell')) NOT NULL,
    entry_price DECIMAL(10,4) NOT NULL,
    exit_price DECIMAL(10,4),
    pnl DECIMAL(10,2),
    confidence DECIMAL(3,2), -- 0.00 to 1.00
    analysis_data JSONB,
    order_id TEXT,
    executed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Trading summaries (daily performance)
CREATE TABLE trading_summaries (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    portfolio_value DECIMAL(12,2) NOT NULL,
    daily_pnl DECIMAL(10,2) NOT NULL,
    open_positions INTEGER DEFAULT 0,
    trades_today INTEGER DEFAULT 0,
    winners INTEGER DEFAULT 0,
    losers INTEGER DEFAULT 0,
    win_rate DECIMAL(5,2) DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Technical analysis results
CREATE TABLE technical_analysis (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    symbol TEXT NOT NULL,
    timeframe TEXT DEFAULT '1Day',
    current_price DECIMAL(10,4) NOT NULL,
    rsi_value DECIMAL(5,2),
    rsi_signal TEXT,
    macd_value DECIMAL(8,4),
    macd_signal TEXT,
    ma_signal TEXT,
    bb_signal TEXT,
    volume_signal TEXT,
    sr_signal TEXT,
    confluence_score DECIMAL(4,3), -- -1.000 to +1.000
    overall_signal TEXT CHECK (overall_signal IN ('STRONG_BUY', 'BUY', 'NEUTRAL', 'SELL', 'STRONG_SELL')),
    risk_level TEXT CHECK (risk_level IN ('LOW', 'MEDIUM', 'HIGH', 'EXTREME')),
    risk_factors TEXT[],
    analysis_data JSONB,
    analyzed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Trading errors and system logs
CREATE TABLE trading_errors (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    error_message TEXT NOT NULL,
    error_details TEXT,
    stack_trace TEXT,
    occurred_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Watchlist management
CREATE TABLE watchlist (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    symbol TEXT UNIQUE NOT NULL,
    added_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    active BOOLEAN DEFAULT true,
    notes TEXT
);

-- Risk management settings
CREATE TABLE risk_settings (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    setting_name TEXT UNIQUE NOT NULL,
    setting_value DECIMAL(10,6) NOT NULL,
    description TEXT,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Insert default risk settings
INSERT INTO risk_settings (setting_name, setting_value, description) VALUES
('max_position_size', 0.05, 'Maximum position size as percentage of portfolio'),
('max_daily_loss', 0.02, 'Maximum daily loss as percentage of portfolio'),
('max_drawdown', 0.10, 'Maximum drawdown limit'),
('stop_loss_percent', 0.03, 'Default stop loss percentage'),
('take_profit_percent', 0.06, 'Default take profit percentage'),
('max_open_positions', 10, 'Maximum number of open positions'),
('cooldown_period_hours', 1, 'Cooldown period after stop loss in hours');

-- Insert default watchlist
INSERT INTO watchlist (symbol, notes) VALUES
('AAPL', 'Apple Inc.'),
('GOOGL', 'Alphabet Inc.'),
('MSFT', 'Microsoft Corporation'),
('TSLA', 'Tesla Inc.'),
('NVDA', 'NVIDIA Corporation'),
('AMD', 'Advanced Micro Devices'),
('META', 'Meta Platforms Inc.'),
('NFLX', 'Netflix Inc.'),
('AMZN', 'Amazon.com Inc.'),
('SPY', 'SPDR S&P 500 ETF');

-- Indexes for performance
CREATE INDEX idx_paper_trades_symbol ON paper_trades(symbol);
CREATE INDEX idx_paper_trades_executed_at ON paper_trades(executed_at);
CREATE INDEX idx_trading_summaries_timestamp ON trading_summaries(timestamp);
CREATE INDEX idx_technical_analysis_symbol ON technical_analysis(symbol);
CREATE INDEX idx_technical_analysis_analyzed_at ON technical_analysis(analyzed_at);

-- Views for analysis
CREATE VIEW trade_performance AS
SELECT 
    symbol,
    COUNT(*) as total_trades,
    COUNT(*) FILTER (WHERE pnl > 0) as winning_trades,
    COUNT(*) FILTER (WHERE pnl < 0) as losing_trades,
    ROUND((COUNT(*) FILTER (WHERE pnl > 0)::DECIMAL / COUNT(*)) * 100, 2) as win_rate_percent,
    ROUND(SUM(pnl), 2) as total_pnl,
    ROUND(AVG(pnl), 2) as avg_pnl,
    ROUND(MAX(pnl), 2) as best_trade,
    ROUND(MIN(pnl), 2) as worst_trade
FROM paper_trades 
WHERE action = 'CLOSE' AND pnl IS NOT NULL
GROUP BY symbol
ORDER BY total_pnl DESC;

CREATE VIEW daily_performance AS
SELECT 
    DATE(executed_at) as trade_date,
    COUNT(*) as trades,
    COUNT(*) FILTER (WHERE pnl > 0) as winners,
    COUNT(*) FILTER (WHERE pnl < 0) as losers,
    ROUND(SUM(pnl), 2) as daily_pnl,
    ROUND((COUNT(*) FILTER (WHERE pnl > 0)::DECIMAL / COUNT(*)) * 100, 2) as win_rate
FROM paper_trades 
WHERE action = 'CLOSE' AND pnl IS NOT NULL
GROUP BY DATE(executed_at)
ORDER BY trade_date DESC;
```

## Complete Working Example: RSI + MACD System

```javascript
// Complete RSI + MACD confluence trading system
class RSIMACDTradingSystem {
    constructor(alpacaKey, alpacaSecret, supabaseClient) {
        this.bot = new PaperTradingBot(alpacaKey, alpacaSecret, supabaseClient);
        this.supabase = supabaseClient;
        
        // Strategy-specific parameters
        this.strategyParams = {
            rsiOverbought: 70,
            rsiOversold: 30,
            rsiNeutralUpper: 60,
            rsiNeutralLower: 40,
            minConfluenceScore: 0.6,
            requiredIndicators: ['rsi', 'macd'], // Must have signals from both
        };
        
        this.name = 'RSI_MACD_Confluence';
        this.version = '1.0.0';
    }
    
    async initialize() {
        await this.bot.initialize();
        console.log(`${this.name} v${this.version} initialized`);
        
        // Log strategy start
        await this.logStrategyEvent('STRATEGY_START', {
            strategy: this.name,
            version: this.version,
            parameters: this.strategyParams
        });
    }
    
    async runStrategy() {
        try {
            console.log(`\n=== ${this.name} Strategy Execution ===`);
            
            // Check trading conditions
            const canTrade = await this.bot.canTrade();
            if (!canTrade.allowed) {
                console.log(`Trading halted: ${canTrade.reason}`);
                return;
            }
            
            // Manage existing positions with strategy-specific logic
            await this.manageExistingPositions();
            
            // Scan for new opportunities
            if (this.bot.positions.size < this.bot.riskParams.maxOpenPositions) {
                await this.scanForSignals();
            }
            
            // Generate strategy report
            await this.generateStrategyReport();
            
        } catch (error) {
            console.error(`Error in ${this.name} strategy:`, error);
            await this.logStrategyEvent('STRATEGY_ERROR', { error: error.message });
        }
    }
    
    async manageExistingPositions() {
        for (const [symbol, position] of this.bot.positions) {
            try {
                // Get fresh technical analysis
                const analysis = await this.bot.technicalAnalysis.analyzeSymbol(symbol);
                
                // Check for early exit signals
                const exitSignal = this.evaluateExitSignal(analysis, position);
                
                if (exitSignal.shouldExit) {
                    console.log(`Early exit signal for ${symbol}: ${exitSignal.reason}`);
                    await this.bot.closePosition(symbol, exitSignal.reason);
                    
                    await this.logStrategyEvent('EARLY_EXIT', {
                        symbol,
                        reason: exitSignal.reason,
                        analysis: analysis.overallSignal,
                        confluenceScore: analysis.confluenceScore
                    });
                }
                
            } catch (error) {
                console.error(`Error managing position ${symbol}:`, error);
            }
        }
    }
    
    evaluateExitSignal(analysis, position) {
        const rsi = analysis.indicators.rsi.current;
        const macd = analysis.indicators.macd;
        
        // RSI extreme reversal
        if (position.side === 'long' && rsi > 80) {
            return {
                shouldExit: true,
                reason: 'RSI_EXTREME_OVERBOUGHT',
                confidence: 0.8
            };
        }
        
        if (position.side === 'short' && rsi < 20) {
            return {
                shouldExit: true,
                reason: 'RSI_EXTREME_OVERSOLD',
                confidence: 0.8
            };
        }
        
        // MACD divergence from position
        if (position.side === 'long' && macd.macd < macd.signal && macd.histogram < 0) {
            return {
                shouldExit: true,
                reason: 'MACD_BEARISH_DIVERGENCE',
                confidence: 0.6
            };
        }
        
        if (position.side === 'short' && macd.macd > macd.signal && macd.histogram > 0) {
            return {
                shouldExit: true,
                reason: 'MACD_BULLISH_DIVERGENCE', 
                confidence: 0.6
            };
        }
        
        return { shouldExit: false, reason: 'NO_EXIT_SIGNAL' };
    }
    
    async scanForSignals() {
        console.log('Scanning for RSI + MACD confluence signals...');
        
        for (const symbol of this.bot.watchlist) {
            try {
                // Skip if already have position or in cooldown
                if (this.bot.positions.has(symbol) || 
                    (this.bot.cooldowns.has(symbol) && Date.now() < this.bot.cooldowns.get(symbol))) {
                    continue;
                }
                
                // Get technical analysis
                const analysis = await this.bot.technicalAnalysis.analyzeSymbol(symbol);
                
                // Evaluate with strategy-specific logic
                const signal = this.evaluateRSIMACDSignal(analysis);
                
                if (signal.action !== 'HOLD') {
                    console.log(`\n${symbol} Signal: ${signal.action}`);
                    console.log(`RSI: ${analysis.indicators.rsi.current.toFixed(2)} (${analysis.signals.rsi.signal})`);
                    console.log(`MACD: ${analysis.indicators.macd.macd.toFixed(4)} vs Signal: ${analysis.indicators.macd.signal.toFixed(4)}`);
                    console.log(`Confluence Score: ${(analysis.confluenceScore * 100).toFixed(1)}%`);
                    console.log(`Reasoning: ${signal.reasoning}`);
                    
                    await this.executeStrategySignal(symbol, signal, analysis);
                }
                
                // Rate limiting
                await new Promise(resolve => setTimeout(resolve, 1000));
                
            } catch (error) {
                console.error(`Error scanning ${symbol}:`, error);
            }
        }
    }
    
    evaluateRSIMACDSignal(analysis) {
        const rsi = analysis.indicators.rsi.current;
        const rsiSignal = analysis.signals.rsi;
        const macdSignal = analysis.signals.macd;
        const confluenceScore = analysis.confluenceScore;
        
        // Must have minimum confluence score
        if (Math.abs(confluenceScore) < this.strategyParams.minConfluenceScore) {
            return {
                action: 'HOLD',
                reason: `Confluence score ${(confluenceScore * 100).toFixed(1)}% below threshold`,
                confidence: 0
            };
        }
        
        // Bullish RSI + MACD confluence
        if (rsi < this.strategyParams.rsiOversold && 
            rsiSignal.signal === 'BUY' && 
            macdSignal.signal === 'BUY') {
            
            return {
                action: 'BUY',
                confidence: Math.min(rsiSignal.strength + macdSignal.strength, 1.0),
                reasoning: `RSI oversold (${rsi.toFixed(2)}) + MACD bullish convergence`,
                strategyType: 'RSI_OVERSOLD_MACD_BULL'
            };
        }
        
        // Bearish RSI + MACD confluence
        if (rsi > this.strategyParams.rsiOverbought && 
            rsiSignal.signal === 'SELL' && 
            macdSignal.signal === 'SELL') {
            
            return {
                action: 'SELL',
                confidence: Math.min(rsiSignal.strength + macdSignal.strength, 1.0),
                reasoning: `RSI overbought (${rsi.toFixed(2)}) + MACD bearish convergence`,
                strategyType: 'RSI_OVERBOUGHT_MACD_BEAR'
            };
        }
        
        // Momentum continuation signals
        if (rsi > this.strategyParams.rsiNeutralUpper && 
            rsi < this.strategyParams.rsiOverbought &&
            rsiSignal.signal === 'BUY' && 
            macdSignal.signal === 'BUY' &&
            confluenceScore > 0.7) {
            
            return {
                action: 'BUY',
                confidence: confluenceScore,
                reasoning: `Strong bullish momentum with RSI ${rsi.toFixed(2)} + MACD alignment`,
                strategyType: 'MOMENTUM_CONTINUATION_BULL'
            };
        }
        
        if (rsi < this.strategyParams.rsiNeutralLower && 
            rsi > this.strategyParams.rsiOversold &&
            rsiSignal.signal === 'SELL' && 
            macdSignal.signal === 'SELL' &&
            confluenceScore < -0.7) {
            
            return {
                action: 'SELL',
                confidence: Math.abs(confluenceScore),
                reasoning: `Strong bearish momentum with RSI ${rsi.toFixed(2)} + MACD alignment`,
                strategyType: 'MOMENTUM_CONTINUATION_BEAR'
            };
        }
        
        return {
            action: 'HOLD',
            reason: 'No clear RSI + MACD confluence signal',
            confidence: 0
        };
    }
    
    async executeStrategySignal(symbol, signal, analysis) {
        try {
            // Calculate position size with strategy-specific risk
            const positionSize = this.calculateStrategyPositionSize(signal, analysis);
            
            if (positionSize < 1) {
                console.log(`Position size too small for ${symbol}`);
                return;
            }
            
            const currentPrice = analysis.currentPrice;
            
            // Submit order through bot
            const order = await this.bot.alpaca.createOrder({
                symbol: symbol,
                qty: positionSize,
                side: signal.action.toLowerCase(),
                type: 'market',
                time_in_force: 'day'
            });
            
            console.log(`Opening ${signal.action} position: ${symbol} x${positionSize} @ $${currentPrice.toFixed(2)}`);
            
            // Create position tracking with strategy data
            this.bot.positions.set(symbol, {
                symbol: symbol,
                quantity: signal.action === 'BUY' ? positionSize : -positionSize,
                entryPrice: currentPrice,
                currentPrice: currentPrice,
                marketValue: positionSize * currentPrice,
                unrealizedPnL: 0,
                entryTime: new Date(),
                side: signal.action === 'BUY' ? 'long' : 'short',
                stopLoss: null,
                takeProfit: null,
                orderId: order.id,
                strategy: this.name,
                strategyType: signal.strategyType
            });
            
            // Set position levels
            this.bot.setPositionLevels(symbol);
            
            // Log strategy-specific trade
            await this.logStrategyTrade(symbol, signal, analysis, order.id, positionSize, currentPrice);
            
        } catch (error) {
            console.error(`Error executing strategy signal for ${symbol}:`, error);
        }
    }
    
    calculateStrategyPositionSize(signal, analysis) {
        // Base position size
        const baseSize = this.bot.dailyStats.currentBalance * this.bot.riskParams.maxPositionSize;
        
        // Adjust based on signal confidence
        const confidenceMultiplier = signal.confidence;
        
        // Adjust based on risk level
        let riskMultiplier = 1.0;
        switch (analysis.riskAssessment.level) {
            case 'LOW': riskMultiplier = 1.0; break;
            case 'MEDIUM': riskMultiplier = 0.8; break;
            case 'HIGH': riskMultiplier = 0.6; break;
            case 'EXTREME': riskMultiplier = 0.0; break;
        }
        
        const adjustedSize = baseSize * confidenceMultiplier * riskMultiplier;
        return Math.floor(adjustedSize / analysis.currentPrice);
    }
    
    async logStrategyTrade(symbol, signal, analysis, orderId, quantity, price) {
        try {
            await this.supabase
                .from('strategy_trades')
                .insert({
                    strategy_name: this.name,
                    strategy_version: this.version,
                    symbol: symbol,
                    action: 'OPEN',
                    signal_type: signal.strategyType,
                    quantity: quantity,
                    price: price,
                    confidence: signal.confidence,
                    reasoning: signal.reasoning,
                    rsi_value: analysis.indicators.rsi.current,
                    macd_value: analysis.indicators.macd.macd,
                    macd_signal: analysis.indicators.macd.signal,
                    confluence_score: analysis.confluenceScore,
                    risk_level: analysis.riskAssessment.level,
                    order_id: orderId,
                    executed_at: new Date().toISOString()
                });
                
        } catch (error) {
            console.error('Error logging strategy trade:', error);
        }
    }
    
    async logStrategyEvent(eventType, data) {
        try {
            await this.supabase
                .from('strategy_events')
                .insert({
                    strategy_name: this.name,
                    event_type: eventType,
                    event_data: data,
                    occurred_at: new Date().toISOString()
                });
                
        } catch (error) {
            console.error('Error logging strategy event:', error);
        }
    }
    
    async generateStrategyReport() {
        // Get strategy performance data
        const { data: trades } = await this.supabase
            .from('strategy_trades')
            .select('*')
            .eq('strategy_name', this.name)
            .gte('executed_at', new Date(Date.now() - 30 * 24 * 60 * 60 * 1000).toISOString()); // Last 30 days
        
        if (!trades || trades.length === 0) {
            console.log('No recent strategy trades to analyze');
            return;
        }
        
        // Calculate strategy metrics
        const openTrades = trades.filter(t => t.action === 'OPEN');
        const closedTrades = trades.filter(t => t.action === 'CLOSE');
        
        const report = {
            strategy: this.name,
            period: '30 days',
            totalSignals: openTrades.length,
            signalTypes: this.groupBy(openTrades, 'signal_type'),
            avgConfidence: openTrades.reduce((sum, t) => sum + (t.confidence || 0), 0) / openTrades.length,
            riskLevelDistribution: this.groupBy(openTrades, 'risk_level'),
            currentPositions: this.bot.positions.size,
            generatedAt: new Date().toISOString()
        };
        
        console.log('\n=== Strategy Report ===');
        console.log(`Strategy: ${report.strategy}`);
        console.log(`Signals Generated: ${report.totalSignals}`);
        console.log(`Average Confidence: ${(report.avgConfidence * 100).toFixed(1)}%`);
        console.log(`Current Positions: ${report.currentPositions}`);
        console.log(`Signal Types:`, report.signalTypes);
        console.log(`Risk Distribution:`, report.riskLevelDistribution);
        console.log('=====================\n');
        
        return report;
    }
    
    groupBy(array, key) {
        return array.reduce((groups, item) => {
            const group = item[key] || 'unknown';
            groups[group] = (groups[group] || 0) + 1;
            return groups;
        }, {});
    }
}

// Cron job to run the RSI + MACD strategy
const RSI_MACD_STRATEGY_JOB = {
    name: 'rsi_macd_trading_strategy',
    schedule: '0 9,10,11,13,14,15 * * 1-5', // Market hours, weekdays only
    prompt: `Execute RSI + MACD confluence trading strategy:

## Strategy Overview
Run the RSI + MACD confluence system for paper trading:

**Entry Conditions:**
- RSI oversold (<30) + MACD bullish signal = BUY
- RSI overbought (>70) + MACD bearish signal = SELL  
- Strong momentum continuation with both indicators aligned
- Minimum 60% confluence score required

**Risk Management:**
- Maximum 5% portfolio per position
- 3% stop loss, 6% take profit (2:1 risk/reward)
- Maximum 10 open positions
- 1-hour cooldown after stop losses

**Position Management:**
- Monitor existing positions for early exit signals
- Trail stops on profitable positions
- Exit on extreme RSI levels or MACD divergence

## Execution Steps
1. Check market hours and trading conditions
2. Update portfolio and risk metrics  
3. Manage existing positions with strategy logic
4. Scan watchlist for new RSI + MACD signals
5. Execute qualifying trades with proper position sizing
6. Log all trades and strategy performance
7. Generate strategy performance report

## Risk Controls
- Halt trading if daily loss exceeds 2%
- No trading if portfolio drawdown >10%
- Reduce position sizes in high volatility
- Respect individual stock cooldown periods

Execute the strategy and provide summary of actions taken. This is paper trading only - no real money at risk.

**CRITICAL REMINDER: This is educational paper trading only. Never trade real money based on this system without thorough testing and professional advice.**`,
    model: 'standard',
    estimatedCost: '$0.40',
    dependencies: ['market_data_access', 'alpaca_paper_trading'],
    alertOnFailure: true
};
```

## Trading Strategy Cron Jobs

```javascript
// Additional strategy-specific cron jobs

// Daily performance analysis
const TRADING_PERFORMANCE_ANALYSIS = {
    name: 'daily_trading_performance',
    schedule: '0 16 * * 1-5', // 4 PM weekdays (after market close)
    prompt: `Analyze daily trading performance and generate insights:

## Daily Performance Review
Analyze today's trading activity:

**Trade Execution Analysis:**
- Number of trades executed and success rate
- Average holding period and timing analysis
- Entry/exit quality and execution slippage
- Order fill rates and market impact

**Strategy Performance:**
- RSI + MACD strategy effectiveness
- Signal quality and confidence correlation with outcomes
- Risk-adjusted returns and Sharpe ratio calculation
- Drawdown analysis and recovery patterns

**Risk Management Effectiveness:**
- Stop loss and take profit execution rates
- Position sizing accuracy and portfolio heat
- Maximum concurrent positions and diversification
- Risk-adjusted position performance

## Market Condition Analysis:**
- Overall market performance vs strategy performance
- Volatility impact on strategy effectiveness
- Sector rotation effects on stock selection
- Market regime identification (trending vs ranging)

## Optimization Opportunities:**
- Parameter optimization suggestions based on recent performance
- Watchlist optimization and symbol performance ranking
- Risk parameter adjustments based on volatility patterns
- Strategy timing and market condition filtering

## Tomorrow's Preparation:**
- Market events and earnings announcements affecting watchlist
- Technical setup identification for monitored stocks
- Risk budget allocation based on market conditions
- Strategy parameter adjustments for next session

Generate comprehensive performance analysis with specific recommendations for strategy improvement.`,
    model: 'premium',
    estimatedCost: '$0.50',
    dependencies: ['trading_database', 'market_data'],
    alertOnFailure: false
};

// Weekly strategy optimization
const WEEKLY_STRATEGY_OPTIMIZATION = {
    name: 'weekly_strategy_optimization',
    schedule: '0 18 * * 5', // 6 PM Fridays
    prompt: `Perform weekly trading strategy optimization and review:

## Strategy Performance Analysis
Review the past week's strategy performance:

**Win/Loss Analysis:**
- Winning vs losing trades breakdown by strategy type
- Average win vs average loss ratio
- Win rate by time of day and day of week
- Position hold time analysis and optimal exit timing

**Risk-Adjusted Performance:**
- Sharpe ratio and risk-adjusted returns
- Maximum drawdown and recovery analysis
- Volatility of returns and consistency metrics
- Risk budgeting effectiveness and allocation accuracy

## Parameter Optimization
Analyze parameter effectiveness and optimization opportunities:

**RSI Parameters:**
- Overbought/oversold level effectiveness (current: 70/30)
- RSI period optimization (current: 14)
- RSI divergence signal effectiveness
- Correlation with successful trades

**MACD Parameters:**
- Fast/slow EMA period effectiveness (current: 12/26/9)
- Signal line crossover timing and accuracy
- Histogram divergence signal quality
- Zero-line cross significance

**Confluence Requirements:**
- Minimum confluence score optimization (current: 60%)
- Individual indicator weight adjustment
- Signal timing and coordination effectiveness
- Multi-timeframe analysis integration

## Risk Management Review:**
- Stop loss percentage effectiveness (current: 3%)
- Take profit ratio optimization (current: 2:1)
- Position sizing based on volatility and confidence
- Maximum position limits and diversification rules

## Strategy Adaptation:**
- Market regime detection and strategy modification
- Volatility-based parameter adjustment
- Sector rotation and stock selection optimization
- Economic calendar integration for risk management

## Next Week Planning:**
- Parameter adjustments based on optimization analysis
- Watchlist updates and new symbol evaluation
- Risk budget allocation and position sizing updates
- Strategy enhancement implementation roadmap

Provide specific, actionable optimization recommendations with expected performance impact estimates.`,
    model: 'premium',
    estimatedCost: '$0.75',
    dependencies: ['trading_performance_data', 'optimization_algorithms'],
    alertOnFailure: false
};

// Risk monitoring (runs every hour during market hours)
const TRADING_RISK_MONITOR = {
    name: 'trading_risk_monitor',
    schedule: '0 9-15 * * 1-5', // Every hour during market hours
    prompt: `Monitor trading system risk levels and portfolio health:

## Real-Time Risk Assessment
Monitor current risk exposure and portfolio health:

**Portfolio Risk Metrics:**
- Current portfolio value and daily P&L
- Open position risk exposure and correlation
- Individual position sizes vs risk limits
- Sector concentration and diversification analysis

**Position Risk Analysis:**
- Unrealized P&L and stop loss proximity
- Position duration and time-based risk
- Correlated positions and portfolio beta
- Liquidity risk and position size vs volume

**Market Risk Factors:**
- Overall market volatility and VIX level
- Sector volatility and specific stock risk
- Economic events and earnings announcements
- Geopolitical events affecting positions

## Risk Limit Monitoring:**
- Daily loss limit vs current P&L (limit: 2%)
- Maximum drawdown vs current drawdown (limit: 10%)
- Position concentration limits (max: 5% per position)
- Total position count vs limit (max: 10)

## Automated Risk Actions:**
- Recommend position size reductions if limits approached
- Suggest stop loss tightening in high volatility
- Alert on correlated position concentration
- Flag positions requiring immediate attention

## Market Condition Assessment:**
- Intraday volatility patterns and trading difficulty
- Volume analysis and liquidity conditions
- Price action quality and execution risk
- Market microstructure and timing risk

## Risk Alerts and Recommendations:**
- Immediate actions required for risk limit breaches
- Proactive risk reduction recommendations
- Portfolio rebalancing suggestions
- Trading halt recommendations if conditions warrant

Only alert for critical risk situations requiring immediate action. Log all risk metrics for trend analysis.`,
    model: 'mini',
    estimatedCost: '$0.08',
    dependencies: ['real_time_portfolio_data', 'risk_management_system'],
    alertOnFailure: true
};
```

## Pro Tips for Trading System Success

**Tip 1: Paper Trade Everything First**
Never trade real money until you've paper traded a strategy for at least 6 months with consistent profits.

**Tip 2: Risk Management is Everything**
Your risk management system is more important than your entry signals. Perfect entries with poor risk management lose money.

**Tip 3: Keep Detailed Records**
Every trade needs detailed documentation. What worked, what didn't, and why. Data beats intuition.

**Tip 4: Start Simple, Add Complexity Gradually**
Begin with one indicator system. Master it before adding complexity. Complex systems often perform worse.

**Tip 5: Respect Market Regimes**
Trending markets favor momentum strategies. Range-bound markets favor mean reversion. Know which regime you're in.

**Tip 6: Automate Emotions Away**
The biggest advantage of systematic trading is removing emotion. Stick to your rules no matter what.

---

**FINAL REMINDER: This chapter demonstrates paper trading systems for educational purposes only. All examples use virtual money through Alpaca's paper trading platform. Real trading involves substantial risk of loss and should only be undertaken with money you can afford to lose. This is not financial advice. Consult qualified financial professionals before making investment decisions.**

The next chapter will show you how to integrate all your systems—lead generation, email outreach, trading, and more—into a cohesive full-stack business operation.