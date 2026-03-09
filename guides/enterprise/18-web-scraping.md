# Chapter 18: Web Scraping & Data Extraction

*The Foundation of Every Autonomous System*

Data is the lifeblood of autonomous systems. Without quality data flowing in, even the most sophisticated AI makes poor decisions. Web scraping isn't just about collecting information—it's about building reliable, ethical, and scalable data pipelines that power everything else you'll build.

This chapter will transform you from a casual scraper into a data extraction architect. We'll cover the legal frameworks, build production-grade scrapers, handle anti-scraping measures, and create pipelines that scale to millions of data points.

## Legal and Ethical Framework: What You Can Scrape, What You Can't

Before writing a single line of scraping code, understand the legal landscape. One lawsuit can destroy everything you've built.

### The Legal Hierarchy

**1. Terms of Service (Highest Authority)**
Every website's Terms of Service is a contract. Violating ToS isn't just unethical—it's potential breach of contract.

```javascript
// Automated ToS checker
class TermsOfServiceChecker {
    constructor() {
        this.cache = new Map();
        this.cacheExpiry = 24 * 60 * 60 * 1000; // 24 hours
    }
    
    async checkScrapingPermission(url) {
        const domain = new URL(url).hostname;
        const cacheKey = `tos_${domain}`;
        
        // Check cache first
        const cached = this.cache.get(cacheKey);
        if (cached && (Date.now() - cached.timestamp) < this.cacheExpiry) {
            return cached.permission;
        }
        
        try {
            // Look for common ToS paths
            const tosPaths = ['/terms', '/terms-of-service', '/legal', '/tos'];
            let tosContent = null;
            
            for (const path of tosPaths) {
                try {
                    const tosUrl = `https://${domain}${path}`;
                    const response = await fetch(tosUrl);
                    if (response.ok) {
                        tosContent = await response.text();
                        break;
                    }
                } catch (error) {
                    continue; // Try next path
                }
            }
            
            if (!tosContent) {
                return {
                    allowed: 'UNKNOWN',
                    reason: 'No Terms of Service found',
                    recommendation: 'Contact site owner for permission'
                };
            }
            
            const analysis = this.analyzeToSContent(tosContent);
            
            // Cache result
            this.cache.set(cacheKey, {
                permission: analysis,
                timestamp: Date.now()
            });
            
            return analysis;
            
        } catch (error) {
            return {
                allowed: 'ERROR',
                reason: error.message,
                recommendation: 'Manual review required'
            };
        }
    }
    
    analyzeToSContent(content) {
        const lowerContent = content.toLowerCase();
        
        // Red flag terms
        const prohibitedTerms = [
            'scraping',
            'automated access',
            'robot',
            'spider',
            'crawling',
            'data mining',
            'systematic downloading'
        ];
        
        const foundProhibited = prohibitedTerms.filter(term => 
            lowerContent.includes(term)
        );
        
        if (foundProhibited.length > 0) {
            return {
                allowed: 'PROHIBITED',
                reason: `Terms explicitly prohibit: ${foundProhibited.join(', ')}`,
                recommendation: 'Do not scrape without explicit permission'
            };
        }
        
        // Look for API mentions
        if (lowerContent.includes('api') && lowerContent.includes('developer')) {
            return {
                allowed: 'API_PREFERRED',
                reason: 'Site offers API access',
                recommendation: 'Use official API instead of scraping'
            };
        }
        
        return {
            allowed: 'UNCLEAR',
            reason: 'No explicit scraping policy found',
            recommendation: 'Proceed cautiously, respect robots.txt'
        };
    }
}
```

**Why This Matters:** A simple automated ToS check can save you from legal trouble. Major companies like LinkedIn, Facebook, and Twitter have sued scrapers for ToS violations.

**2. robots.txt (Site Owner Intent)**
robots.txt isn't legally binding, but it signals the site owner's intent. Respecting it shows good faith.

```javascript
// Robots.txt parser and validator
class RobotsTxtValidator {
    constructor() {
        this.cache = new Map();
        this.cacheExpiry = 60 * 60 * 1000; // 1 hour
    }
    
    async checkPathAllowed(url, userAgent = '*') {
        const urlObj = new URL(url);
        const robotsUrl = `${urlObj.protocol}//${urlObj.host}/robots.txt`;
        
        let robotsRules = this.cache.get(robotsUrl);
        
        if (!robotsRules || (Date.now() - robotsRules.timestamp) > this.cacheExpiry) {
            robotsRules = await this.fetchAndParseRobots(robotsUrl);
            this.cache.set(robotsUrl, {
                rules: robotsRules,
                timestamp: Date.now()
            });
        }
        
        return this.isPathAllowed(urlObj.pathname, userAgent, robotsRules.rules);
    }
    
    async fetchAndParseRobots(robotsUrl) {
        try {
            const response = await fetch(robotsUrl);
            if (!response.ok) {
                return { rules: [], crawlDelay: 0, sitemaps: [] };
            }
            
            const content = await response.text();
            return this.parseRobotsTxt(content);
            
        } catch (error) {
            console.warn(`Could not fetch robots.txt from ${robotsUrl}:`, error.message);
            return { rules: [], crawlDelay: 0, sitemaps: [] };
        }
    }
    
    parseRobotsTxt(content) {
        const lines = content.split('\n');
        const rules = [];
        let currentUserAgent = null;
        let crawlDelay = 0;
        const sitemaps = [];
        
        for (const line of lines) {
            const trimmed = line.trim();
            if (!trimmed || trimmed.startsWith('#')) continue;
            
            const [directive, ...valueParts] = trimmed.split(':');
            const value = valueParts.join(':').trim();
            
            switch (directive.toLowerCase()) {
                case 'user-agent':
                    currentUserAgent = value;
                    break;
                    
                case 'disallow':
                    if (currentUserAgent) {
                        rules.push({
                            userAgent: currentUserAgent,
                            directive: 'disallow',
                            path: value
                        });
                    }
                    break;
                    
                case 'allow':
                    if (currentUserAgent) {
                        rules.push({
                            userAgent: currentUserAgent,
                            directive: 'allow',
                            path: value
                        });
                    }
                    break;
                    
                case 'crawl-delay':
                    crawlDelay = parseInt(value) || 0;
                    break;
                    
                case 'sitemap':
                    sitemaps.push(value);
                    break;
            }
        }
        
        return { rules, crawlDelay, sitemaps };
    }
    
    isPathAllowed(path, userAgent, rules) {
        const applicableRules = rules.filter(rule => 
            rule.userAgent === '*' || rule.userAgent === userAgent
        );
        
        // Check most specific rules first
        applicableRules.sort((a, b) => b.path.length - a.path.length);
        
        for (const rule of applicableRules) {
            if (this.pathMatches(path, rule.path)) {
                return {
                    allowed: rule.directive === 'allow',
                    rule: rule,
                    reason: `${rule.directive.toUpperCase()} rule: ${rule.path}`
                };
            }
        }
        
        // No matching rule = allowed
        return {
            allowed: true,
            rule: null,
            reason: 'No matching robots.txt rule'
        };
    }
    
    pathMatches(path, pattern) {
        if (pattern === '') return true; // Empty pattern matches all
        if (pattern === '/') return true; // Root pattern matches all
        
        // Convert robots.txt wildcards to regex
        const regexPattern = pattern
            .replace(/\*/g, '.*')  // * becomes .*
            .replace(/\$$/g, '$'); // $ at end means end of string
            
        return new RegExp('^' + regexPattern).test(path);
    }
}
```

**3. Rate Limiting (Technical Respect)**
Even if scraping is allowed, you must respect the server's capacity.

```javascript
// Intelligent rate limiter
class IntelligentRateLimiter {
    constructor() {
        this.domainLimits = new Map();
        this.requestHistory = new Map();
    }
    
    async shouldWait(url) {
        const domain = new URL(url).hostname;
        const now = Date.now();
        
        // Get or create domain configuration
        let domainConfig = this.domainLimits.get(domain);
        if (!domainConfig) {
            domainConfig = await this.detectOptimalRateLimit(domain);
            this.domainLimits.set(domain, domainConfig);
        }
        
        // Get request history for this domain
        let history = this.requestHistory.get(domain) || [];
        
        // Remove old requests (outside the time window)
        const windowStart = now - domainConfig.windowMs;
        history = history.filter(timestamp => timestamp > windowStart);
        
        // Check if we're at the limit
        if (history.length >= domainConfig.maxRequests) {
            const oldestRequest = Math.min(...history);
            const waitTime = (oldestRequest + domainConfig.windowMs) - now;
            return Math.max(0, waitTime);
        }
        
        // Check minimum delay between requests
        if (history.length > 0) {
            const lastRequest = Math.max(...history);
            const timeSinceLastRequest = now - lastRequest;
            const minimumWait = domainConfig.minDelayMs - timeSinceLastRequest;
            
            if (minimumWait > 0) {
                return minimumWait;
            }
        }
        
        // Update history
        history.push(now);
        this.requestHistory.set(domain, history);
        
        return 0; // No wait needed
    }
    
    async detectOptimalRateLimit(domain) {
        // Start with conservative defaults
        const baseConfig = {
            maxRequests: 10,
            windowMs: 60000, // 1 minute
            minDelayMs: 1000, // 1 second between requests
            adaptive: true
        };
        
        try {
            // Check if robots.txt specifies crawl delay
            const robotsValidator = new RobotsTxtValidator();
            const robotsUrl = `https://${domain}/robots.txt`;
            const robotsData = await robotsValidator.fetchAndParseRobots(robotsUrl);
            
            if (robotsData.crawlDelay > 0) {
                baseConfig.minDelayMs = robotsData.crawlDelay * 1000;
            }
            
            // Detect server response patterns
            const testConfig = await this.adaptiveRateDetection(domain, baseConfig);
            return { ...baseConfig, ...testConfig };
            
        } catch (error) {
            console.warn(`Could not detect optimal rate for ${domain}, using defaults`);
            return baseConfig;
        }
    }
    
    async adaptiveRateDetection(domain, baseConfig) {
        // Send test requests to determine optimal rate
        const testRequests = 5;
        const results = [];
        
        for (let i = 0; i < testRequests; i++) {
            const start = Date.now();
            
            try {
                const response = await fetch(`https://${domain}`, {
                    method: 'HEAD',
                    timeout: 10000
                });
                
                const responseTime = Date.now() - start;
                results.push({
                    success: response.ok,
                    responseTime,
                    status: response.status,
                    rateLimitHeaders: this.extractRateLimitHeaders(response.headers)
                });
                
                // Wait base delay between tests
                await new Promise(resolve => setTimeout(resolve, baseConfig.minDelayMs));
                
            } catch (error) {
                results.push({
                    success: false,
                    responseTime: Date.now() - start,
                    error: error.message
                });
            }
        }
        
        return this.analyzeTestResults(results, baseConfig);
    }
    
    extractRateLimitHeaders(headers) {
        const rateLimitHeaders = {};
        
        // Common rate limit header patterns
        const headerPatterns = {
            'x-ratelimit-limit': 'limit',
            'x-ratelimit-remaining': 'remaining',
            'x-ratelimit-reset': 'reset',
            'x-rate-limit-limit': 'limit',
            'x-rate-limit-remaining': 'remaining',
            'x-rate-limit-reset': 'reset',
            'retry-after': 'retryAfter'
        };
        
        for (const [headerName, configKey] of Object.entries(headerPatterns)) {
            const value = headers.get(headerName);
            if (value) {
                rateLimitHeaders[configKey] = parseInt(value) || value;
            }
        }
        
        return rateLimitHeaders;
    }
}
```

**Why This Matters:** Proper rate limiting prevents IP bans, reduces server load, and shows respect for the site owner's resources.

## Browser-Based Scraping with OpenClaw's Browser Tool

Browser-based scraping handles JavaScript-heavy sites, complex interactions, and modern web applications that traditional HTTP scraping can't touch.

### Navigating to Pages

```javascript
// Advanced browser navigation with error handling
class BrowserScraper {
    constructor(options = {}) {
        this.options = {
            timeout: 30000,
            waitForLoad: 'networkidle',
            userAgent: options.userAgent || 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
            viewport: { width: 1920, height: 1080 },
            ...options
        };
    }
    
    async navigateToPage(url, options = {}) {
        const navigationOptions = {
            ...this.options,
            ...options
        };
        
        try {
            // Open browser and navigate
            const result = await browser.action('navigate', {
                url: url,
                timeout: navigationOptions.timeout,
                waitUntil: navigationOptions.waitForLoad
            });
            
            if (!result.success) {
                throw new Error(`Navigation failed: ${result.error}`);
            }
            
            // Wait for any dynamic content to load
            if (navigationOptions.waitForSelector) {
                await this.waitForElement(navigationOptions.waitForSelector);
            }
            
            // Check for common blocking patterns
            const blockingDetected = await this.detectBlocking();
            if (blockingDetected.blocked) {
                throw new Error(`Access blocked: ${blockingDetected.reason}`);
            }
            
            return {
                success: true,
                url: result.url,
                title: await this.getPageTitle(),
                loadTime: result.loadTime
            };
            
        } catch (error) {
            await this.handleNavigationError(error, url, navigationOptions);
            throw error;
        }
    }
    
    async detectBlocking() {
        // Take a snapshot to analyze the page
        const snapshot = await browser.action('snapshot', {
            refs: 'role'
        });
        
        const pageText = snapshot.text.toLowerCase();
        
        // Common blocking patterns
        const blockingPatterns = [
            { pattern: 'access denied', reason: 'Access denied by server' },
            { pattern: 'captcha', reason: 'CAPTCHA challenge detected' },
            { pattern: 'rate limit', reason: 'Rate limiting detected' },
            { pattern: 'bot detection', reason: 'Bot detection system triggered' },
            { pattern: '403 forbidden', reason: 'HTTP 403 Forbidden' },
            { pattern: 'cloudflare', reason: 'Cloudflare protection active' }
        ];
        
        for (const { pattern, reason } of blockingPatterns) {
            if (pageText.includes(pattern)) {
                return { blocked: true, reason };
            }
        }
        
        return { blocked: false, reason: null };
    }
    
    async waitForElement(selector, timeout = 10000) {
        const startTime = Date.now();
        
        while (Date.now() - startTime < timeout) {
            const snapshot = await browser.action('snapshot');
            const element = this.findElementInSnapshot(snapshot, selector);
            
            if (element) {
                return element;
            }
            
            await new Promise(resolve => setTimeout(resolve, 500));
        }
        
        throw new Error(`Element not found: ${selector} (timeout: ${timeout}ms)`);
    }
}
```

### Taking Snapshots (DOM Inspection)

```javascript
// Advanced DOM analysis and data extraction
class DOMExtractor {
    constructor() {
        this.extractors = new Map();
    }
    
    async analyzePageStructure(url) {
        await browser.action('navigate', { url });
        
        // Take comprehensive snapshot
        const snapshot = await browser.action('snapshot', {
            refs: 'aria',
            labels: true,
            maxChars: 1000000 // Large pages
        });
        
        const analysis = {
            url: url,
            timestamp: Date.now(),
            structure: this.analyzeStructure(snapshot),
            dataElements: this.findDataElements(snapshot),
            navigationElements: this.findNavigationElements(snapshot),
            formElements: this.findFormElements(snapshot),
            contentPatterns: this.identifyContentPatterns(snapshot)
        };
        
        return analysis;
    }
    
    analyzeStructure(snapshot) {
        const elements = snapshot.elements || [];
        
        const structure = {
            totalElements: elements.length,
            elementTypes: {},
            contentAreas: [],
            dataContainers: []
        };
        
        for (const element of elements) {
            // Count element types
            const tagName = element.tagName?.toLowerCase() || 'unknown';
            structure.elementTypes[tagName] = (structure.elementTypes[tagName] || 0) + 1;
            
            // Identify content areas
            if (this.isContentArea(element)) {
                structure.contentAreas.push({
                    ref: element.ref,
                    type: this.getContentAreaType(element),
                    textLength: element.text?.length || 0
                });
            }
            
            // Identify data containers
            if (this.isDataContainer(element)) {
                structure.dataContainers.push({
                    ref: element.ref,
                    dataType: this.inferDataType(element),
                    childCount: element.children?.length || 0
                });
            }
        }
        
        return structure;
    }
    
    isContentArea(element) {
        const contentSelectors = [
            'article', 'main', 'section',
            '[role="main"]', '[role="article"]',
            '.content', '.post', '.article'
        ];
        
        return contentSelectors.some(selector => 
            this.elementMatchesSelector(element, selector)
        );
    }
    
    isDataContainer(element) {
        const dataSelectors = [
            'table', 'ul', 'ol', '.list',
            '[data-list]', '[data-items]',
            '.grid', '.cards', '.results'
        ];
        
        return dataSelectors.some(selector => 
            this.elementMatchesSelector(element, selector)
        );
    }
    
    findDataElements(snapshot) {
        const elements = snapshot.elements || [];
        const dataElements = [];
        
        for (const element of elements) {
            const dataScore = this.calculateDataScore(element);
            
            if (dataScore > 0.7) {
                dataElements.push({
                    ref: element.ref,
                    score: dataScore,
                    type: this.inferElementDataType(element),
                    extractionPattern: this.generateExtractionPattern(element)
                });
            }
        }
        
        return dataElements.sort((a, b) => b.score - a.score);
    }
    
    calculateDataScore(element) {
        let score = 0;
        
        // Text content indicates data
        if (element.text && element.text.length > 10) {
            score += 0.3;
        }
        
        // Structured attributes
        if (element.id) score += 0.1;
        if (element.className) score += 0.1;
        
        // Data-specific patterns
        const text = element.text?.toLowerCase() || '';
        
        // Email pattern
        if (text.includes('@') && text.includes('.')) {
            score += 0.4;
        }
        
        // Phone pattern
        if (/\d{3}[-.]?\d{3}[-.]?\d{4}/.test(text)) {
            score += 0.4;
        }
        
        // URL pattern
        if (text.includes('http') || text.includes('www.')) {
            score += 0.3;
        }
        
        // Currency pattern
        if (/[$£€¥]\d+|\d+[$£€¥]/.test(text)) {
            score += 0.3;
        }
        
        // Date pattern
        if (/\d{1,2}[\/\-]\d{1,2}[\/\-]\d{2,4}/.test(text)) {
            score += 0.3;
        }
        
        return Math.min(1, score);
    }
}
```

### Extracting Data from Elements

```javascript
// Production-grade data extraction system
class ProductionDataExtractor {
    constructor() {
        this.extractionRules = new Map();
        this.validators = new Map();
        this.cleaners = new Map();
    }
    
    async extractDataFromPage(url, extractionConfig) {
        await browser.action('navigate', { url });
        
        const snapshot = await browser.action('snapshot', {
            refs: 'aria',
            labels: true
        });
        
        const extractedData = {};
        const extractionLog = [];
        
        for (const [fieldName, fieldConfig] of Object.entries(extractionConfig.fields)) {
            try {
                const rawValue = await this.extractField(snapshot, fieldConfig);
                const cleanedValue = await this.cleanValue(rawValue, fieldConfig);
                const validatedValue = await this.validateValue(cleanedValue, fieldConfig);
                
                extractedData[fieldName] = validatedValue;
                extractionLog.push({
                    field: fieldName,
                    status: 'success',
                    rawValue: rawValue?.substring(0, 100) + '...',
                    cleanedValue: cleanedValue?.substring(0, 100) + '...'
                });
                
            } catch (error) {
                extractionLog.push({
                    field: fieldName,
                    status: 'error',
                    error: error.message
                });
                
                // Use fallback if configured
                if (fieldConfig.fallback) {
                    try {
                        const fallbackValue = await this.extractField(snapshot, fieldConfig.fallback);
                        extractedData[fieldName] = await this.cleanValue(fallbackValue, fieldConfig);
                        extractionLog.push({
                            field: fieldName,
                            status: 'fallback_success'
                        });
                    } catch (fallbackError) {
                        extractedData[fieldName] = fieldConfig.default || null;
                    }
                } else {
                    extractedData[fieldName] = fieldConfig.default || null;
                }
            }
        }
        
        return {
            data: extractedData,
            extractionLog,
            timestamp: Date.now(),
            url
        };
    }
    
    async extractField(snapshot, fieldConfig) {
        const { selector, attribute, multiple, regex, required } = fieldConfig;
        
        // Find elements matching the selector
        const elements = this.findElementsBySelector(snapshot, selector);
        
        if (elements.length === 0) {
            if (required) {
                throw new Error(`Required field not found: ${selector}`);
            }
            return null;
        }
        
        const values = [];
        
        for (const element of elements) {
            let value;
            
            // Extract based on attribute or text
            if (attribute) {
                value = element[attribute] || element.getAttribute?.(attribute);
            } else {
                value = element.text || element.textContent;
            }
            
            // Apply regex if specified
            if (regex && value) {
                const match = value.match(new RegExp(regex));
                value = match ? (match[1] || match[0]) : null;
            }
            
            if (value) {
                values.push(value.trim());
            }
        }
        
        // Return single value or array based on configuration
        if (multiple) {
            return values;
        } else {
            return values.length > 0 ? values[0] : null;
        }
    }
    
    findElementsBySelector(snapshot, selector) {
        // Convert CSS selector to element matches
        const elements = snapshot.elements || [];
        const matches = [];
        
        for (const element of elements) {
            if (this.elementMatchesSelector(element, selector)) {
                matches.push(element);
            }
        }
        
        return matches;
    }
    
    elementMatchesSelector(element, selector) {
        // Simplified selector matching for common patterns
        
        // ID selector
        if (selector.startsWith('#')) {
            const id = selector.substring(1);
            return element.id === id;
        }
        
        // Class selector
        if (selector.startsWith('.')) {
            const className = selector.substring(1);
            return element.className?.includes(className);
        }
        
        // Tag selector
        if (/^[a-zA-Z]+$/.test(selector)) {
            return element.tagName?.toLowerCase() === selector.toLowerCase();
        }
        
        // Attribute selector
        if (selector.includes('[') && selector.includes(']')) {
            const attrMatch = selector.match(/\[([^=\]]+)(?:="?([^"]*)"?)?\]/);
            if (attrMatch) {
                const [, attrName, attrValue] = attrMatch;
                const elementAttr = element.getAttribute?.(attrName);
                
                if (attrValue) {
                    return elementAttr === attrValue;
                } else {
                    return elementAttr !== null;
                }
            }
        }
        
        return false;
    }
    
    async cleanValue(value, fieldConfig) {
        if (!value) return value;
        
        const { type, trim = true, lowercase, removePatterns } = fieldConfig;
        
        let cleaned = value;
        
        // Basic trimming
        if (trim && typeof cleaned === 'string') {
            cleaned = cleaned.trim();
        }
        
        // Remove specified patterns
        if (removePatterns && Array.isArray(removePatterns)) {
            for (const pattern of removePatterns) {
                cleaned = cleaned.replace(new RegExp(pattern, 'gi'), '');
            }
        }
        
        // Type-specific cleaning
        switch (type) {
            case 'email':
                cleaned = this.cleanEmail(cleaned);
                break;
            case 'phone':
                cleaned = this.cleanPhone(cleaned);
                break;
            case 'url':
                cleaned = this.cleanUrl(cleaned);
                break;
            case 'number':
                cleaned = this.cleanNumber(cleaned);
                break;
            case 'date':
                cleaned = this.cleanDate(cleaned);
                break;
        }
        
        // Case transformation
        if (lowercase && typeof cleaned === 'string') {
            cleaned = cleaned.toLowerCase();
        }
        
        return cleaned;
    }
    
    cleanEmail(email) {
        if (typeof email !== 'string') return email;
        
        // Remove common prefixes/suffixes
        let cleaned = email.replace(/^mailto:/, '');
        
        // Extract email from text that might contain other content
        const emailMatch = cleaned.match(/([a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,})/);
        
        return emailMatch ? emailMatch[1] : cleaned;
    }
    
    cleanPhone(phone) {
        if (typeof phone !== 'string') return phone;
        
        // Remove all non-digit characters except + at the start
        let cleaned = phone.replace(/[^\d+]/g, '');
        
        // If it starts with +, keep it
        if (phone.trim().startsWith('+')) {
            cleaned = '+' + cleaned.replace(/\+/g, '');
        }
        
        return cleaned;
    }
    
    cleanUrl(url) {
        if (typeof url !== 'string') return url;
        
        // Add protocol if missing
        if (url.startsWith('//')) {
            return 'https:' + url;
        } else if (url.startsWith('www.') || (!url.includes('://') && url.includes('.'))) {
            return 'https://' + url;
        }
        
        return url;
    }
    
    cleanNumber(number) {
        if (typeof number !== 'string') return number;
        
        // Remove currency symbols and commas
        let cleaned = number.replace(/[$£€¥,\s]/g, '');
        
        // Parse as float
        const parsed = parseFloat(cleaned);
        
        return isNaN(parsed) ? null : parsed;
    }
    
    async validateValue(value, fieldConfig) {
        if (!value && !fieldConfig.required) {
            return value;
        }
        
        const { type, required, pattern, minLength, maxLength } = fieldConfig;
        
        if (required && (!value || value.length === 0)) {
            throw new Error(`Required field is empty`);
        }
        
        // Length validation
        if (typeof value === 'string') {
            if (minLength && value.length < minLength) {
                throw new Error(`Value too short (min: ${minLength})`);
            }
            if (maxLength && value.length > maxLength) {
                throw new Error(`Value too long (max: ${maxLength})`);
            }
        }
        
        // Pattern validation
        if (pattern && typeof value === 'string') {
            if (!new RegExp(pattern).test(value)) {
                throw new Error(`Value does not match required pattern`);
            }
        }
        
        // Type-specific validation
        switch (type) {
            case 'email':
                if (!this.isValidEmail(value)) {
                    throw new Error('Invalid email format');
                }
                break;
            case 'url':
                if (!this.isValidUrl(value)) {
                    throw new Error('Invalid URL format');
                }
                break;
            case 'number':
                if (isNaN(parseFloat(value))) {
                    throw new Error('Invalid number format');
                }
                break;
        }
        
        return value;
    }
    
    isValidEmail(email) {
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        return emailRegex.test(email);
    }
    
    isValidUrl(url) {
        try {
            new URL(url);
            return true;
        } catch {
            return false;
        }
    }
}
```

### Handling Pagination

```javascript
// Advanced pagination handler
class PaginationHandler {
    constructor(options = {}) {
        this.options = {
            maxPages: 50,
            delayBetweenPages: 2000,
            ...options
        };
        this.visitedUrls = new Set();
    }
    
    async scrapeAllPages(startUrl, extractionConfig, paginationConfig) {
        const allData = [];
        const errors = [];
        let currentUrl = startUrl;
        let pageNumber = 1;
        
        while (currentUrl && pageNumber <= this.options.maxPages) {
            try {
                console.log(`Scraping page ${pageNumber}: ${currentUrl}`);
                
                // Navigate to current page
                await browser.action('navigate', { url: currentUrl });
                
                // Wait for content to load
                if (paginationConfig.waitForSelector) {
                    await this.waitForElement(paginationConfig.waitForSelector);
                }
                
                // Extract data from current page
                const extractor = new ProductionDataExtractor();
                const pageData = await extractor.extractDataFromPage(currentUrl, extractionConfig);
                
                allData.push(...(Array.isArray(pageData.data) ? pageData.data : [pageData.data]));
                
                // Find next page URL
                const nextUrl = await this.findNextPage(paginationConfig);
                
                if (!nextUrl || this.visitedUrls.has(nextUrl)) {
                    console.log('No more pages found or circular pagination detected');
                    break;
                }
                
                this.visitedUrls.add(currentUrl);
                currentUrl = nextUrl;
                pageNumber++;
                
                // Respectful delay between pages
                await new Promise(resolve => setTimeout(resolve, this.options.delayBetweenPages));
                
            } catch (error) {
                errors.push({
                    page: pageNumber,
                    url: currentUrl,
                    error: error.message
                });
                
                console.error(`Error on page ${pageNumber}:`, error.message);
                break; // Stop on error unless configured to continue
            }
        }
        
        return {
            data: allData,
            totalPages: pageNumber - 1,
            errors,
            completed: errors.length === 0
        };
    }
    
    async findNextPage(paginationConfig) {
        const { type, selector, urlPattern, currentPagePattern } = paginationConfig;
        
        const snapshot = await browser.action('snapshot', {
            refs: 'aria',
            labels: true
        });
        
        switch (type) {
            case 'next_button':
                return await this.findNextButtonUrl(snapshot, selector);
                
            case 'page_numbers':
                return await this.findNextPageNumber(snapshot, selector);
                
            case 'url_pattern':
                return await this.generateNextUrl(urlPattern, currentPagePattern);
                
            case 'infinite_scroll':
                return await this.handleInfiniteScroll(selector);
                
            default:
                throw new Error(`Unknown pagination type: ${type}`);
        }
    }
    
    async findNextButtonUrl(snapshot, selector) {
        const elements = this.findElementsBySelector(snapshot, selector);
        
        for (const element of elements) {
            const text = element.text?.toLowerCase() || '';
            
            // Look for "next" indicators
            if (text.includes('next') || text.includes('>') || text.includes('→')) {
                // Get URL from href attribute or click the element
                const href = element.href;
                
                if (href) {
                    return this.resolveUrl(href);
                } else {
                    // Click the element and get the new URL
                    await browser.action('act', {
                        kind: 'click',
                        ref: element.ref
                    });
                    
                    // Wait for navigation
                    await new Promise(resolve => setTimeout(resolve, 2000));
                    
                    const newSnapshot = await browser.action('snapshot');
                    return newSnapshot.url;
                }
            }
        }
        
        return null;
    }
    
    async findNextPageNumber(snapshot, selector) {
        const elements = this.findElementsBySelector(snapshot, selector);
        
        // Find current page and next page numbers
        let currentPage = 0;
        const pageLinks = [];
        
        for (const element of elements) {
            const text = element.text?.trim();
            const pageNum = parseInt(text);
            
            if (!isNaN(pageNum)) {
                pageLinks.push({
                    number: pageNum,
                    url: element.href,
                    element: element
                });
                
                // Check if this is the current page (often has a different class)
                if (element.className?.includes('active') || 
                    element.className?.includes('current')) {
                    currentPage = pageNum;
                }
            }
        }
        
        // Find next page
        const nextPageNumber = currentPage + 1;
        const nextPageLink = pageLinks.find(link => link.number === nextPageNumber);
        
        return nextPageLink ? this.resolveUrl(nextPageLink.url) : null;
    }
    
    async generateNextUrl(urlPattern, currentPagePattern) {
        const currentUrl = await this.getCurrentUrl();
        
        // Extract current page number
        const match = currentUrl.match(new RegExp(currentPagePattern));
        if (!match) return null;
        
        const currentPageNum = parseInt(match[1]);
        const nextPageNum = currentPageNum + 1;
        
        // Generate next URL
        return urlPattern.replace('{page}', nextPageNum);
    }
    
    async handleInfiniteScroll(selector) {
        let previousHeight = 0;
        let scrollAttempts = 0;
        const maxScrollAttempts = 5;
        
        while (scrollAttempts < maxScrollAttempts) {
            // Get current page height
            const currentHeight = await browser.action('act', {
                kind: 'evaluate',
                fn: 'document.body.scrollHeight'
            });
            
            // Scroll to bottom
            await browser.action('act', {
                kind: 'evaluate',
                fn: 'window.scrollTo(0, document.body.scrollHeight)'
            });
            
            // Wait for new content
            await new Promise(resolve => setTimeout(resolve, 3000));
            
            // Check if new content loaded
            const newHeight = await browser.action('act', {
                kind: 'evaluate',
                fn: 'document.body.scrollHeight'
            });
            
            if (newHeight === previousHeight) {
                scrollAttempts++;
            } else {
                scrollAttempts = 0; // Reset counter if new content loaded
            }
            
            previousHeight = newHeight;
        }
        
        // Return current URL since infinite scroll doesn't change URL
        return await this.getCurrentUrl();
    }
    
    resolveUrl(url) {
        if (!url) return null;
        
        try {
            // Handle relative URLs
            if (url.startsWith('/')) {
                const currentUrl = new URL(window.location.href);
                return `${currentUrl.protocol}//${currentUrl.host}${url}`;
            }
            
            return url;
        } catch {
            return null;
        }
    }
}
```

## HTTP-Based Scraping with web_fetch

For simpler sites without heavy JavaScript, HTTP-based scraping is faster and more reliable.

### Simple Page Fetching

```javascript
// Robust HTTP scraping system
class HTTPScraper {
    constructor(options = {}) {
        this.options = {
            timeout: 30000,
            retryAttempts: 3,
            retryDelay: 1000,
            userAgent: 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
            ...options
        };
        
        this.rateLimiter = new IntelligentRateLimiter();
        this.cache = new Map();
    }
    
    async fetchPage(url, options = {}) {
        const config = { ...this.options, ...options };
        
        // Check cache first
        const cacheKey = `${url}_${JSON.stringify(config)}`;
        const cached = this.cache.get(cacheKey);
        
        if (cached && this.isCacheValid(cached)) {
            return cached.data;
        }
        
        // Check rate limiting
        const waitTime = await this.rateLimiter.shouldWait(url);
        if (waitTime > 0) {
            await new Promise(resolve => setTimeout(resolve, waitTime));
        }
        
        let lastError;
        
        for (let attempt = 1; attempt <= config.retryAttempts; attempt++) {
            try {
                const result = await this.performFetch(url, config);
                
                // Cache successful result
                this.cache.set(cacheKey, {
                    data: result,
                    timestamp: Date.now(),
                    ttl: config.cacheTTL || 300000 // 5 minutes default
                });
                
                return result;
                
            } catch (error) {
                lastError = error;
                
                if (!this.shouldRetry(error, attempt, config.retryAttempts)) {
                    throw error;
                }
                
                const delay = config.retryDelay * Math.pow(2, attempt - 1);
                await new Promise(resolve => setTimeout(resolve, delay));
            }
        }
        
        throw lastError;
    }
    
    async performFetch(url, config) {
        const response = await web_fetch(url, {
            extractMode: 'markdown',
            maxChars: config.maxChars || 1000000
        });
        
        if (response.error) {
            throw new Error(`Fetch error: ${response.error}`);
        }
        
        return {
            url: url,
            content: response.content,
            title: this.extractTitle(response.content),
            headings: this.extractHeadings(response.content),
            links: this.extractLinks(response.content),
            metadata: this.extractMetadata(response.content),
            fetchedAt: Date.now()
        };
    }
    
    shouldRetry(error, attempt, maxAttempts) {
        if (attempt >= maxAttempts) return false;
        
        // Don't retry client errors
        if (error.message.includes('404') || error.message.includes('403')) {
            return false;
        }
        
        // Retry network errors and server errors
        return true;
    }
    
    extractTitle(content) {
        const titleMatch = content.match(/^#\s+(.+)$/m);
        return titleMatch ? titleMatch[1].trim() : null;
    }
    
    extractHeadings(content) {
        const headingRegex = /^(#{1,6})\s+(.+)$/gm;
        const headings = [];
        let match;
        
        while ((match = headingRegex.exec(content)) !== null) {
            headings.push({
                level: match[1].length,
                text: match[2].trim()
            });
        }
        
        return headings;
    }
    
    extractLinks(content) {
        const linkRegex = /\[([^\]]+)\]\(([^)]+)\)/g;
        const links = [];
        let match;
        
        while ((match = linkRegex.exec(content)) !== null) {
            links.push({
                text: match[1],
                url: match[2]
            });
        }
        
        return links;
    }
    
    extractMetadata(content) {
        const metadata = {};
        
        // Look for common metadata patterns
        const metaPatterns = {
            author: /author:\s*(.+)/i,
            date: /date:\s*(.+)/i,
            category: /category:\s*(.+)/i,
            tags: /tags:\s*(.+)/i
        };
        
        for (const [key, pattern] of Object.entries(metaPatterns)) {
            const match = content.match(pattern);
            if (match) {
                metadata[key] = match[1].trim();
            }
        }
        
        return metadata;
    }
}
```

### Parsing HTML to Markdown

```javascript
// Advanced HTML to structured data parser
class HTMLParser {
    constructor() {
        this.structuredExtractors = new Map();
        this.cleaningRules = new Map();
    }
    
    async parseStructuredData(html, schema) {
        // First, clean the HTML
        const cleanedHtml = await this.cleanHtml(html, schema.cleaning);
        
        // Convert to markdown for easier processing
        const markdown = await this.htmlToMarkdown(cleanedHtml);
        
        // Extract structured data based on schema
        const structuredData = await this.extractBySchema(markdown, schema);
        
        return {
            raw: html,
            markdown: markdown,
            structured: structuredData,
            extractedAt: Date.now()
        };
    }
    
    async cleanHtml(html, cleaningRules = {}) {
        let cleaned = html;
        
        // Remove unwanted elements
        const removeElements = cleaningRules.remove || [
            'script', 'style', 'nav', 'header', 'footer',
            '.advertisement', '.sidebar', '.popup'
        ];
        
        for (const selector of removeElements) {
            // Simple regex-based removal (in production, use a proper HTML parser)
            if (selector.startsWith('.')) {
                const className = selector.substring(1);
                cleaned = cleaned.replace(
                    new RegExp(`<[^>]*class="[^"]*${className}[^"]*"[^>]*>.*?</[^>]*>`, 'gis'),
                    ''
                );
            } else {
                cleaned = cleaned.replace(
                    new RegExp(`<${selector}[^>]*>.*?</${selector}>`, 'gis'),
                    ''
                );
            }
        }
        
        // Clean up whitespace
        cleaned = cleaned.replace(/\s+/g, ' ').trim();
        
        return cleaned;
    }
    
    async htmlToMarkdown(html) {
        // Use web_fetch to convert HTML to markdown
        // This is a simplified approach - in production, use a dedicated HTML->Markdown library
        
        const tempFile = `/tmp/html_${Date.now()}.html`;
        await fs.writeFile(tempFile, html);
        
        try {
            const result = await web_fetch(`file://${tempFile}`, {
                extractMode: 'markdown'
            });
            
            return result.content;
        } finally {
            // Clean up temp file
            try {
                await fs.unlink(tempFile);
            } catch {}
        }
    }
    
    async extractBySchema(markdown, schema) {
        const extracted = {};
        
        for (const [fieldName, fieldSchema] of Object.entries(schema.fields)) {
            try {
                extracted[fieldName] = await this.extractField(markdown, fieldSchema);
            } catch (error) {
                console.warn(`Failed to extract field ${fieldName}:`, error.message);
                extracted[fieldName] = fieldSchema.default || null;
            }
        }
        
        return extracted;
    }
    
    async extractField(markdown, fieldSchema) {
        const { type, pattern, multiple, transform } = fieldSchema;
        
        let matches = [];
        
        // Apply extraction pattern
        if (pattern) {
            const regex = new RegExp(pattern, multiple ? 'gi' : 'i');
            const found = markdown.match(regex);
            
            if (found) {
                matches = multiple ? found : [found[0]];
            }
        }
        
        // Apply transformations
        if (transform && matches.length > 0) {
            matches = await Promise.all(
                matches.map(match => this.applyTransform(match, transform))
            );
        }
        
        // Type-specific processing
        switch (type) {
            case 'email':
                matches = matches.filter(email => this.isValidEmail(email));
                break;
            case 'url':
                matches = matches.map(url => this.normalizeUrl(url))
                               .filter(url => this.isValidUrl(url));
                break;
            case 'phone':
                matches = matches.map(phone => this.normalizePhone(phone));
                break;
            case 'date':
                matches = matches.map(date => this.parseDate(date))
                               .filter(date => date !== null);
                break;
        }
        
        return multiple ? matches : (matches[0] || null);
    }
    
    async applyTransform(value, transform) {
        switch (transform.type) {
            case 'trim':
                return value.trim();
                
            case 'lowercase':
                return value.toLowerCase();
                
            case 'regex_extract':
                const match = value.match(new RegExp(transform.pattern));
                return match ? (match[1] || match[0]) : value;
                
            case 'replace':
                return value.replace(
                    new RegExp(transform.from, 'gi'),
                    transform.to
                );
                
            default:
                return value;
        }
    }
}
```

## Building a Complete Scraping Pipeline

Now let's combine everything into a production-grade scraping pipeline.

### Complete Working Example: Company Directory Scraper

```javascript
// Complete company directory scraping system
class CompanyDirectoryScraper {
    constructor(config) {
        this.config = {
            maxCompanies: 1000,
            rateLimitDelay: 2000,
            batchSize: 50,
            ...config
        };
        
        this.httpScraper = new HTTPScraper();
        this.browserScraper = new BrowserScraper();
        this.dataProcessor = new DataProcessor();
        this.storage = new SupabaseStorage();
        this.deduplicator = new Deduplicator();
    }
    
    async scrapeDirectory(directoryUrl, extractionSchema) {
        const pipeline = {
            id: generateUUID(),
            startTime: Date.now(),
            directoryUrl,
            status: 'RUNNING',
            stats: {
                companiesFound: 0,
                companiesProcessed: 0,
                companiesStored: 0,
                errors: 0
            }
        };
        
        try {
            // Phase 1: Discover all company URLs
            const companyUrls = await this.discoverCompanyUrls(directoryUrl);
            pipeline.stats.companiesFound = companyUrls.length;
            
            // Phase 2: Process companies in batches
            const processedCompanies = [];
            
            for (let i = 0; i < companyUrls.length; i += this.config.batchSize) {
                const batch = companyUrls.slice(i, i + this.config.batchSize);
                const batchResults = await this.processBatch(batch, extractionSchema);
                
                processedCompanies.push(...batchResults.success);
                pipeline.stats.errors += batchResults.errors.length;
                
                // Log progress
                console.log(`Processed ${Math.min(i + this.config.batchSize, companyUrls.length)} of ${companyUrls.length} companies`);
            }
            
            pipeline.stats.companiesProcessed = processedCompanies.length;
            
            // Phase 3: Deduplicate
            const uniqueCompanies = await this.deduplicator.deduplicate(processedCompanies);
            
            // Phase 4: Store in database
            const stored = await this.storage.storeBatch(uniqueCompanies);
            pipeline.stats.companiesStored = stored.length;
            
            pipeline.status = 'COMPLETED';
            pipeline.endTime = Date.now();
            pipeline.duration = pipeline.endTime - pipeline.startTime;
            
            return {
                pipeline,
                companies: stored
            };
            
        } catch (error) {
            pipeline.status = 'FAILED';
            pipeline.error = error.message;
            pipeline.endTime = Date.now();
            
            throw error;
        }
    }
    
    async discoverCompanyUrls(directoryUrl) {
        const allUrls = [];
        const paginationConfig = {
            type: 'next_button',
            selector: '.next, .pagination-next, [aria-label="Next"]'
        };
        
        const extractionConfig = {
            fields: {
                companyUrls: {
                    selector: 'a[href*="/company/"], a[href*="/profile/"]',
                    attribute: 'href',
                    multiple: true,
                    required: true
                }
            }
        };
        
        const paginationHandler = new PaginationHandler({
            maxPages: 20,
            delayBetweenPages: 3000
        });
        
        const result = await paginationHandler.scrapeAllPages(
            directoryUrl,
            extractionConfig,
            paginationConfig
        );
        
        // Flatten and deduplicate URLs
        for (const pageData of result.data) {
            if (pageData.companyUrls) {
                allUrls.push(...pageData.companyUrls);
            }
        }
        
        return [...new Set(allUrls)].map(url => this.normalizeUrl(url, directoryUrl));
    }
    
    async processBatch(urls, extractionSchema) {
        const success = [];
        const errors = [];
        
        const promises = urls.map(async (url) => {
            try {
                await new Promise(resolve => 
                    setTimeout(resolve, Math.random() * 1000) // Stagger requests
                );
                
                const companyData = await this.scrapeCompanyData(url, extractionSchema);
                return { success: companyData, url };
            } catch (error) {
                return { error: error.message, url };
            }
        });
        
        const results = await Promise.allSettled(promises);
        
        for (const result of results) {
            if (result.status === 'fulfilled') {
                if (result.value.success) {
                    success.push(result.value.success);
                } else {
                    errors.push(result.value);
                }
            } else {
                errors.push({
                    error: result.reason.message,
                    url: 'unknown'
                });
            }
        }
        
        return { success, errors };
    }
    
    async scrapeCompanyData(url, extractionSchema) {
        // Try HTTP scraping first (faster)
        try {
            const httpResult = await this.httpScraper.fetchPage(url);
            const extractedData = await this.extractCompanyData(
                httpResult.content,
                extractionSchema,
                'markdown'
            );
            
            if (this.isValidCompanyData(extractedData)) {
                return {
                    ...extractedData,
                    sourceUrl: url,
                    scrapingMethod: 'http',
                    scrapedAt: Date.now()
                };
            }
        } catch (error) {
            console.warn(`HTTP scraping failed for ${url}, trying browser:`, error.message);
        }
        
        // Fallback to browser scraping
        try {
            const browserResult = await this.browserScraper.analyzePageStructure(url);
            const extractedData = await this.extractCompanyData(
                browserResult,
                extractionSchema,
                'browser'
            );
            
            return {
                ...extractedData,
                sourceUrl: url,
                scrapingMethod: 'browser',
                scrapedAt: Date.now()
            };
            
        } catch (error) {
            throw new Error(`Both HTTP and browser scraping failed: ${error.message}`);
        }
    }
    
    async extractCompanyData(sourceData, extractionSchema, sourceType) {
        const extractor = new ProductionDataExtractor();
        
        if (sourceType === 'markdown') {
            return await this.extractFromMarkdown(sourceData, extractionSchema);
        } else {
            return await extractor.extractDataFromPage(sourceData.url, extractionSchema);
        }
    }
    
    async extractFromMarkdown(markdown, schema) {
        const extracted = {};
        
        // Company name - usually in the first heading
        const nameMatch = markdown.match(/^#\s+(.+)$/m);
        extracted.name = nameMatch ? nameMatch[1].trim() : null;
        
        // Email extraction
        const emailRegex = /([a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,})/g;
        const emails = markdown.match(emailRegex) || [];
        extracted.email = emails.length > 0 ? emails[0] : null;
        
        // Website extraction
        const websiteRegex = /(https?:\/\/[^\s]+|www\.[^\s]+)/g;
        const websites = markdown.match(websiteRegex) || [];
        extracted.website = websites.length > 0 ? websites[0] : null;
        
        // Phone extraction
        const phoneRegex = /(\+?1?[-.\s]?\(?\d{3}\)?[-.\s]?\d{3}[-.\s]?\d{4})/g;
        const phones = markdown.match(phoneRegex) || [];
        extracted.phone = phones.length > 0 ? phones[0] : null;
        
        // Description - usually the first substantial paragraph
        const paragraphs = markdown.split('\n\n');
        for (const paragraph of paragraphs) {
            if (paragraph.length > 100 && !paragraph.startsWith('#')) {
                extracted.description = paragraph.trim();
                break;
            }
        }
        
        // Industry/Category - look for common patterns
        const industryPatterns = [
            /industry:\s*(.+)/i,
            /category:\s*(.+)/i,
            /sector:\s*(.+)/i
        ];
        
        for (const pattern of industryPatterns) {
            const match = markdown.match(pattern);
            if (match) {
                extracted.industry = match[1].trim();
                break;
            }
        }
        
        return extracted;
    }
    
    isValidCompanyData(data) {
        // Validate that we have minimum required data
        return data.name && (data.email || data.website || data.phone);
    }
    
    normalizeUrl(url, baseUrl) {
        try {
            if (url.startsWith('/')) {
                const base = new URL(baseUrl);
                return `${base.protocol}//${base.host}${url}`;
            }
            return url;
        } catch {
            return url;
        }
    }
}
```

### Storage Schema in Supabase

```sql
-- Company data table
CREATE TABLE companies (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT,
    website TEXT,
    phone TEXT,
    description TEXT,
    industry TEXT,
    source_url TEXT NOT NULL,
    scraping_method TEXT CHECK (scraping_method IN ('http', 'browser')),
    scraped_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Deduplication fields
    name_hash TEXT GENERATED ALWAYS AS (md5(lower(trim(name)))) STORED,
    domain TEXT GENERATED ALWAYS AS (
        CASE 
            WHEN website IS NOT NULL THEN 
                regexp_replace(
                    regexp_replace(website, '^https?://', '', 'i'),
                    '^www\.', '', 'i'
                )
            WHEN email IS NOT NULL THEN 
                split_part(email, '@', 2)
            ELSE NULL
        END
    ) STORED
);

-- Indexes for performance
CREATE INDEX idx_companies_name_hash ON companies (name_hash);
CREATE INDEX idx_companies_domain ON companies (domain);
CREATE INDEX idx_companies_scraped_at ON companies (scraped_at);
CREATE INDEX idx_companies_industry ON companies (industry);

-- Scraping pipeline logs
CREATE TABLE scraping_pipelines (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    directory_url TEXT NOT NULL,
    status TEXT CHECK (status IN ('RUNNING', 'COMPLETED', 'FAILED')),
    start_time TIMESTAMP WITH TIME ZONE NOT NULL,
    end_time TIMESTAMP WITH TIME ZONE,
    duration_ms INTEGER,
    companies_found INTEGER,
    companies_processed INTEGER,
    companies_stored INTEGER,
    error_count INTEGER,
    error_message TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### Deduplication Logic

```javascript
// Advanced deduplication system
class Deduplicator {
    constructor(supabaseClient) {
        this.supabase = supabaseClient;
        this.similarityThreshold = 0.8;
    }
    
    async deduplicate(companies) {
        const unique = [];
        const duplicates = [];
        
        for (const company of companies) {
            const isDuplicate = await this.checkForDuplicate(company, unique);
            
            if (isDuplicate) {
                duplicates.push({
                    company,
                    duplicate: isDuplicate,
                    reason: isDuplicate.reason
                });
            } else {
                unique.push(company);
            }
        }
        
        // Log deduplication results
        console.log(`Deduplication complete: ${unique.length} unique, ${duplicates.length} duplicates`);
        
        return {
            unique,
            duplicates,
            deduplicationRate: duplicates.length / companies.length
        };
    }
    
    async checkForDuplicate(company, existingCompanies) {
        // Check against existing companies in batch
        for (const existing of existingCompanies) {
            const similarity = this.calculateSimilarity(company, existing);
            
            if (similarity.score > this.similarityThreshold) {
                return {
                    existing,
                    score: similarity.score,
                    reason: similarity.reason
                };
            }
        }
        
        // Check against database
        const dbDuplicate = await this.checkDatabaseForDuplicate(company);
        if (dbDuplicate) {
            return dbDuplicate;
        }
        
        return null;
    }
    
    calculateSimilarity(company1, company2) {
        let score = 0;
        const factors = [];
        
        // Exact name match
        if (company1.name && company2.name) {
            const name1 = this.normalizeName(company1.name);
            const name2 = this.normalizeName(company2.name);
            
            if (name1 === name2) {
                score += 0.5;
                factors.push('exact_name_match');
            } else {
                const nameScore = this.calculateStringSimilarity(name1, name2);
                if (nameScore > 0.8) {
                    score += nameScore * 0.4;
                    factors.push('similar_name');
                }
            }
        }
        
        // Domain match
        const domain1 = this.extractDomain(company1);
        const domain2 = this.extractDomain(company2);
        
        if (domain1 && domain2 && domain1 === domain2) {
            score += 0.4;
            factors.push('same_domain');
        }
        
        // Email domain match
        if (company1.email && company2.email) {
            const emailDomain1 = company1.email.split('@')[1];
            const emailDomain2 = company2.email.split('@')[1];
            
            if (emailDomain1 === emailDomain2) {
                score += 0.3;
                factors.push('same_email_domain');
            }
        }
        
        // Phone similarity
        if (company1.phone && company2.phone) {
            const phone1 = this.normalizePhone(company1.phone);
            const phone2 = this.normalizePhone(company2.phone);
            
            if (phone1 === phone2) {
                score += 0.2;
                factors.push('same_phone');
            }
        }
        
        return {
            score: Math.min(1, score),
            reason: factors.join(', ')
        };
    }
    
    normalizeName(name) {
        return name
            .toLowerCase()
            .replace(/[^a-z0-9\s]/g, '')
            .replace(/\b(inc|llc|ltd|corp|corporation|company|co)\b/g, '')
            .replace(/\s+/g, ' ')
            .trim();
    }
    
    extractDomain(company) {
        if (company.website) {
            try {
                const url = new URL(company.website.startsWith('http') 
                    ? company.website 
                    : `https://${company.website}`
                );
                return url.hostname.replace(/^www\./, '');
            } catch {}
        }
        
        if (company.email) {
            return company.email.split('@')[1];
        }
        
        return null;
    }
    
    normalizePhone(phone) {
        return phone.replace(/[^\d]/g, '');
    }
    
    calculateStringSimilarity(str1, str2) {
        const longer = str1.length > str2.length ? str1 : str2;
        const shorter = str1.length > str2.length ? str2 : str1;
        
        if (longer.length === 0) return 1.0;
        
        const distance = this.levenshteinDistance(longer, shorter);
        return (longer.length - distance) / longer.length;
    }
    
    levenshteinDistance(str1, str2) {
        const matrix = [];
        
        for (let i = 0; i <= str2.length; i++) {
            matrix[i] = [i];
        }
        
        for (let j = 0; j <= str1.length; j++) {
            matrix[0][j] = j;
        }
        
        for (let i = 1; i <= str2.length; i++) {
            for (let j = 1; j <= str1.length; j++) {
                if (str2.charAt(i - 1) === str1.charAt(j - 1)) {
                    matrix[i][j] = matrix[i - 1][j - 1];
                } else {
                    matrix[i][j] = Math.min(
                        matrix[i - 1][j - 1] + 1,
                        matrix[i][j - 1] + 1,
                        matrix[i - 1][j] + 1
                    );
                }
            }
        }
        
        return matrix[str2.length][str1.length];
    }
    
    async checkDatabaseForDuplicate(company) {
        const domain = this.extractDomain(company);
        const nameHash = this.generateNameHash(company.name);
        
        let query = this.supabase
            .from('companies')
            .select('id, name, email, website, phone');
        
        // Build OR conditions for potential duplicates
        const orConditions = [];
        
        if (domain) {
            orConditions.push(`domain.eq.${domain}`);
        }
        
        if (nameHash) {
            orConditions.push(`name_hash.eq.${nameHash}`);
        }
        
        if (orConditions.length === 0) return null;
        
        const { data, error } = await query.or(orConditions.join(','));
        
        if (error || !data || data.length === 0) return null;
        
        // Check each result for actual similarity
        for (const existing of data) {
            const similarity = this.calculateSimilarity(company, existing);
            
            if (similarity.score > this.similarityThreshold) {
                return {
                    existing,
                    score: similarity.score,
                    reason: similarity.reason
                };
            }
        }
        
        return null;
    }
    
    generateNameHash(name) {
        if (!name) return null;
        
        const normalized = this.normalizeName(name);
        return crypto.createHash('md5').update(normalized).digest('hex');
    }
}
```

## Troubleshooting Common Scraping Issues

### Issue 1: JavaScript-Heavy Sites Not Loading Content

**Symptom:** HTTP scraping returns empty or incomplete data.

**Cause:** Site renders content client-side with JavaScript.

**Solution:**
```javascript
// Detect JavaScript-dependent sites
class JavaScriptDetector {
    async detectJSRequirement(url) {
        // Compare HTTP vs Browser results
        const httpResult = await web_fetch(url);
        const browserSnapshot = await browser.snapshot();
        
        const httpContentLength = httpResult.content?.length || 0;
        const browserContentLength = browserSnapshot.text?.length || 0;
        
        const ratio = httpContentLength / Math.max(browserContentLength, 1);
        
        return {
            requiresJS: ratio < 0.5,
            httpLength: httpContentLength,
            browserLength: browserContentLength,
            recommendation: ratio < 0.5 ? 'Use browser scraping' : 'HTTP scraping sufficient'
        };
    }
}
```

### Issue 2: IP Blocking or Rate Limiting

**Symptom:** Requests return 429, 403, or connection timeouts.

**Cause:** Too many requests too quickly.

**Solution:**
```javascript
// IP rotation and proxy system
class ProxyRotator {
    constructor(proxies) {
        this.proxies = proxies;
        this.currentIndex = 0;
        this.blacklistedProxies = new Set();
    }
    
    getNextProxy() {
        const availableProxies = this.proxies.filter(
            proxy => !this.blacklistedProxies.has(proxy)
        );
        
        if (availableProxies.length === 0) {
            // Reset blacklist if all proxies are blocked
            this.blacklistedProxies.clear();
            return this.proxies[0];
        }
        
        const proxy = availableProxies[this.currentIndex % availableProxies.length];
        this.currentIndex++;
        
        return proxy;
    }
    
    async testProxy(proxy) {
        try {
            const response = await fetch('http://httpbin.org/ip', {
                proxy: proxy,
                timeout: 10000
            });
            
            return response.ok;
        } catch {
            return false;
        }
    }
}
```

### Issue 3: CAPTCHAs and Bot Detection

**Symptom:** Site shows CAPTCHA or "Access Denied" pages.

**Cause:** Anti-bot systems detecting automated behavior.

**Solution:**
```javascript
// CAPTCHA handling system
class CaptchaHandler {
    async handleCaptchaChallenge(snapshot) {
        const hasCaptcha = this.detectCaptcha(snapshot);
        
        if (!hasCaptcha) return { handled: false };
        
        // Try to solve automatically (for testing only)
        const solution = await this.attemptAutoSolve(snapshot);
        
        if (solution.success) {
            await this.submitCaptchaSolution(solution);
            return { handled: true, method: 'auto' };
        }
        
        // Escalate to human if auto-solve fails
        await this.requestHumanSolution(snapshot);
        return { handled: true, method: 'human' };
    }
    
    detectCaptcha(snapshot) {
        const indicators = [
            'recaptcha',
            'captcha',
            'verify you are human',
            'security check',
            'prove you are not a robot'
        ];
        
        const text = snapshot.text?.toLowerCase() || '';
        return indicators.some(indicator => text.includes(indicator));
    }
}
```

### Issue 4: Dynamic Content Loading

**Symptom:** Content appears after initial page load.

**Cause:** AJAX requests or infinite scroll.

**Solution:**
```javascript
// Dynamic content waiter
class ContentWaiter {
    async waitForDynamicContent(selector, maxWait = 30000) {
        const startTime = Date.now();
        let lastContentLength = 0;
        let stableCount = 0;
        
        while (Date.now() - startTime < maxWait) {
            const snapshot = await browser.snapshot();
            const currentLength = snapshot.text?.length || 0;
            
            if (currentLength === lastContentLength) {
                stableCount++;
            } else {
                stableCount = 0;
                lastContentLength = currentLength;
            }
            
            // Content stable for 3 consecutive checks
            if (stableCount >= 3) {
                return true;
            }
            
            await new Promise(resolve => setTimeout(resolve, 1000));
        }
        
        return false; // Timeout reached
    }
}
```

### Issue 5: Data Quality Issues

**Symptom:** Extracted data is incomplete or malformed.

**Cause:** Poor extraction patterns or site structure changes.

**Solution:**
```javascript
// Data quality monitor
class DataQualityMonitor {
    constructor() {
        this.qualityMetrics = new Map();
    }
    
    async assessDataQuality(extractedData, expectedSchema) {
        const quality = {
            completeness: this.calculateCompleteness(extractedData, expectedSchema),
            validity: this.validateDataTypes(extractedData, expectedSchema),
            consistency: this.checkConsistency(extractedData),
            freshness: this.checkFreshness(extractedData)
        };
        
        const overallScore = (
            quality.completeness * 0.3 +
            quality.validity * 0.3 +
            quality.consistency * 0.2 +
            quality.freshness * 0.2
        );
        
        if (overallScore < 0.7) {
            await this.alertPoorQuality(quality, extractedData);
        }
        
        return { ...quality, overallScore };
    }
    
    calculateCompleteness(data, schema) {
        const requiredFields = Object.entries(schema.fields)
            .filter(([_, config]) => config.required)
            .map(([name, _]) => name);
        
        const presentFields = requiredFields.filter(
            field => data[field] && data[field] !== null && data[field] !== ''
        );
        
        return requiredFields.length > 0 ? presentFields.length / requiredFields.length : 1;
    }
}
```

## Scheduling Scraping Jobs with Cron

```bash
# Daily company scraping at 2 AM
0 2 * * * /usr/local/bin/openclaw cron "Run daily company directory scraping pipeline"

# Weekly data quality check on Sundays at 6 AM  
0 6 * * 0 /usr/local/bin/openclaw cron "Analyze scraping data quality and clean duplicates"

# Hourly rate limit reset for blocked domains
0 * * * * /usr/local/bin/openclaw cron "Check and reset rate limits for blocked domains"
```

## Pro Tips for Professional Scraping

**Tip 1: Always Check Legal First**
Before scraping any site, verify: robots.txt, terms of service, and relevant laws in your jurisdiction.

**Tip 2: Respect Rate Limits Aggressively**
Better to scrape slowly than get IP banned. Implement delays 2-3x longer than you think you need.

**Tip 3: Monitor Data Quality Continuously**
Set up alerts for when extraction patterns break. Sites change constantly.

**Tip 4: Build Multiple Extraction Strategies**
Always have fallbacks. HTTP → Browser → Manual escalation.

**Tip 5: Cache Everything Reasonably**
Don't re-scrape the same page multiple times. Implement intelligent caching.

**Tip 6: Document Your Patterns**
When extraction breaks, you need to know exactly what changed and how to fix it quickly.

---

Web scraping is the foundation of every data-driven autonomous system. Master these patterns and you have unlimited access to the world's information—ethically and sustainably.

The next chapter will show you how to turn this raw scraped data into qualified leads through intelligent pipeline automation.