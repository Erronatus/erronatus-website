# Chapter 13: Custom Skills
## Build Your Own AI Superpowers

*OpenClaw skills are like iPhone apps for AI — they extend capabilities in specific domains. The Personal Edition showed you how to use existing skills. The Business Edition teaches you to build custom skills that solve your unique problems. This isn't about generic automation — it's about creating specialized AI tools that give you unfair advantages in your market.*

### Why This Matters

Pre-built skills solve common problems. Custom skills solve *your* problems. When you can build skills that:
- Automate your specific workflows
- Integrate your exact data sources
- Match your business logic
- Handle your edge cases

You stop competing on the same tools as everyone else. You build moats that competitors can't cross because they don't have your skills.

The businesses that dominate their markets don't use off-the-shelf everything — they build custom solutions where it matters most.

## Anatomy of an OpenClaw Skill

Every skill follows the same structure:

```
skill-name/
├── SKILL.md              # Skill definition and instructions
├── scripts/              # Helper scripts and automation
│   ├── main.js          # Primary skill logic
│   ├── helpers.js       # Utility functions
│   └── setup.js         # Initial configuration
├── assets/              # Templates, data files, images
│   ├── templates/       # Email, report templates
│   ├── data/           # Reference data, lookups
│   └── examples/       # Usage examples
├── config/             # Configuration files
│   ├── defaults.json   # Default settings
│   └── schema.json     # Configuration validation
└── README.md           # Documentation for developers
```

### SKILL.md Structure

The SKILL.md file tells OpenClaw how and when to use your skill:

```markdown
# Skill Name

Brief description of what this skill does.

## Trigger Conditions

When should OpenClaw load this skill:
- User mentions specific keywords
- Specific file types are present
- Certain workflow conditions are met

## Dependencies

Required services, APIs, or tools:
- Service A (API key required)
- Service B (account setup needed)
- Local tools (ffmpeg, imagemagick, etc.)

## Configuration

Environment variables needed:
- REQUIRED_API_KEY
- OPTIONAL_SETTING (default: value)

## Usage Examples

Specific examples of how to invoke the skill.

## Scripts

Description of included scripts and their purposes.
```

## Building Your First Skill: Weather Report Generator

Let's build a complete skill that generates formatted weather reports for business planning:

### Step 1: Create Skill Structure

```bash
mkdir -p ~/.openclaw/workspace/skills/weather-reports/{scripts,assets/templates,config}
cd ~/.openclaw/workspace/skills/weather-reports
```

### Step 2: Create SKILL.md

```markdown
# Weather Reports

Generates comprehensive weather reports for business planning and decision-making.

## Trigger Conditions

OpenClaw will load this skill when:
- User asks about weather for business purposes
- Keywords: "weather report", "forecast analysis", "weather impact"
- File operations involving weather data

## Dependencies

- Open-Meteo API (free, no API key required)
- Node.js axios library

## Configuration

No API keys required. Optional environment variables:
- DEFAULT_LOCATION (default: "New York, NY")
- TEMPERATURE_UNIT (default: "fahrenheit") 
- REPORT_LANGUAGE (default: "en")

## Usage Examples

- "Generate a 7-day weather report for Chicago"
- "Create weather analysis for outdoor event planning"
- "Get weather impact assessment for construction project"

## Scripts

- `scripts/weather-fetcher.js` - Fetches weather data from Open-Meteo
- `scripts/report-generator.js` - Formats data into business reports
- `scripts/main.js` - Main skill entry point
```

Save this as `SKILL.md` in the skill directory.

### Step 3: Create Weather Fetcher

```javascript
// scripts/weather-fetcher.js
const axios = require('axios');

class WeatherFetcher {
    constructor() {
        this.baseUrl = 'https://api.open-meteo.com/v1';
        this.geocodingUrl = 'https://geocoding-api.open-meteo.com/v1';
    }

    async getCoordinates(location) {
        try {
            const response = await axios.get(`${this.geocodingUrl}/search`, {
                params: {
                    name: location,
                    count: 1,
                    language: 'en',
                    format: 'json'
                }
            });

            const results = response.data.results;
            if (!results || results.length === 0) {
                throw new Error(`Location not found: ${location}`);
            }

            return {
                latitude: results[0].latitude,
                longitude: results[0].longitude,
                name: results[0].name,
                country: results[0].country
            };
        } catch (error) {
            console.error('Geocoding error:', error.message);
            throw new Error(`Failed to find coordinates for ${location}`);
        }
    }

    async getCurrentWeather(latitude, longitude) {
        try {
            const response = await axios.get(`${this.baseUrl}/forecast`, {
                params: {
                    latitude,
                    longitude,
                    current: 'temperature_2m,relative_humidity_2m,apparent_temperature,is_day,precipitation,weather_code,cloud_cover,pressure_msl,surface_pressure,wind_speed_10m,wind_direction_10m,wind_gusts_10m',
                    temperature_unit: 'fahrenheit',
                    wind_speed_unit: 'mph',
                    precipitation_unit: 'inch',
                    timezone: 'auto'
                }
            });

            return response.data.current;
        } catch (error) {
            console.error('Current weather error:', error.message);
            throw new Error('Failed to fetch current weather');
        }
    }

    async getWeatherForecast(latitude, longitude, days = 7) {
        try {
            const response = await axios.get(`${this.baseUrl}/forecast`, {
                params: {
                    latitude,
                    longitude,
                    daily: 'weather_code,temperature_2m_max,temperature_2m_min,apparent_temperature_max,apparent_temperature_min,precipitation_sum,precipitation_hours,wind_speed_10m_max,wind_gusts_10m_max,wind_direction_10m_dominant,uv_index_max,sunrise,sunset',
                    temperature_unit: 'fahrenheit',
                    wind_speed_unit: 'mph',
                    precipitation_unit: 'inch',
                    timezone: 'auto',
                    forecast_days: days
                }
            });

            return response.data.daily;
        } catch (error) {
            console.error('Forecast error:', error.message);
            throw new Error('Failed to fetch weather forecast');
        }
    }

    interpretWeatherCode(code) {
        const weatherCodes = {
            0: { description: 'Clear sky', icon: '☀️', severity: 'good' },
            1: { description: 'Mainly clear', icon: '🌤️', severity: 'good' },
            2: { description: 'Partly cloudy', icon: '⛅', severity: 'good' },
            3: { description: 'Overcast', icon: '☁️', severity: 'fair' },
            45: { description: 'Fog', icon: '🌫️', severity: 'poor' },
            48: { description: 'Depositing rime fog', icon: '🌫️', severity: 'poor' },
            51: { description: 'Light drizzle', icon: '🌦️', severity: 'fair' },
            53: { description: 'Moderate drizzle', icon: '🌦️', severity: 'poor' },
            55: { description: 'Dense drizzle', icon: '🌧️', severity: 'poor' },
            61: { description: 'Slight rain', icon: '🌧️', severity: 'fair' },
            63: { description: 'Moderate rain', icon: '🌧️', severity: 'poor' },
            65: { description: 'Heavy rain', icon: '🌧️', severity: 'bad' },
            71: { description: 'Slight snow', icon: '🌨️', severity: 'poor' },
            73: { description: 'Moderate snow', icon: '❄️', severity: 'bad' },
            75: { description: 'Heavy snow', icon: '❄️', severity: 'bad' },
            95: { description: 'Thunderstorm', icon: '⛈️', severity: 'bad' },
            96: { description: 'Thunderstorm with hail', icon: '⛈️', severity: 'bad' },
            99: { description: 'Heavy thunderstorm with hail', icon: '⛈️', severity: 'bad' }
        };

        return weatherCodes[code] || { description: 'Unknown', icon: '❓', severity: 'unknown' };
    }

    getBusinessImpactAssessment(weatherData, forecastData) {
        const impacts = [];
        
        // Current conditions impact
        const currentWeather = this.interpretWeatherCode(weatherData.weather_code);
        if (currentWeather.severity === 'bad') {
            impacts.push({
                type: 'immediate',
                severity: 'high',
                description: `Current severe weather (${currentWeather.description}) may impact operations`
            });
        }

        // Wind impact
        if (weatherData.wind_gusts_10m > 25) {
            impacts.push({
                type: 'immediate',
                severity: 'medium',
                description: `High wind gusts (${weatherData.wind_gusts_10m} mph) may affect outdoor activities`
            });
        }

        // Forecast impacts
        for (let i = 0; i < Math.min(forecastData.weather_code.length, 3); i++) {
            const dayWeather = this.interpretWeatherCode(forecastData.weather_code[i]);
            const date = new Date(forecastData.time[i]).toLocaleDateString();
            
            if (dayWeather.severity === 'bad') {
                impacts.push({
                    type: 'upcoming',
                    severity: 'high', 
                    description: `${date}: ${dayWeather.description} - consider rescheduling outdoor activities`,
                    date: forecastData.time[i]
                });
            }

            // Precipitation impact
            if (forecastData.precipitation_sum[i] > 0.5) {
                impacts.push({
                    type: 'upcoming',
                    severity: 'medium',
                    description: `${date}: Heavy precipitation (${forecastData.precipitation_sum[i]}" expected) - plan for delays`,
                    date: forecastData.time[i]
                });
            }
        }

        return impacts;
    }
}

module.exports = WeatherFetcher;
```

### Step 4: Create Report Generator

```javascript
// scripts/report-generator.js
const fs = require('fs');
const path = require('path');

class WeatherReportGenerator {
    constructor() {
        this.templatesDir = path.join(__dirname, '../assets/templates');
    }

    generateBusinessReport(location, currentWeather, forecast, impacts) {
        const report = {
            title: `Weather Analysis Report - ${location.name}, ${location.country}`,
            generatedAt: new Date().toISOString(),
            location,
            current: this.formatCurrentWeather(currentWeather),
            forecast: this.formatForecast(forecast),
            businessImpacts: impacts,
            recommendations: this.generateRecommendations(impacts, forecast)
        };

        return report;
    }

    formatCurrentWeather(weather) {
        const WeatherFetcher = require('./weather-fetcher');
        const fetcher = new WeatherFetcher();
        const condition = fetcher.interpretWeatherCode(weather.weather_code);

        return {
            condition: condition.description,
            icon: condition.icon,
            temperature: `${Math.round(weather.temperature_2m)}°F`,
            feelsLike: `${Math.round(weather.apparent_temperature)}°F`,
            humidity: `${weather.relative_humidity_2m}%`,
            pressure: `${Math.round(weather.pressure_msl)} hPa`,
            windSpeed: `${Math.round(weather.wind_speed_10m)} mph`,
            windDirection: `${weather.wind_direction_10m}°`,
            windGusts: `${Math.round(weather.wind_gusts_10m)} mph`,
            cloudCover: `${weather.cloud_cover}%`,
            precipitation: `${weather.precipitation}" last hour`
        };
    }

    formatForecast(forecast) {
        const WeatherFetcher = require('./weather-fetcher');
        const fetcher = new WeatherFetcher();

        return forecast.time.map((date, index) => {
            const condition = fetcher.interpretWeatherCode(forecast.weather_code[index]);
            
            return {
                date: new Date(date).toLocaleDateString('en-US', { 
                    weekday: 'long', 
                    month: 'short', 
                    day: 'numeric' 
                }),
                condition: condition.description,
                icon: condition.icon,
                highTemp: `${Math.round(forecast.temperature_2m_max[index])}°F`,
                lowTemp: `${Math.round(forecast.temperature_2m_min[index])}°F`,
                precipitation: `${forecast.precipitation_sum[index]}"`,
                precipHours: `${forecast.precipitation_hours[index]}h`,
                windMax: `${Math.round(forecast.wind_speed_10m_max[index])} mph`,
                uvIndex: forecast.uv_index_max[index],
                sunrise: new Date(forecast.sunrise[index]).toLocaleTimeString('en-US', { 
                    hour: 'numeric', 
                    minute: '2-digit', 
                    hour12: true 
                }),
                sunset: new Date(forecast.sunset[index]).toLocaleTimeString('en-US', { 
                    hour: 'numeric', 
                    minute: '2-digit', 
                    hour12: true 
                })
            };
        });
    }

    generateRecommendations(impacts, forecast) {
        const recommendations = [];

        // High-priority alerts
        const highImpacts = impacts.filter(impact => impact.severity === 'high');
        if (highImpacts.length > 0) {
            recommendations.push({
                priority: 'high',
                category: 'immediate_action',
                title: 'Weather Alerts Require Immediate Attention',
                actions: highImpacts.map(impact => impact.description)
            });
        }

        // Precipitation planning
        const precipDays = forecast.time.filter((date, index) => 
            forecast.precipitation_sum[index] > 0.1
        );
        
        if (precipDays.length > 0) {
            recommendations.push({
                priority: 'medium',
                category: 'planning',
                title: 'Precipitation Expected',
                actions: [
                    'Plan indoor backup activities',
                    'Allow extra travel time',
                    'Secure outdoor equipment',
                    'Consider rescheduling outdoor meetings'
                ]
            });
        }

        // Wind considerations
        const windyDays = forecast.time.filter((date, index) => 
            forecast.wind_speed_10m_max[index] > 20
        );
        
        if (windyDays.length > 0) {
            recommendations.push({
                priority: 'medium',
                category: 'safety',
                title: 'High Wind Conditions Expected',
                actions: [
                    'Secure outdoor signage and displays',
                    'Consider drone/aerial work delays',
                    'Monitor transportation services',
                    'Brief staff on wind safety protocols'
                ]
            });
        }

        // Optimal weather windows
        const goodWeatherDays = forecast.time.filter((date, index) => {
            const WeatherFetcher = require('./weather-fetcher');
            const fetcher = new WeatherFetcher();
            const condition = fetcher.interpretWeatherCode(forecast.weather_code[index]);
            
            return condition.severity === 'good' && 
                   forecast.precipitation_sum[index] < 0.1 &&
                   forecast.wind_speed_10m_max[index] < 15;
        });

        if (goodWeatherDays.length > 0) {
            recommendations.push({
                priority: 'low',
                category: 'optimization',
                title: 'Optimal Weather Windows Identified',
                actions: [
                    'Schedule outdoor activities during clear periods',
                    'Plan site visits and inspections',
                    'Consider outdoor marketing events',
                    'Optimize delivery and logistics schedules'
                ]
            });
        }

        return recommendations;
    }

    generateMarkdownReport(reportData) {
        let markdown = `# ${reportData.title}\n\n`;
        markdown += `*Generated on ${new Date(reportData.generatedAt).toLocaleString()}*\n\n`;
        
        markdown += `## 📍 Location\n`;
        markdown += `${reportData.location.name}, ${reportData.location.country}\n`;
        markdown += `Coordinates: ${reportData.location.latitude}, ${reportData.location.longitude}\n\n`;

        // Current weather
        markdown += `## 🌤️ Current Conditions\n\n`;
        const current = reportData.current;
        markdown += `${current.icon} **${current.condition}**\n\n`;
        markdown += `| Metric | Value |\n`;
        markdown += `|--------|-------|\n`;
        markdown += `| Temperature | ${current.temperature} (feels like ${current.feelsLike}) |\n`;
        markdown += `| Humidity | ${current.humidity} |\n`;
        markdown += `| Pressure | ${current.pressure} |\n`;
        markdown += `| Wind | ${current.windSpeed} (gusts ${current.windGusts}) |\n`;
        markdown += `| Cloud Cover | ${current.cloudCover} |\n`;
        markdown += `| Precipitation | ${current.precipitation} |\n\n`;

        // Forecast
        markdown += `## 📅 7-Day Forecast\n\n`;
        reportData.forecast.forEach(day => {
            markdown += `### ${day.date} ${day.icon}\n`;
            markdown += `**${day.condition}** • High: ${day.highTemp} • Low: ${day.lowTemp}\n`;
            markdown += `Rain: ${day.precipitation} (${day.precipHours}) • Wind: ${day.windMax} • UV: ${day.uvIndex}\n`;
            markdown += `Sunrise: ${day.sunrise} • Sunset: ${day.sunset}\n\n`;
        });

        // Business impacts
        if (reportData.businessImpacts.length > 0) {
            markdown += `## ⚠️ Business Impact Assessment\n\n`;
            reportData.businessImpacts.forEach(impact => {
                const emoji = impact.severity === 'high' ? '🚨' : 
                             impact.severity === 'medium' ? '⚠️' : 'ℹ️';
                markdown += `${emoji} **${impact.type.toUpperCase()}**: ${impact.description}\n`;
            });
            markdown += '\n';
        }

        // Recommendations
        if (reportData.recommendations.length > 0) {
            markdown += `## 💡 Recommendations\n\n`;
            reportData.recommendations.forEach(rec => {
                const emoji = rec.priority === 'high' ? '🔴' : 
                             rec.priority === 'medium' ? '🟡' : '🟢';
                markdown += `${emoji} **${rec.title}**\n`;
                rec.actions.forEach(action => {
                    markdown += `- ${action}\n`;
                });
                markdown += '\n';
            });
        }

        return markdown;
    }

    generateJSONReport(reportData) {
        return JSON.stringify(reportData, null, 2);
    }

    saveReport(reportData, format = 'markdown') {
        const timestamp = new Date().toISOString().split('T')[0];
        const locationSlug = reportData.location.name.toLowerCase().replace(/\s+/g, '-');
        
        let filename, content;
        
        if (format === 'markdown') {
            filename = `weather-report-${locationSlug}-${timestamp}.md`;
            content = this.generateMarkdownReport(reportData);
        } else if (format === 'json') {
            filename = `weather-report-${locationSlug}-${timestamp}.json`;
            content = this.generateJSONReport(reportData);
        } else {
            throw new Error(`Unsupported format: ${format}`);
        }

        const outputPath = path.join(process.cwd(), filename);
        fs.writeFileSync(outputPath, content);
        
        return outputPath;
    }
}

module.exports = WeatherReportGenerator;
```

### Step 5: Create Main Skill Entry Point

```javascript
// scripts/main.js
const WeatherFetcher = require('./weather-fetcher');
const WeatherReportGenerator = require('./report-generator');

class WeatherReportsSkill {
    constructor() {
        this.fetcher = new WeatherFetcher();
        this.generator = new WeatherReportGenerator();
        this.defaultLocation = process.env.DEFAULT_LOCATION || 'New York, NY';
    }

    async generateReport(location = null, days = 7, format = 'markdown') {
        try {
            const targetLocation = location || this.defaultLocation;
            
            console.log(`🌤️ Generating weather report for ${targetLocation}...`);
            
            // Get location coordinates
            const coordinates = await this.fetcher.getCoordinates(targetLocation);
            console.log(`📍 Found: ${coordinates.name}, ${coordinates.country}`);
            
            // Fetch current weather and forecast
            const [currentWeather, forecast] = await Promise.all([
                this.fetcher.getCurrentWeather(coordinates.latitude, coordinates.longitude),
                this.fetcher.getWeatherForecast(coordinates.latitude, coordinates.longitude, days)
            ]);
            
            // Assess business impacts
            const impacts = this.fetcher.getBusinessImpactAssessment(currentWeather, forecast);
            
            // Generate report
            const reportData = this.generator.generateBusinessReport(
                coordinates,
                currentWeather,
                forecast,
                impacts
            );
            
            // Save report
            const outputPath = this.generator.saveReport(reportData, format);
            
            console.log(`✅ Weather report saved to: ${outputPath}`);
            console.log(`📊 Found ${impacts.length} business impact alerts`);
            console.log(`💡 Generated ${reportData.recommendations.length} recommendations`);
            
            return {
                success: true,
                reportPath: outputPath,
                data: reportData,
                summary: {
                    location: coordinates.name,
                    currentCondition: this.fetcher.interpretWeatherCode(currentWeather.weather_code).description,
                    temperature: `${Math.round(currentWeather.temperature_2m)}°F`,
                    impactAlerts: impacts.length,
                    recommendations: reportData.recommendations.length
                }
            };
            
        } catch (error) {
            console.error('❌ Weather report generation failed:', error.message);
            return {
                success: false,
                error: error.message
            };
        }
    }

    async quickForecast(location = null) {
        try {
            const targetLocation = location || this.defaultLocation;
            const coordinates = await this.fetcher.getCoordinates(targetLocation);
            const currentWeather = await this.fetcher.getCurrentWeather(
                coordinates.latitude, 
                coordinates.longitude
            );
            
            const condition = this.fetcher.interpretWeatherCode(currentWeather.weather_code);
            
            return {
                location: coordinates.name,
                condition: condition.description,
                icon: condition.icon,
                temperature: `${Math.round(currentWeather.temperature_2m)}°F`,
                feelsLike: `${Math.round(currentWeather.apparent_temperature)}°F`,
                humidity: `${currentWeather.relative_humidity_2m}%`,
                wind: `${Math.round(currentWeather.wind_speed_10m)} mph`
            };
            
        } catch (error) {
            console.error('❌ Quick forecast failed:', error.message);
            return { error: error.message };
        }
    }

    async getBusinessImpactSummary(location = null, days = 3) {
        try {
            const targetLocation = location || this.defaultLocation;
            const coordinates = await this.fetcher.getCoordinates(targetLocation);
            
            const [currentWeather, forecast] = await Promise.all([
                this.fetcher.getCurrentWeather(coordinates.latitude, coordinates.longitude),
                this.fetcher.getWeatherForecast(coordinates.latitude, coordinates.longitude, days)
            ]);
            
            const impacts = this.fetcher.getBusinessImpactAssessment(currentWeather, forecast);
            
            return {
                location: coordinates.name,
                totalImpacts: impacts.length,
                highSeverity: impacts.filter(i => i.severity === 'high').length,
                immediateAlerts: impacts.filter(i => i.type === 'immediate').length,
                upcomingConcerns: impacts.filter(i => i.type === 'upcoming').length,
                impacts: impacts.slice(0, 5) // Top 5 impacts
            };
            
        } catch (error) {
            console.error('❌ Business impact summary failed:', error.message);
            return { error: error.message };
        }
    }
}

// CLI usage when called directly
if (require.main === module) {
    const skill = new WeatherReportsSkill();
    
    const command = process.argv[2];
    const location = process.argv[3];
    
    switch (command) {
        case 'report':
            skill.generateReport(location).then(result => {
                if (result.success) {
                    console.log('\n📋 Report Summary:');
                    console.log(JSON.stringify(result.summary, null, 2));
                } else {
                    console.error('Report generation failed:', result.error);
                }
            });
            break;
            
        case 'quick':
            skill.quickForecast(location).then(result => {
                if (!result.error) {
                    console.log(`\n${result.icon} ${result.location}`);
                    console.log(`${result.condition} - ${result.temperature} (feels like ${result.feelsLike})`);
                    console.log(`Humidity: ${result.humidity} • Wind: ${result.wind}`);
                } else {
                    console.error('Quick forecast failed:', result.error);
                }
            });
            break;
            
        case 'impacts':
            skill.getBusinessImpactSummary(location).then(result => {
                if (!result.error) {
                    console.log(`\n⚠️ Business Impact Summary for ${result.location}`);
                    console.log(`Total impacts: ${result.totalImpacts}`);
                    console.log(`High severity: ${result.highSeverity}`);
                    console.log(`Immediate alerts: ${result.immediateAlerts}`);
                    
                    if (result.impacts.length > 0) {
                        console.log('\nTop concerns:');
                        result.impacts.forEach(impact => {
                            console.log(`- ${impact.description}`);
                        });
                    }
                } else {
                    console.error('Impact summary failed:', result.error);
                }
            });
            break;
            
        default:
            console.log('Usage: node main.js [report|quick|impacts] [location]');
            console.log('Examples:');
            console.log('  node main.js report "Chicago, IL"');
            console.log('  node main.js quick "San Francisco, CA"');
            console.log('  node main.js impacts "Miami, FL"');
    }
}

module.exports = WeatherReportsSkill;
```

### Step 6: Create Configuration Files

```json
// config/defaults.json
{
  "defaultLocation": "New York, NY",
  "temperatureUnit": "fahrenheit",
  "windSpeedUnit": "mph",
  "precipitationUnit": "inch",
  "forecastDays": 7,
  "reportFormat": "markdown",
  "businessHours": {
    "start": 9,
    "end": 17
  },
  "severityThresholds": {
    "wind": {
      "medium": 20,
      "high": 35
    },
    "precipitation": {
      "medium": 0.25,
      "high": 0.75
    },
    "temperature": {
      "extremeCold": 20,
      "extremeHeat": 95
    }
  },
  "alerts": {
    "enabled": true,
    "includeWeekends": false,
    "lookAheadDays": 3
  }
}
```

```json
// config/schema.json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "type": "object",
  "properties": {
    "defaultLocation": {
      "type": "string",
      "description": "Default location for weather reports"
    },
    "temperatureUnit": {
      "type": "string",
      "enum": ["fahrenheit", "celsius"],
      "default": "fahrenheit"
    },
    "forecastDays": {
      "type": "integer",
      "minimum": 1,
      "maximum": 14,
      "default": 7
    },
    "reportFormat": {
      "type": "string",
      "enum": ["markdown", "json", "html"],
      "default": "markdown"
    }
  },
  "required": ["defaultLocation"]
}
```

### Step 7: Create Package Configuration

```json
// package.json
{
  "name": "weather-reports-skill",
  "version": "1.0.0",
  "description": "Comprehensive weather reports for business planning",
  "main": "scripts/main.js",
  "scripts": {
    "start": "node scripts/main.js",
    "test": "node scripts/main.js quick",
    "setup": "node scripts/setup.js"
  },
  "dependencies": {
    "axios": "^1.6.0"
  },
  "keywords": ["weather", "business", "reports", "openclaw"],
  "author": "Your Name",
  "license": "MIT"
}
```

### Step 8: Install Dependencies

```bash
cd ~/.openclaw/workspace/skills/weather-reports
npm init -y
npm install axios
```

### Step 9: Test Your Skill

```bash
# Test quick forecast
node scripts/main.js quick "Chicago, IL"

# Generate full report
node scripts/main.js report "San Francisco, CA" 

# Get business impact summary
node scripts/main.js impacts "Miami, FL"
```

## Skill Discovery and Loading

OpenClaw finds and loads skills automatically based on patterns. Here's how to make your skills discoverable:

### Skill Registration

Add your skill to OpenClaw's skill registry:

```javascript
// ~/.openclaw/workspace/skills/skill-registry.js
const path = require('path');
const fs = require('fs');

class SkillRegistry {
    constructor() {
        this.skillsDir = path.join(process.env.HOME, '.openclaw/workspace/skills');
        this.registry = this.scanForSkills();
    }

    scanForSkills() {
        const skills = {};
        
        try {
            const skillDirs = fs.readdirSync(this.skillsDir, { withFileTypes: true })
                .filter(dirent => dirent.isDirectory())
                .map(dirent => dirent.name);

            for (const skillDir of skillDirs) {
                const skillPath = path.join(this.skillsDir, skillDir);
                const skillFile = path.join(skillPath, 'SKILL.md');
                
                if (fs.existsSync(skillFile)) {
                    const skillData = this.parseSkillFile(skillFile);
                    skills[skillDir] = {
                        name: skillDir,
                        path: skillPath,
                        ...skillData
                    };
                }
            }
        } catch (error) {
            console.error('Failed to scan for skills:', error.message);
        }

        return skills;
    }

    parseSkillFile(skillFilePath) {
        const content = fs.readFileSync(skillFilePath, 'utf8');
        
        // Extract metadata from SKILL.md
        const titleMatch = content.match(/^# (.+)$/m);
        const descMatch = content.match(/^([^#\n].+)$/m);
        
        // Extract trigger conditions
        const triggerSection = this.extractSection(content, 'Trigger Conditions');
        const triggers = this.parseListItems(triggerSection);
        
        // Extract dependencies
        const dependenciesSection = this.extractSection(content, 'Dependencies');
        const dependencies = this.parseListItems(dependenciesSection);
        
        // Extract configuration
        const configSection = this.extractSection(content, 'Configuration');
        const config = this.parseConfigSection(configSection);

        return {
            title: titleMatch ? titleMatch[1] : 'Unknown Skill',
            description: descMatch ? descMatch[1] : '',
            triggers: triggers || [],
            dependencies: dependencies || [],
            config: config || {},
            lastModified: fs.statSync(skillFilePath).mtime
        };
    }

    extractSection(content, sectionTitle) {
        const sectionRegex = new RegExp(`## ${sectionTitle}\\s*\\n([\\s\\S]*?)(?=\\n##|$)`, 'i');
        const match = content.match(sectionRegex);
        return match ? match[1].trim() : '';
    }

    parseListItems(section) {
        if (!section) return [];
        
        const items = section.match(/^[-*] (.+)$/gm);
        return items ? items.map(item => item.replace(/^[-*] /, '').trim()) : [];
    }

    parseConfigSection(section) {
        const config = {};
        const lines = section.split('\n');
        
        lines.forEach(line => {
            const match = line.match(/^[-*] (\w+)(?:\s*\((.*?)\))?/);
            if (match) {
                const [, key, defaultValue] = match;
                config[key] = {
                    required: !defaultValue,
                    default: defaultValue ? defaultValue.replace('default: ', '') : null
                };
            }
        });
        
        return config;
    }

    findSkillByTrigger(triggerText) {
        const matchingSkills = [];
        
        Object.values(this.registry).forEach(skill => {
            const matches = skill.triggers.some(trigger => {
                const keywords = trigger.toLowerCase().split(/[,\s]+/);
                return keywords.some(keyword => 
                    triggerText.toLowerCase().includes(keyword.toLowerCase())
                );
            });
            
            if (matches) {
                matchingSkills.push(skill);
            }
        });
        
        return matchingSkills;
    }

    getSkill(skillName) {
        return this.registry[skillName];
    }

    listSkills() {
        return Object.values(this.registry).map(skill => ({
            name: skill.name,
            title: skill.title,
            description: skill.description,
            triggerCount: skill.triggers.length,
            dependencyCount: skill.dependencies.length
        }));
    }

    validateSkillDependencies(skillName) {
        const skill = this.registry[skillName];
        if (!skill) return { valid: false, error: 'Skill not found' };
        
        const missing = [];
        
        skill.dependencies.forEach(dep => {
            // Check for required environment variables
            if (dep.includes('API key') || dep.includes('token')) {
                const envVar = dep.match(/([A-Z_]+)/);
                if (envVar && !process.env[envVar[1]]) {
                    missing.push(envVar[1]);
                }
            }
            
            // Check for required packages
            if (dep.includes('npm') || dep.includes('node')) {
                try {
                    require.resolve(dep.split(' ')[0]);
                } catch (error) {
                    missing.push(dep);
                }
            }
        });
        
        return {
            valid: missing.length === 0,
            missing: missing
        };
    }
}

module.exports = SkillRegistry;
```

## Advanced Skill Patterns

### Skills That Call APIs

Example skill that integrates with Stripe for revenue reporting:

```javascript
// ~/.openclaw/workspace/skills/revenue-reports/scripts/stripe-integration.js
const stripe = require('stripe')(process.env.STRIPE_SECRET_KEY);

class StripeRevenueReporter {
    constructor() {
        this.stripe = stripe;
    }

    async getRevenueData(startDate, endDate) {
        try {
            // Fetch charges in date range
            const charges = await this.stripe.charges.list({
                created: {
                    gte: Math.floor(startDate.getTime() / 1000),
                    lte: Math.floor(endDate.getTime() / 1000)
                },
                limit: 100
            });

            // Fetch subscription data
            const subscriptions = await this.stripe.subscriptions.list({
                status: 'active',
                limit: 100
            });

            // Calculate metrics
            const totalRevenue = charges.data
                .filter(charge => charge.status === 'succeeded')
                .reduce((sum, charge) => sum + charge.amount, 0) / 100;

            const monthlyRecurring = subscriptions.data
                .reduce((sum, sub) => {
                    const price = sub.items.data[0]?.price?.unit_amount || 0;
                    return sum + (price / 100);
                }, 0);

            return {
                totalRevenue,
                monthlyRecurring,
                transactionCount: charges.data.length,
                activeSubscriptions: subscriptions.data.length,
                averageTransaction: totalRevenue / charges.data.length || 0
            };

        } catch (error) {
            console.error('Stripe API error:', error.message);
            throw error;
        }
    }

    async generateReport(days = 30) {
        const endDate = new Date();
        const startDate = new Date(endDate.getTime() - days * 24 * 60 * 60 * 1000);
        
        const data = await this.getRevenueData(startDate, endDate);
        
        return {
            period: `${startDate.toDateString()} - ${endDate.toDateString()}`,
            ...data,
            generatedAt: new Date().toISOString()
        };
    }
}

module.exports = StripeRevenueReporter;
```

### Skills That Generate Files

Template-based file generation skill:

```javascript
// ~/.openclaw/workspace/skills/contract-generator/scripts/contract-builder.js
const fs = require('fs');
const path = require('path');

class ContractBuilder {
    constructor() {
        this.templatesDir = path.join(__dirname, '../assets/templates');
    }

    generateServiceAgreement(clientData, serviceData) {
        const templatePath = path.join(this.templatesDir, 'service-agreement.md');
        let template = fs.readFileSync(templatePath, 'utf8');
        
        // Replace placeholders
        const replacements = {
            '{{CLIENT_NAME}}': clientData.name,
            '{{CLIENT_ADDRESS}}': clientData.address,
            '{{CLIENT_EMAIL}}': clientData.email,
            '{{SERVICE_DESCRIPTION}}': serviceData.description,
            '{{SERVICE_PRICE}}': serviceData.price,
            '{{START_DATE}}': serviceData.startDate,
            '{{END_DATE}}': serviceData.endDate,
            '{{PAYMENT_TERMS}}': serviceData.paymentTerms,
            '{{GENERATED_DATE}}': new Date().toLocaleDateString()
        };

        Object.entries(replacements).forEach(([placeholder, value]) => {
            template = template.replace(new RegExp(placeholder, 'g'), value);
        });

        // Generate unique filename
        const timestamp = new Date().toISOString().slice(0, 10);
        const clientSlug = clientData.name.toLowerCase().replace(/\s+/g, '-');
        const filename = `service-agreement-${clientSlug}-${timestamp}.md`;
        
        const outputPath = path.join(process.cwd(), filename);
        fs.writeFileSync(outputPath, template);
        
        return outputPath;
    }
}

module.exports = ContractBuilder;
```

### Skills With Configuration Options

Configurable email newsletter skill:

```javascript
// ~/.openclaw/workspace/skills/newsletter/scripts/newsletter-generator.js
const { Resend } = require('resend');
const fs = require('fs');
const path = require('path');

class NewsletterGenerator {
    constructor() {
        this.resend = new Resend(process.env.RESEND_API_KEY);
        this.config = this.loadConfig();
    }

    loadConfig() {
        const configPath = path.join(__dirname, '../config/newsletter-config.json');
        
        if (fs.existsSync(configPath)) {
            return JSON.parse(fs.readFileSync(configPath, 'utf8'));
        }
        
        // Default configuration
        return {
            fromName: 'Your Newsletter',
            fromEmail: 'newsletter@yourdomain.com',
            replyTo: 'hello@yourdomain.com',
            template: 'default',
            frequency: 'weekly',
            categories: ['tech', 'business', 'updates'],
            maxArticles: 5,
            includeFooter: true
        };
    }

    async generateNewsletter(articles, customConfig = {}) {
        const config = { ...this.config, ...customConfig };
        
        // Load template
        const templatePath = path.join(__dirname, `../assets/templates/${config.template}.html`);
        let template = fs.readFileSync(templatePath, 'utf8');
        
        // Generate content sections
        const contentSections = articles.slice(0, config.maxArticles).map(article => `
            <div class="article">
                <h2>${article.title}</h2>
                <p class="meta">Published on ${article.date}</p>
                <p>${article.summary}</p>
                <a href="${article.url}" class="read-more">Read More →</a>
            </div>
        `).join('');
        
        // Replace template variables
        const html = template
            .replace('{{CONTENT_SECTIONS}}', contentSections)
            .replace('{{NEWSLETTER_NAME}}', config.fromName)
            .replace('{{GENERATED_DATE}}', new Date().toLocaleDateString())
            .replace('{{UNSUBSCRIBE_URL}}', config.unsubscribeUrl || '#');
        
        return html;
    }

    async sendNewsletter(subscribers, html, subject) {
        const results = [];
        
        for (const subscriber of subscribers) {
            try {
                const result = await this.resend.emails.send({
                    from: `${this.config.fromName} <${this.config.fromEmail}>`,
                    to: subscriber.email,
                    subject: subject,
                    html: html.replace('{{SUBSCRIBER_NAME}}', subscriber.name || 'Friend')
                });
                
                results.push({ 
                    email: subscriber.email, 
                    success: true, 
                    messageId: result.data.id 
                });
                
                // Rate limiting
                await new Promise(resolve => setTimeout(resolve, 100));
                
            } catch (error) {
                results.push({ 
                    email: subscriber.email, 
                    success: false, 
                    error: error.message 
                });
            }
        }
        
        return results;
    }
}

module.exports = NewsletterGenerator;
```

## ClawHub Integration

Publish your skills to the community marketplace:

### Step 1: Prepare for Publishing

```bash
# Ensure your skill is complete
cd ~/.openclaw/workspace/skills/weather-reports

# Create comprehensive README
cat > README.md << 'EOF'
# Weather Reports Skill

Professional weather analysis and business impact reports for OpenClaw.

## Features

- Real-time weather data from Open-Meteo API
- 7-day forecasts with business impact analysis
- Automated report generation in Markdown and JSON
- Business-focused recommendations and alerts
- No API keys required

## Installation

```bash
npm install
```

## Usage

```javascript
const WeatherReportsSkill = require('./scripts/main.js');
const skill = new WeatherReportsSkill();

// Generate full report
const result = await skill.generateReport('Chicago, IL');

// Quick forecast
const forecast = await skill.quickForecast('San Francisco, CA');
```

## Configuration

Optional environment variables:
- `DEFAULT_LOCATION` - Default location for reports
- `TEMPERATURE_UNIT` - fahrenheit or celsius (default: fahrenheit)

## License

MIT
EOF

# Test your skill thoroughly
npm test
```

### Step 2: Publish to ClawHub

```bash
# Install ClawHub CLI if not already installed
npm install -g @openclaw/clawhub-cli

# Login to ClawHub
clawhub login

# Initialize skill for publishing
clawhub init

# Publish skill
clawhub publish

# Update existing skill
clawhub publish --version 1.0.1
```

## Pro Tips

**🎯 Single Purpose:** Each skill should solve one specific problem well, not try to be a Swiss Army knife.

**📝 Document Everything:** Your SKILL.md is your marketing page. Make it clear, comprehensive, and compelling.

**🔧 Handle Errors Gracefully:** Business skills need to fail elegantly. Always provide meaningful error messages and fallback options.

**⚡ Performance Matters:** Skills should respond quickly. Cache data when possible, use async operations, and implement timeouts.

**🧪 Test Thoroughly:** Create test cases for success scenarios, error conditions, and edge cases. Users will find every bug.

## Troubleshooting

### Issue 1: Skill Not Loading
**Symptoms:** OpenClaw doesn't recognize your skill
**Diagnosis:** SKILL.md missing or malformed
**Fix:**
```bash
# Verify SKILL.md exists and is properly formatted
ls -la ~/.openclaw/workspace/skills/your-skill/SKILL.md

# Check for syntax errors
node -e "console.log('SKILL.md syntax check passed')"
```

### Issue 2: Dependencies Not Found
**Symptoms:** Skill fails with "module not found" errors
**Diagnosis:** npm dependencies not installed or wrong versions
**Fix:**
```bash
cd ~/.openclaw/workspace/skills/your-skill
npm install
npm audit fix
```

### Issue 3: API Rate Limiting
**Symptoms:** Skill works sometimes, fails other times
**Diagnosis:** Hitting API rate limits
**Fix:**
```javascript
// Add rate limiting to your skill
class RateLimitedAPI {
    constructor(requestsPerMinute = 60) {
        this.requests = [];
        this.limit = requestsPerMinute;
    }
    
    async makeRequest(apiCall) {
        await this.checkRateLimit();
        this.requests.push(Date.now());
        return apiCall();
    }
    
    async checkRateLimit() {
        const now = Date.now();
        this.requests = this.requests.filter(time => now - time < 60000);
        
        if (this.requests.length >= this.limit) {
            const waitTime = 60000 - (now - this.requests[0]);
            await new Promise(resolve => setTimeout(resolve, waitTime));
        }
    }
}
```

### Issue 4: Configuration Not Loading
**Symptoms:** Skill uses default values instead of configuration
**Diagnosis:** Config file path or format issues
**Fix:**
```javascript
// Robust config loading
loadConfig() {
    const configPaths = [
        path.join(__dirname, '../config/config.json'),
        path.join(process.env.HOME, '.openclaw/skills-config.json'),
        path.join(process.cwd(), 'skill-config.json')
    ];
    
    for (const configPath of configPaths) {
        try {
            if (fs.existsSync(configPath)) {
                return JSON.parse(fs.readFileSync(configPath, 'utf8'));
            }
        } catch (error) {
            console.warn(`Failed to load config from ${configPath}:`, error.message);
        }
    }
    
    return this.getDefaultConfig();
}
```

### Issue 5: Template Processing Errors
**Symptoms:** Generated files have placeholder text instead of actual values
**Diagnosis:** Template variables not properly replaced
**Fix:**
```javascript
// Robust template processing
processTemplate(template, variables) {
    let processed = template;
    
    Object.entries(variables).forEach(([key, value]) => {
        const placeholder = `{{${key}}}`;
        const regex = new RegExp(placeholder.replace(/[{}]/g, '\\$&'), 'g');
        
        // Handle null/undefined values
        const replacement = value !== null && value !== undefined ? 
            String(value) : 
            `[${key} not provided]`;
            
        processed = processed.replace(regex, replacement);
    });
    
    // Check for unreplaced placeholders
    const remainingPlaceholders = processed.match(/\{\{[^}]+\}\}/g);
    if (remainingPlaceholders) {
        console.warn('Unreplaced placeholders found:', remainingPlaceholders);
    }
    
    return processed;
}
```

Custom skills are your competitive advantage. While everyone else uses the same generic tools, you build specialized solutions that fit your exact needs. Master skill development, and you'll never be constrained by what others think you need.

Build skills that make you irreplaceable in your market. This is how you turn AI from a cost center into a profit engine.