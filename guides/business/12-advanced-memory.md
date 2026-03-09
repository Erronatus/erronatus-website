# Chapter 12: Advanced Memory Architecture
## Build a System That Remembers Everything That Matters

*Most AI systems are digital goldfish — they forget everything the moment the conversation ends. This chapter shows you how to build persistent memory systems that accumulate knowledge, track context across sessions, and learn from every interaction. The difference between a stateless chatbot and an intelligent system that builds on its past is the difference between a tool and an employee.*

### Why This Matters

Memory is what turns automation into intelligence. Without memory:
- Every session starts from zero
- You repeat the same explanations endlessly
- Important context gets lost
- Patterns remain undetected
- Mistakes get repeated

With proper memory architecture:
- Systems learn from experience
- Context persists across sessions
- Knowledge compounds over time
- Patterns emerge automatically
- Intelligence increases with usage

The businesses that win with AI don't just use it — they build systems that get smarter with every interaction.

## Beyond Basic Files: Structured Memory Systems

The Personal Edition introduced basic memory with daily files and MEMORY.md. The Business Edition requires enterprise-grade memory architecture that scales with complexity.

### Memory Types and Purposes

**1. Active Context (RAM-equivalent)**
- Current session state
- Immediate operational context
- Temporary calculations
- Working variables

**2. Session Memory (Cache-equivalent)**
- Recent conversation history
- Current workflow state
- Temporary insights
- Session-specific data

**3. Persistent Memory (Database-equivalent)**
- Long-term knowledge
- Historical patterns
- Accumulated insights
- Business intelligence

**4. Archived Memory (Cold Storage-equivalent)**
- Historical records
- Completed projects
- Old configurations
- Audit trails

## Active Context Files (JSON State)

Replace scattered variables with structured state management:

```javascript
// ~/.openclaw/workspace/memory/active-context.js
const fs = require('fs');
const path = require('path');

class ActiveContext {
    constructor() {
        this.contextFile = path.join(process.env.HOME, '.openclaw/workspace/memory/active-context.json');
        this.context = this.load();
        this.autosaveInterval = 30000; // Save every 30 seconds
        
        // Auto-save on changes
        this.startAutosave();
    }

    load() {
        try {
            if (fs.existsSync(this.contextFile)) {
                const data = fs.readFileSync(this.contextFile, 'utf8');
                return JSON.parse(data);
            }
        } catch (error) {
            console.error('Failed to load active context:', error.message);
        }

        // Default context structure
        return {
            session: {
                id: this.generateSessionId(),
                startTime: new Date().toISOString(),
                currentTask: null,
                workingDirectory: process.env.HOME + '/.openclaw/workspace',
                model: 'claude-3-5-sonnet-20241022'
            },
            workflow: {
                currentPhase: 'idle',
                completedSteps: [],
                pendingTasks: [],
                blockers: []
            },
            data: {
                calculations: {},
                tempResults: {},
                userPreferences: {},
                recentQueries: []
            },
            performance: {
                apiCalls: 0,
                tokensUsed: 0,
                costToday: 0,
                averageResponseTime: 0
            },
            flags: {
                debugMode: false,
                verboseLogging: false,
                autoCommit: true,
                maintenanceMode: false
            }
        };
    }

    save() {
        try {
            // Ensure directory exists
            const dir = path.dirname(this.contextFile);
            if (!fs.existsSync(dir)) {
                fs.mkdirSync(dir, { recursive: true });
            }

            // Update metadata
            this.context.session.lastSaved = new Date().toISOString();
            
            fs.writeFileSync(this.contextFile, JSON.stringify(this.context, null, 2));
        } catch (error) {
            console.error('Failed to save active context:', error.message);
        }
    }

    startAutosave() {
        setInterval(() => {
            this.save();
        }, this.autosaveInterval);
    }

    // Context management methods
    setCurrentTask(task, priority = 'normal') {
        this.context.workflow.currentPhase = 'active';
        this.context.session.currentTask = {
            description: task,
            priority,
            startTime: new Date().toISOString()
        };
        this.save();
    }

    completeStep(step, result = null) {
        this.context.workflow.completedSteps.push({
            step,
            completedAt: new Date().toISOString(),
            result
        });
        
        // Remove from pending if it was there
        this.context.workflow.pendingTasks = this.context.workflow.pendingTasks
            .filter(task => task.description !== step);
            
        this.save();
    }

    addPendingTask(task, priority = 'normal', dueDate = null) {
        this.context.workflow.pendingTasks.push({
            description: task,
            priority,
            addedAt: new Date().toISOString(),
            dueDate
        });
        this.save();
    }

    addBlocker(issue, severity = 'medium') {
        this.context.workflow.blockers.push({
            issue,
            severity,
            addedAt: new Date().toISOString(),
            resolved: false
        });
        this.save();
    }

    resolveBlocker(issue) {
        const blocker = this.context.workflow.blockers.find(b => b.issue === issue);
        if (blocker) {
            blocker.resolved = true;
            blocker.resolvedAt = new Date().toISOString();
            this.save();
        }
    }

    storeCalculation(key, calculation) {
        this.context.data.calculations[key] = {
            result: calculation,
            timestamp: new Date().toISOString()
        };
        this.save();
    }

    getCalculation(key) {
        return this.context.data.calculations[key];
    }

    updatePerformance(metrics) {
        Object.assign(this.context.performance, metrics);
        this.save();
    }

    logQuery(query, result, responseTime) {
        this.context.data.recentQueries.push({
            query,
            result: result?.substring(0, 200) + '...', // Truncate long results
            responseTime,
            timestamp: new Date().toISOString()
        });

        // Keep only last 10 queries
        if (this.context.data.recentQueries.length > 10) {
            this.context.data.recentQueries = this.context.data.recentQueries.slice(-10);
        }

        this.save();
    }

    generateSessionId() {
        return 'session_' + Date.now() + '_' + Math.random().toString(36).substr(2, 9);
    }

    getContext() {
        return this.context;
    }

    reset() {
        this.context = this.load();
        this.context.session.id = this.generateSessionId();
        this.context.session.startTime = new Date().toISOString();
        this.save();
    }
}

module.exports = ActiveContext;
```

## Task Queue System

Manage pending work across sessions with a robust task queue:

```javascript
// ~/.openclaw/workspace/memory/task-queue.js
const fs = require('fs');
const path = require('path');

class TaskQueue {
    constructor() {
        this.queueFile = path.join(process.env.HOME, '.openclaw/workspace/memory/task-queue.json');
        this.queue = this.load();
    }

    load() {
        try {
            if (fs.existsSync(this.queueFile)) {
                const data = fs.readFileSync(this.queueFile, 'utf8');
                const parsed = JSON.parse(data);
                
                // Clean up expired tasks
                return parsed.filter(task => !this.isExpired(task));
            }
        } catch (error) {
            console.error('Failed to load task queue:', error.message);
        }
        return [];
    }

    save() {
        try {
            const dir = path.dirname(this.queueFile);
            if (!fs.existsSync(dir)) {
                fs.mkdirSync(dir, { recursive: true });
            }
            
            fs.writeFileSync(this.queueFile, JSON.stringify(this.queue, null, 2));
        } catch (error) {
            console.error('Failed to save task queue:', error.message);
        }
    }

    add(task, priority = 'normal', dueDate = null, context = {}) {
        const newTask = {
            id: this.generateTaskId(),
            description: task,
            priority, // 'low', 'normal', 'high', 'urgent'
            status: 'pending',
            createdAt: new Date().toISOString(),
            dueDate,
            context,
            attempts: 0,
            maxAttempts: 3
        };

        this.queue.push(newTask);
        this.save();
        
        return newTask.id;
    }

    get(id) {
        return this.queue.find(task => task.id === id);
    }

    getNext(priorityFilter = null) {
        const availableTasks = this.queue.filter(task => 
            task.status === 'pending' && 
            task.attempts < task.maxAttempts &&
            (priorityFilter ? task.priority === priorityFilter : true)
        );

        if (availableTasks.length === 0) return null;

        // Sort by priority then by creation date
        const priorityOrder = { 'urgent': 4, 'high': 3, 'normal': 2, 'low': 1 };
        
        availableTasks.sort((a, b) => {
            if (priorityOrder[b.priority] !== priorityOrder[a.priority]) {
                return priorityOrder[b.priority] - priorityOrder[a.priority];
            }
            return new Date(a.createdAt) - new Date(b.createdAt);
        });

        return availableTasks[0];
    }

    startWork(id) {
        const task = this.get(id);
        if (!task) return false;

        task.status = 'in_progress';
        task.startedAt = new Date().toISOString();
        task.attempts++;
        
        this.save();
        return true;
    }

    complete(id, result = null) {
        const task = this.get(id);
        if (!task) return false;

        task.status = 'completed';
        task.completedAt = new Date().toISOString();
        task.result = result;
        
        this.save();
        return true;
    }

    fail(id, error, retry = true) {
        const task = this.get(id);
        if (!task) return false;

        if (retry && task.attempts < task.maxAttempts) {
            task.status = 'pending';
            task.lastError = error;
            task.lastFailedAt = new Date().toISOString();
        } else {
            task.status = 'failed';
            task.failedAt = new Date().toISOString();
            task.finalError = error;
        }
        
        this.save();
        return true;
    }

    cancel(id) {
        const task = this.get(id);
        if (!task) return false;

        task.status = 'cancelled';
        task.cancelledAt = new Date().toISOString();
        
        this.save();
        return true;
    }

    getByStatus(status) {
        return this.queue.filter(task => task.status === status);
    }

    getOverdue() {
        const now = new Date();
        return this.queue.filter(task => 
            task.dueDate && 
            new Date(task.dueDate) < now && 
            task.status === 'pending'
        );
    }

    cleanup(olderThanDays = 30) {
        const cutoff = new Date(Date.now() - olderThanDays * 24 * 60 * 60 * 1000);
        const originalLength = this.queue.length;
        
        this.queue = this.queue.filter(task => {
            // Keep if not completed/failed or if recent
            return (task.status === 'pending' || task.status === 'in_progress') ||
                   new Date(task.createdAt) > cutoff;
        });

        if (this.queue.length < originalLength) {
            this.save();
            console.log(`Cleaned up ${originalLength - this.queue.length} old tasks`);
        }
    }

    getStats() {
        const stats = {
            total: this.queue.length,
            pending: 0,
            in_progress: 0,
            completed: 0,
            failed: 0,
            cancelled: 0,
            overdue: this.getOverdue().length
        };

        this.queue.forEach(task => {
            stats[task.status]++;
        });

        return stats;
    }

    isExpired(task) {
        // Tasks expire after 7 days if failed or cancelled
        if (task.status === 'failed' || task.status === 'cancelled') {
            const sevenDaysAgo = new Date(Date.now() - 7 * 24 * 60 * 60 * 1000);
            return new Date(task.createdAt) < sevenDaysAgo;
        }
        return false;
    }

    generateTaskId() {
        return 'task_' + Date.now() + '_' + Math.random().toString(36).substr(2, 9);
    }
}

module.exports = TaskQueue;
```

## Credential Vault Pattern

Store sensitive references without exposing secrets in memory:

```javascript
// ~/.openclaw/workspace/memory/credential-vault.js
const fs = require('fs');
const path = require('path');
const crypto = require('crypto');

class CredentialVault {
    constructor() {
        this.vaultFile = path.join(process.env.HOME, '.openclaw/workspace/memory/credential-vault.json');
        this.vault = this.load();
    }

    load() {
        try {
            if (fs.existsSync(this.vaultFile)) {
                const data = fs.readFileSync(this.vaultFile, 'utf8');
                return JSON.parse(data);
            }
        } catch (error) {
            console.error('Failed to load credential vault:', error.message);
        }
        
        return {
            references: {}, // Map of reference keys to environment variable names
            metadata: {},   // Non-sensitive metadata about credentials
            rotation: {}    // Key rotation tracking
        };
    }

    save() {
        try {
            const dir = path.dirname(this.vaultFile);
            if (!fs.existsSync(dir)) {
                fs.mkdirSync(dir, { recursive: true });
            }
            
            fs.writeFileSync(this.vaultFile, JSON.stringify(this.vault, null, 2));
        } catch (error) {
            console.error('Failed to save credential vault:', error.message);
        }
    }

    // Register a credential reference
    registerCredential(key, envVarName, metadata = {}) {
        this.vault.references[key] = envVarName;
        this.vault.metadata[key] = {
            description: metadata.description || '',
            service: metadata.service || '',
            scopes: metadata.scopes || [],
            createdAt: new Date().toISOString(),
            lastVerified: null,
            expiresAt: metadata.expiresAt || null,
            rotationInterval: metadata.rotationInterval || null // days
        };
        
        this.save();
    }

    // Get credential value (reads from environment)
    getCredential(key) {
        const envVarName = this.vault.references[key];
        if (!envVarName) {
            throw new Error(`Credential reference '${key}' not found`);
        }
        
        const value = process.env[envVarName];
        if (!value) {
            throw new Error(`Environment variable '${envVarName}' not set`);
        }
        
        // Update last accessed time
        this.vault.metadata[key].lastAccessed = new Date().toISOString();
        this.save();
        
        return value;
    }

    // Verify credential is accessible (without exposing value)
    verifyCredential(key) {
        try {
            this.getCredential(key);
            this.vault.metadata[key].lastVerified = new Date().toISOString();
            this.save();
            return true;
        } catch (error) {
            return false;
        }
    }

    // List all credential references (safe - no values)
    listCredentials() {
        return Object.keys(this.vault.references).map(key => ({
            key,
            service: this.vault.metadata[key]?.service,
            description: this.vault.metadata[key]?.description,
            lastVerified: this.vault.metadata[key]?.lastVerified,
            needsRotation: this.needsRotation(key)
        }));
    }

    // Check if credential needs rotation
    needsRotation(key) {
        const metadata = this.vault.metadata[key];
        if (!metadata || !metadata.rotationInterval) return false;

        const rotationDate = new Date(metadata.createdAt);
        rotationDate.setDate(rotationDate.getDate() + metadata.rotationInterval);
        
        return new Date() > rotationDate;
    }

    // Get credentials that need rotation
    getRotationCandidates() {
        return this.listCredentials().filter(cred => cred.needsRotation);
    }

    // Mark credential as rotated
    markRotated(key) {
        if (this.vault.metadata[key]) {
            this.vault.metadata[key].lastRotated = new Date().toISOString();
            this.vault.metadata[key].createdAt = new Date().toISOString(); // Reset rotation timer
            this.save();
        }
    }

    // Verify all credentials are accessible
    verifyAll() {
        const results = {};
        
        for (const key of Object.keys(this.vault.references)) {
            results[key] = this.verifyCredential(key);
        }
        
        return results;
    }

    // Get credential metadata (safe)
    getMetadata(key) {
        return this.vault.metadata[key] || null;
    }

    // Generate secure reference key
    generateReference(service, description) {
        const base = `${service}_${description}`.toLowerCase()
            .replace(/[^a-z0-9]/g, '_')
            .replace(/_+/g, '_');
        
        const hash = crypto.createHash('md5')
            .update(`${base}_${Date.now()}`)
            .digest('hex')
            .substring(0, 8);
            
        return `${base}_${hash}`;
    }
}

// Usage example with common business APIs
function setupBusinessCredentials() {
    const vault = new CredentialVault();
    
    // Register all business credentials
    vault.registerCredential('openai_api', 'OPENAI_API_KEY', {
        service: 'OpenAI',
        description: 'Primary AI model access',
        rotationInterval: 90
    });
    
    vault.registerCredential('stripe_live', 'STRIPE_SECRET_KEY', {
        service: 'Stripe',
        description: 'Live payment processing',
        rotationInterval: 180
    });
    
    vault.registerCredential('database_url', 'SUPABASE_URL', {
        service: 'Supabase',
        description: 'Database connection',
        rotationInterval: null // No rotation needed
    });
    
    vault.registerCredential('email_api', 'RESEND_API_KEY', {
        service: 'Resend',
        description: 'Transactional email sending',
        rotationInterval: 60
    });
    
    return vault;
}

module.exports = { CredentialVault, setupBusinessCredentials };
```

## Memory Search System

Implement semantic search across all memory files:

```javascript
// ~/.openclaw/workspace/memory/memory-search.js
const fs = require('fs');
const path = require('path');
const { glob } = require('glob');

class MemorySearch {
    constructor() {
        this.memoryDir = path.join(process.env.HOME, '.openclaw/workspace/memory');
        this.indexFile = path.join(this.memoryDir, 'search-index.json');
        this.index = this.loadIndex();
    }

    loadIndex() {
        try {
            if (fs.existsSync(this.indexFile)) {
                return JSON.parse(fs.readFileSync(this.indexFile, 'utf8'));
            }
        } catch (error) {
            console.error('Failed to load search index:', error.message);
        }
        
        return {
            files: {},
            keywords: {},
            lastUpdated: null
        };
    }

    saveIndex() {
        try {
            fs.writeFileSync(this.indexFile, JSON.stringify(this.index, null, 2));
        } catch (error) {
            console.error('Failed to save search index:', error.message);
        }
    }

    // Build search index from all memory files
    async buildIndex() {
        console.log('🔍 Building memory search index...');
        
        this.index = { files: {}, keywords: {}, lastUpdated: new Date().toISOString() };
        
        // Find all memory files
        const patterns = [
            `${this.memoryDir}/**/*.md`,
            `${this.memoryDir}/**/*.json`,
            `${this.memoryDir}/**/*.txt`
        ];
        
        const files = [];
        for (const pattern of patterns) {
            const matches = await glob(pattern);
            files.push(...matches);
        }
        
        // Index each file
        for (const filePath of files) {
            await this.indexFile(filePath);
        }
        
        this.saveIndex();
        console.log(`✅ Indexed ${Object.keys(this.index.files).length} files with ${Object.keys(this.index.keywords).length} unique keywords`);
    }

    async indexFile(filePath) {
        try {
            const stats = fs.statSync(filePath);
            const content = fs.readFileSync(filePath, 'utf8');
            
            const fileInfo = {
                path: filePath,
                size: stats.size,
                modified: stats.mtime.toISOString(),
                wordCount: content.split(/\s+/).length,
                lines: content.split('\n').length
            };

            // Extract keywords and phrases
            const keywords = this.extractKeywords(content);
            const phrases = this.extractPhrases(content);
            
            fileInfo.keywords = keywords;
            fileInfo.phrases = phrases;
            
            // Store file info
            this.index.files[filePath] = fileInfo;
            
            // Update keyword index
            [...keywords, ...phrases].forEach(keyword => {
                if (!this.index.keywords[keyword]) {
                    this.index.keywords[keyword] = [];
                }
                
                if (!this.index.keywords[keyword].includes(filePath)) {
                    this.index.keywords[keyword].push(filePath);
                }
            });
            
        } catch (error) {
            console.error(`Failed to index ${filePath}:`, error.message);
        }
    }

    extractKeywords(content) {
        // Remove common words and extract meaningful terms
        const stopWords = new Set([
            'the', 'a', 'an', 'and', 'or', 'but', 'in', 'on', 'at', 'to', 'for', 'of', 'with', 
            'by', 'is', 'are', 'was', 'were', 'be', 'been', 'being', 'have', 'has', 'had',
            'do', 'does', 'did', 'will', 'would', 'could', 'should', 'may', 'might', 'can',
            'this', 'that', 'these', 'those', 'i', 'you', 'he', 'she', 'it', 'we', 'they'
        ]);
        
        const words = content.toLowerCase()
            .replace(/[^\w\s]/g, ' ')
            .split(/\s+/)
            .filter(word => word.length > 3 && !stopWords.has(word));
        
        // Count frequency and return top keywords
        const wordCounts = {};
        words.forEach(word => {
            wordCounts[word] = (wordCounts[word] || 0) + 1;
        });
        
        return Object.entries(wordCounts)
            .filter(([word, count]) => count > 1)
            .sort(([,a], [,b]) => b - a)
            .slice(0, 50)
            .map(([word]) => word);
    }

    extractPhrases(content) {
        // Extract common phrases (2-3 words)
        const sentences = content.split(/[.!?]+/);
        const phrases = new Set();
        
        sentences.forEach(sentence => {
            const words = sentence.toLowerCase()
                .replace(/[^\w\s]/g, ' ')
                .split(/\s+/)
                .filter(word => word.length > 2);
            
            // Extract 2-word phrases
            for (let i = 0; i < words.length - 1; i++) {
                const phrase = words[i] + ' ' + words[i + 1];
                if (phrase.length > 8) phrases.add(phrase);
            }
            
            // Extract 3-word phrases
            for (let i = 0; i < words.length - 2; i++) {
                const phrase = words[i] + ' ' + words[i + 1] + ' ' + words[i + 2];
                if (phrase.length > 12) phrases.add(phrase);
            }
        });
        
        return Array.from(phrases).slice(0, 20);
    }

    // Search memory files
    search(query, options = {}) {
        const {
            maxResults = 20,
            fileTypes = ['md', 'json', 'txt'],
            scoreThreshold = 0.1
        } = options;
        
        const queryTerms = query.toLowerCase().split(/\s+/);
        const results = [];
        
        Object.entries(this.index.files).forEach(([filePath, fileInfo]) => {
            // Check file type filter
            const ext = path.extname(filePath).substring(1);
            if (!fileTypes.includes(ext)) return;
            
            let score = 0;
            const matchedTerms = [];
            
            queryTerms.forEach(term => {
                // Check keywords
                const keywordMatches = fileInfo.keywords.filter(keyword => 
                    keyword.includes(term) || term.includes(keyword)
                );
                if (keywordMatches.length > 0) {
                    score += keywordMatches.length * 2;
                    matchedTerms.push(...keywordMatches);
                }
                
                // Check phrases
                const phraseMatches = fileInfo.phrases.filter(phrase => 
                    phrase.includes(term)
                );
                if (phraseMatches.length > 0) {
                    score += phraseMatches.length * 3;
                    matchedTerms.push(...phraseMatches);
                }
                
                // Check file path
                if (filePath.toLowerCase().includes(term)) {
                    score += 1;
                }
            });
            
            // Normalize score by file size (prefer concise, relevant content)
            const normalizedScore = score / Math.sqrt(fileInfo.wordCount);
            
            if (normalizedScore > scoreThreshold) {
                results.push({
                    path: filePath,
                    score: normalizedScore,
                    rawScore: score,
                    matchedTerms: [...new Set(matchedTerms)],
                    fileInfo: {
                        modified: fileInfo.modified,
                        wordCount: fileInfo.wordCount,
                        lines: fileInfo.lines
                    }
                });
            }
        });
        
        return results
            .sort((a, b) => b.score - a.score)
            .slice(0, maxResults);
    }

    // Find related content
    findRelated(filePath, maxResults = 10) {
        const fileInfo = this.index.files[filePath];
        if (!fileInfo) return [];
        
        const keywords = fileInfo.keywords.slice(0, 10); // Top keywords
        const relatedFiles = new Map();
        
        keywords.forEach(keyword => {
            const filesWithKeyword = this.index.keywords[keyword] || [];
            filesWithKeyword.forEach(file => {
                if (file !== filePath) {
                    relatedFiles.set(file, (relatedFiles.get(file) || 0) + 1);
                }
            });
        });
        
        return Array.from(relatedFiles.entries())
            .sort(([,a], [,b]) => b - a)
            .slice(0, maxResults)
            .map(([file, matches]) => ({
                path: file,
                sharedKeywords: matches,
                fileInfo: this.index.files[file]
            }));
    }

    // Get search statistics
    getStats() {
        return {
            totalFiles: Object.keys(this.index.files).length,
            totalKeywords: Object.keys(this.index.keywords).length,
            lastUpdated: this.index.lastUpdated,
            fileTypes: this.getFileTypeBreakdown(),
            topKeywords: this.getTopKeywords(10)
        };
    }

    getFileTypeBreakdown() {
        const breakdown = {};
        Object.keys(this.index.files).forEach(filePath => {
            const ext = path.extname(filePath).substring(1) || 'unknown';
            breakdown[ext] = (breakdown[ext] || 0) + 1;
        });
        return breakdown;
    }

    getTopKeywords(limit = 10) {
        return Object.entries(this.index.keywords)
            .sort(([,a], [,b]) => b.length - a.length)
            .slice(0, limit)
            .map(([keyword, files]) => ({
                keyword,
                fileCount: files.length
            }));
    }
}

module.exports = MemorySearch;
```

## Memory Maintenance Automation

Automate the curation process from daily logs to long-term memory:

```javascript
// ~/.openclaw/workspace/memory/memory-curator.js
const fs = require('fs');
const path = require('path');
const { glob } = require('glob');

class MemoryCurator {
    constructor() {
        this.memoryDir = path.join(process.env.HOME, '.openclaw/workspace/memory');
        this.memoryFile = path.join(process.env.HOME, '.openclaw/workspace/MEMORY.md');
    }

    async curateDailyLogs(days = 7) {
        console.log(`🧠 Curating memory from last ${days} days...`);
        
        // Find daily log files from the last N days
        const cutoffDate = new Date(Date.now() - days * 24 * 60 * 60 * 1000);
        const dailyFiles = await this.findDailyFiles(cutoffDate);
        
        if (dailyFiles.length === 0) {
            console.log('No daily files found to curate');
            return;
        }

        // Extract insights from daily files
        const insights = await this.extractInsights(dailyFiles);
        
        // Update MEMORY.md with new insights
        await this.updateLongTermMemory(insights);
        
        // Archive processed daily files
        await this.archiveDailyFiles(dailyFiles);
        
        console.log(`✅ Memory curation complete. Processed ${dailyFiles.length} daily files.`);
    }

    async findDailyFiles(cutoffDate) {
        const pattern = `${this.memoryDir}/**/[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9].md`;
        const files = await glob(pattern);
        
        return files.filter(file => {
            const basename = path.basename(file, '.md');
            const fileDate = new Date(basename);
            return fileDate >= cutoffDate && fs.existsSync(file);
        });
    }

    async extractInsights(dailyFiles) {
        const insights = {
            decisions: [],
            lessons: [],
            patterns: [],
            achievements: [],
            errors: [],
            todos: []
        };

        for (const file of dailyFiles) {
            const content = fs.readFileSync(file, 'utf8');
            const fileInsights = this.analyzeDailyContent(content, file);
            
            // Merge insights
            Object.keys(insights).forEach(key => {
                insights[key].push(...fileInsights[key]);
            });
        }

        // Deduplicate and prioritize
        Object.keys(insights).forEach(key => {
            insights[key] = this.deduplicateInsights(insights[key]);
        });

        return insights;
    }

    analyzeDailyContent(content, filePath) {
        const insights = {
            decisions: [],
            lessons: [],
            patterns: [],
            achievements: [],
            errors: [],
            todos: []
        };

        const lines = content.split('\n');
        const date = path.basename(filePath, '.md');

        lines.forEach(line => {
            const trimmed = line.trim();
            
            // Look for decision patterns
            if (this.matchesPattern(trimmed, ['decided', 'chose', 'selected', 'went with'])) {
                insights.decisions.push({
                    text: trimmed,
                    date,
                    source: filePath
                });
            }
            
            // Look for lessons learned
            if (this.matchesPattern(trimmed, ['learned', 'realized', 'discovered', 'figured out'])) {
                insights.lessons.push({
                    text: trimmed,
                    date,
                    source: filePath
                });
            }
            
            // Look for achievements
            if (this.matchesPattern(trimmed, ['completed', 'finished', 'shipped', 'deployed', 'succeeded'])) {
                insights.achievements.push({
                    text: trimmed,
                    date,
                    source: filePath
                });
            }
            
            // Look for errors and problems
            if (this.matchesPattern(trimmed, ['error', 'failed', 'broke', 'issue', 'problem', 'bug'])) {
                insights.errors.push({
                    text: trimmed,
                    date,
                    source: filePath
                });
            }
            
            // Look for TODO items
            if (trimmed.match(/^(- \[ \]|TODO|FIXME|\* \[ \])/i)) {
                insights.todos.push({
                    text: trimmed,
                    date,
                    source: filePath
                });
            }
        });

        return insights;
    }

    matchesPattern(text, keywords) {
        const lowercaseText = text.toLowerCase();
        return keywords.some(keyword => lowercaseText.includes(keyword.toLowerCase()));
    }

    deduplicateInsights(insights) {
        // Simple deduplication based on text similarity
        const unique = [];
        const seen = new Set();
        
        insights.forEach(insight => {
            const normalized = insight.text.toLowerCase()
                .replace(/[^\w\s]/g, '')
                .replace(/\s+/g, ' ')
                .trim();
            
            if (!seen.has(normalized) && normalized.length > 10) {
                seen.add(normalized);
                unique.push(insight);
            }
        });
        
        return unique.slice(0, 20); // Limit per category
    }

    async updateLongTermMemory(insights) {
        let memoryContent = '';
        
        // Load existing MEMORY.md if it exists
        if (fs.existsSync(this.memoryFile)) {
            memoryContent = fs.readFileSync(this.memoryFile, 'utf8');
        } else {
            memoryContent = '# MEMORY.md - Long-Term Memory\n\n';
            memoryContent += '*Curated insights and learnings from daily operations*\n\n';
        }

        // Add new section with timestamp
        const timestamp = new Date().toISOString().split('T')[0];
        memoryContent += `\n## Memory Update - ${timestamp}\n\n`;

        // Add insights by category
        Object.entries(insights).forEach(([category, items]) => {
            if (items.length > 0) {
                memoryContent += `### ${category.charAt(0).toUpperCase() + category.slice(1)}\n\n`;
                
                items.slice(0, 10).forEach(insight => {
                    memoryContent += `- ${insight.text} *(${insight.date})*\n`;
                });
                
                memoryContent += '\n';
            }
        });

        // Write updated memory
        fs.writeFileSync(this.memoryFile, memoryContent);
    }

    async archiveDailyFiles(dailyFiles) {
        const archiveDir = path.join(this.memoryDir, 'archive');
        
        if (!fs.existsSync(archiveDir)) {
            fs.mkdirSync(archiveDir, { recursive: true });
        }

        for (const file of dailyFiles) {
            const basename = path.basename(file);
            const archivePath = path.join(archiveDir, basename);
            
            // Move to archive
            fs.renameSync(file, archivePath);
        }
    }

    // Analyze memory patterns
    async analyzePatterns() {
        if (!fs.existsSync(this.memoryFile)) {
            return { message: 'No long-term memory file found' };
        }

        const content = fs.readFileSync(this.memoryFile, 'utf8');
        const sections = content.split('##').slice(1); // Skip header
        
        const analysis = {
            totalSections: sections.length,
            recentTrends: this.analyzeRecentTrends(sections),
            frequentTopics: this.findFrequentTopics(content),
            learningVelocity: this.calculateLearningVelocity(sections)
        };

        return analysis;
    }

    analyzeRecentTrends(sections) {
        const recentSections = sections.slice(-5); // Last 5 updates
        const trends = {};
        
        recentSections.forEach(section => {
            const lines = section.split('\n');
            lines.forEach(line => {
                if (line.includes('###')) {
                    const category = line.replace('###', '').trim().toLowerCase();
                    trends[category] = (trends[category] || 0) + 1;
                }
            });
        });
        
        return Object.entries(trends)
            .sort(([,a], [,b]) => b - a)
            .slice(0, 5);
    }

    findFrequentTopics(content) {
        // Extract frequently mentioned terms
        const words = content.toLowerCase()
            .replace(/[^\w\s]/g, ' ')
            .split(/\s+/)
            .filter(word => word.length > 4);
        
        const wordCounts = {};
        words.forEach(word => {
            wordCounts[word] = (wordCounts[word] || 0) + 1;
        });
        
        return Object.entries(wordCounts)
            .sort(([,a], [,b]) => b - a)
            .slice(0, 10);
    }

    calculateLearningVelocity(sections) {
        // Approximate learning velocity by counting insights per time period
        const velocityData = sections.map(section => {
            const lines = section.split('\n').filter(line => line.trim().startsWith('- '));
            const dateMatch = section.match(/Memory Update - (\d{4}-\d{2}-\d{2})/);
            
            return {
                date: dateMatch ? dateMatch[1] : null,
                insightCount: lines.length
            };
        }).filter(entry => entry.date);

        if (velocityData.length < 2) return 0;

        const totalInsights = velocityData.reduce((sum, entry) => sum + entry.insightCount, 0);
        const daysBetween = this.daysBetween(velocityData[0].date, velocityData[velocityData.length - 1].date);
        
        return daysBetween > 0 ? (totalInsights / daysBetween).toFixed(2) : 0;
    }

    daysBetween(date1, date2) {
        const d1 = new Date(date1);
        const d2 = new Date(date2);
        const diffTime = Math.abs(d2 - d1);
        return Math.ceil(diffTime / (1000 * 60 * 60 * 24));
    }
}

module.exports = MemoryCurator;
```

## Advanced AGENTS.md Patterns

Implement conditional behaviors and mode switching:

```markdown
# Advanced AGENTS.md - Conditional AI Behavior

## Context-Aware Loading

```javascript
// Dynamic behavior based on context
const context = require('./memory/active-context');
const currentPhase = context.getContext().workflow.currentPhase;

if (currentPhase === 'development') {
    // Load development-specific instructions
    this.mode = 'detailed-logging';
    this.verbosity = 'high';
} else if (currentPhase === 'production') {
    // Load production-specific instructions
    this.mode = 'efficiency-focused';
    this.verbosity = 'low';
}
```

## Conditional Sections

### If in Development Mode
*Only load this section when workflow.currentPhase === 'development'*

- Use verbose logging
- Explain every decision
- Ask before making changes
- Save intermediate results

### If in Production Mode
*Only load when workflow.currentPhase === 'production'*

- Focus on speed and efficiency
- Minimal logging
- Auto-commit safe changes
- Batch operations

## Dynamic Memory Loading

```javascript
// Load different memory contexts based on current task
const taskType = context.getContext().session.currentTask?.type;

if (taskType === 'financial') {
    this.loadMemoryFiles(['financial-patterns.md', 'trading-insights.md']);
} else if (taskType === 'technical') {
    this.loadMemoryFiles(['coding-standards.md', 'architecture-decisions.md']);
}
```

## Performance-Based Adaptation

Track your own performance and adapt:

```javascript
const performance = context.getContext().performance;
const avgResponseTime = performance.averageResponseTime;

if (avgResponseTime > 10000) { // Over 10 seconds
    // Switch to faster, less detailed responses
    this.responseStyle = 'concise';
    this.thinking = 'minimal';
} else {
    this.responseStyle = 'thorough';
    this.thinking = 'detailed';
}
```

## Time-Based Behaviors

```javascript
const hour = new Date().getHours();

if (hour >= 23 || hour <= 6) {
    // Late night/early morning - quiet mode
    this.notifications = 'urgent-only';
    this.autoCommit = false; // Safer during off-hours
} else if (hour >= 9 && hour <= 17) {
    // Business hours - active mode
    this.notifications = 'all';
    this.autoCommit = true;
}
```
```

## Pro Tips

**🧠 Memory Hierarchy:** Active context for immediate needs, persistent memory for long-term knowledge. Don't blur the lines.

**🔍 Search First:** Before creating new memory files, search existing ones. Avoid duplicate insights and contradictory information.

**⚡ Performance Balance:** Rich memory is powerful but slower. Monitor context size and optimize loading patterns.

**🔄 Regular Curation:** Memory maintenance isn't optional. Run curation weekly or accumulated knowledge becomes noise.

**📊 Track Memory Health:** Monitor search index size, file count growth, and access patterns. Healthy memory grows steadily, not explosively.

## Troubleshooting

### Issue 1: Context Size Too Large
**Symptoms:** Slow responses, high token usage, context overflow errors
**Diagnosis:** Loading too much memory at once
**Fix:**
```javascript
// Implement memory loading limits
class MemoryManager {
    loadContext(maxTokens = 8000) {
        const context = this.activeContext.getContext();
        const memoryFiles = this.prioritizeMemoryFiles();
        
        let tokenCount = 0;
        const loaded = [];
        
        for (const file of memoryFiles) {
            const fileTokens = this.estimateTokens(file);
            if (tokenCount + fileTokens <= maxTokens) {
                loaded.push(file);
                tokenCount += fileTokens;
            } else {
                break;
            }
        }
        
        return loaded;
    }
}
```

### Issue 2: Search Returns Irrelevant Results
**Symptoms:** Search finds files but content isn't relevant to query
**Diagnosis:** Index keywords don't match actual content usefulness
**Fix:**
```javascript
// Improve keyword extraction
extractKeywords(content) {
    // Focus on domain-specific terms
    const domainTerms = this.extractDomainSpecificTerms(content);
    const technicalTerms = this.extractTechnicalTerms(content);
    
    return [...domainTerms, ...technicalTerms];
}
```

### Issue 3: Memory Curation Creates Noise
**Symptoms:** MEMORY.md becomes cluttered with trivial insights
**Diagnosis:** Not filtering for truly important information
**Fix:**
```javascript
// Add importance scoring
scoreInsight(insight) {
    let score = 0;
    
    // Business impact keywords
    if (insight.text.match(/revenue|cost|efficiency|automation/i)) score += 3;
    
    // Technical breakthrough keywords  
    if (insight.text.match(/solved|breakthrough|optimization|architecture/i)) score += 2;
    
    // Learning keywords
    if (insight.text.match(/learned|discovered|realized/i)) score += 1;
    
    return score;
}
```

### Issue 4: Task Queue Gets Clogged
**Symptoms:** Many pending tasks, nothing gets completed
**Diagnosis:** Tasks too complex or dependencies not managed
**Fix:**
```javascript
// Break down complex tasks
addTask(task, priority = 'normal') {
    const subtasks = this.decomposeTask(task);
    
    if (subtasks.length > 1) {
        return subtasks.map(subtask => this.add(subtask, priority));
    } else {
        return this.add(task, priority);
    }
}
```

### Issue 5: Credential Vault Access Errors
**Symptoms:** Environment variables not found when credentials are accessed
**Diagnosis:** Environment not properly loaded or variables not set
**Fix:**
```javascript
// Add environment validation on startup
validateEnvironment() {
    const vault = new CredentialVault();
    const results = vault.verifyAll();
    
    const failures = Object.entries(results)
        .filter(([key, valid]) => !valid)
        .map(([key]) => key);
    
    if (failures.length > 0) {
        throw new Error(`Missing credentials: ${failures.join(', ')}`);
    }
}
```

Advanced memory architecture is what separates professional AI systems from toys. Build it right, and your AI becomes more capable with every interaction. Skip it, and you'll forever be explaining the same things over and over.

Memory is not storage — it's intelligence that compounds over time. Build systems that remember, learn, and get smarter. That's how you create AI that works for you instead of against you.