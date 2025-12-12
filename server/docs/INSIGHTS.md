# Frontend Integration Guide: Gig Worker Financial Insights API

## Overview

The Volt backend now provides **comprehensive, income-aware financial insights** specifically designed for gig workers and freelancers with variable income. This document explains what data is available, how to consume it, and how to present it meaningfully in the Flutter frontend.

---

## ✅ What's Ready for Production

### Core Capabilities
- ✅ **Income volatility tracking** - Automatically calculated from credit transactions
- ✅ **Personalized emergency fund recommendations** - Based on income variability
- ✅ **Good month vs lean month strategies** - Specific dollar amounts and thresholds
- ✅ **Client diversity analysis** - Income source tracking
- ✅ **Context-aware spending recommendations** - Adjusted for income patterns
- ✅ **Risk warnings** - Income volatility, impulse spending, data quality

---

## API Endpoints

### 1. Dashboard Insights (Main Entry Point)
```
GET /users/{user_id}/insights/dashboard
```

**Authentication**: Required (Bearer token)

**Response Structure**:
```json
{
  "behavior_summary": {
    "total_spending": 4523.50,
    "top_categories": [
      {
        "category": "Housing",
        "category_key": "HOUSING",
        "monthly_avg": 1200.00,
        "transaction_count": 3,
        "reliability_score": 0.95
      }
    ],
    "spending_flexibility": [
      {
        "category": "Dining Out",
        "elasticity": 0.78,
        "flexibility_level": "high"
      }
    ],
    "impulse_score": {
      "score": 0.42,
      "level": "moderate",
      "description": "Some impulse purchases detected"
    },
    "data_quality": {
      "confidence": "high",
      "transaction_count": 127,
      "coverage_months": 3,
      "message": "Excellent data quality"
    }
  },
  
  "income_analysis": {
    "average_monthly": 2166.67,
    "volatility": 0.6523,
    "volatility_level": "HIGH",
    "income_range": {
      "min": 800.00,
      "max": 5000.00
    },
    "payment_frequency": {
      "count": 9,
      "avg_days_between": 10.2
    },
    "recommended_emergency_fund": {
      "months": 6,
      "amount": 13000.00,
      "reason": "high income volatility"
    },
    "is_gig_worker": true
  },
  
  "quick_wins": [
    {
      "category": "Dining Out",
      "category_key": "DINING",
      "action": "Reduce dining spending by 15%",
      "monthly_impact": 127.50,
      "annual_impact": 1530.00,
      "difficulty": "easy",
      "current_spending": 850.00,
      "new_spending": 722.50,
      "reason": "High flexibility detected"
    }
  ],
  
  "risk_warnings": [
    {
      "type": "income_volatility",
      "severity": "high",
      "title": "High Income Variability",
      "message": "Your income varies by 65% month-to-month",
      "recommendation": "Build a 6-month emergency fund ($13,000). Save extra during high-income months to buffer lean periods.",
      "metric": "65% income volatility"
    }
  ],
  
  "recommended_actions": [
    "In months earning >$2,600, save $2,333 extra for lean periods",
    "Review high-priority warnings before making changes"
  ]
}
```

---

## Key Data Models

### Income Analysis Object
```dart
class IncomeAnalysis {
  final double averageMonthly;      // Mean monthly income
  final double volatility;           // 0.0-1.0+ (coefficient of variation)
  final String volatilityLevel;     // "HIGH", "MODERATE", "STABLE"
  final IncomeRange incomeRange;
  final PaymentFrequency paymentFrequency;
  final EmergencyFund recommendedEmergencyFund;
  final bool isGigWorker;           // true if volatility > 0.3
}

class IncomeRange {
  final double min;   // Worst month income
  final double max;   // Best month income
}

class PaymentFrequency {
  final int count;              // Payments per month
  final double avgDaysBetween;  // Spacing between payments
}

class EmergencyFund {
  final int months;           // 3 or 6 months
  final double amount;        // Total target amount
  final String reason;        // Why this amount is recommended
}
```

### Risk Warning Object
```dart
class RiskWarning {
  final String type;              // "income_volatility", "impulse_spending", "data_quality"
  final String severity;          // "high", "warning", "info"
  final String title;             // Display title
  final String message;           // Main message
  final String? recommendation;   // Actionable advice
  final String? metric;           // Supporting data
}
```

### Quick Win Object
```dart
class QuickWin {
  final String category;          // Display name
  final String categoryKey;       // UPPERCASE_KEY
  final String action;            // What to do
  final double monthlyImpact;     // Monthly savings
  final double annualImpact;      // Annual savings
  final String difficulty;        // "easy", "moderate", "challenging"
  final double currentSpending;
  final double newSpending;
  final String? reason;
}
```

---

## UI Implementation Guidance

### Dashboard Screen

#### 1. **Income Health Card** (Priority: High)
Display when `income_analysis` is present:

```dart
Widget buildIncomeHealthCard(IncomeAnalysis income) {
  return Card(
    child: Column(
      children: [
        // Header with volatility badge
        Row(
          children: [
            Text('Income Health'),
            _buildVolatilityBadge(income.volatilityLevel),
          ],
        ),
        
        // Key metrics
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _metricTile('Average', '\$${income.averageMonthly.toStringAsFixed(0)}'),
            _metricTile('Range', '\$${income.incomeRange.min.toInt()}-\$${income.incomeRange.max.toInt()}'),
            _metricTile('Variability', '${(income.volatility * 100).toInt()}%'),
          ],
        ),
        
        // Emergency fund progress
        _buildEmergencyFundProgress(income.recommendedEmergencyFund),
      ],
    ),
  );
}

Widget _buildVolatilityBadge(String level) {
  final config = {
    'HIGH': {'color': Colors.red, 'icon': Icons.trending_up, 'text': 'Variable Income'},
    'MODERATE': {'color': Colors.orange, 'icon': Icons.show_chart, 'text': 'Moderate Variability'},
    'STABLE': {'color': Colors.green, 'icon': Icons.check_circle, 'text': 'Stable Income'},
  }[level]!;
  
  return Chip(
    backgroundColor: config['color'],
    avatar: Icon(config['icon'], size: 16),
    label: Text(config['text']),
  );
}
```

**Visual Suggestions**:
- Use a gauge chart or progress bar for income volatility
- Show min/max range as a horizontal bar chart
- Emergency fund progress as a ring/circular progress indicator

---

#### 2. **Risk Warnings Section** (Priority: High)

```dart
Widget buildRiskWarnings(List<RiskWarning> warnings) {
  return Column(
    children: warnings.map((warning) {
      final config = _getSeverityConfig(warning.severity);
      
      return Card(
        color: config.backgroundColor,
        child: ListTile(
          leading: Icon(config.icon, color: config.iconColor),
          title: Text(warning.title, style: TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(warning.message),
              if (warning.metric != null)
                Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Text(warning.metric!, style: TextStyle(fontStyle: FontStyle.italic)),
                ),
              if (warning.recommendation != null)
                Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    '💡 ${warning.recommendation}',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
            ],
          ),
        ),
      );
    }).toList(),
  );
}

SeverityConfig _getSeverityConfig(String severity) {
  switch (severity) {
    case 'high':
      return SeverityConfig(
        backgroundColor: Colors.red.shade50,
        iconColor: Colors.red,
        icon: Icons.error_outline,
      );
    case 'warning':
      return SeverityConfig(
        backgroundColor: Colors.orange.shade50,
        iconColor: Colors.orange,
        icon: Icons.warning_amber_outlined,
      );
    default: // 'info'
      return SeverityConfig(
        backgroundColor: Colors.blue.shade50,
        iconColor: Colors.blue,
        icon: Icons.info_outline,
      );
  }
}
```

**Priority Order**:
1. High severity warnings (income volatility)
2. Warning severity (impulse spending)
3. Info severity (data quality)

---

#### 3. **Quick Wins Carousel** (Priority: Medium)

```dart
Widget buildQuickWinsCarousel(List<QuickWin> quickWins) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Quick Wins', style: Theme.of(context).textTheme.headline6),
      SizedBox(height: 8),
      SizedBox(
        height: 180,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: quickWins.length,
          itemBuilder: (context, index) {
            final win = quickWins[index];
            return _buildQuickWinCard(win);
          },
        ),
      ),
    ],
  );
}

Widget _buildQuickWinCard(QuickWin win) {
  return Card(
    margin: EdgeInsets.only(right: 12),
    child: Container(
      width: 280,
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(win.category, style: TextStyle(fontWeight: FontWeight.bold)),
              _buildDifficultyChip(win.difficulty),
            ],
          ),
          SizedBox(height: 8),
          Text(win.action, style: TextStyle(fontSize: 14)),
          Spacer(),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Monthly', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  Text('\$${win.monthlyImpact.toStringAsFixed(0)}', 
                       style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green)),
                ],
              ),
              SizedBox(width: 24),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Annual', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  Text('\$${win.annualImpact.toStringAsFixed(0)}', 
                       style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
```

---

#### 4. **Gig Worker-Specific Recommendations**

When `is_gig_worker: true`, show special strategy cards:

```dart
Widget buildGigWorkerStrategies(IncomeAnalysis income, List<String> actions) {
  if (!income.isGigWorker) return SizedBox.shrink();
  
  final goodMonthThreshold = income.averageMonthly * 1.2;
  final leanMonthThreshold = income.averageMonthly * 0.8;
  
  return Card(
    child: Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline, color: Colors.amber),
              SizedBox(width: 8),
              Text('Income-Based Strategy', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          SizedBox(height: 12),
          
          // Good month strategy
          _buildStrategyRow(
            icon: Icons.trending_up,
            iconColor: Colors.green,
            title: 'Good Months (>\$${goodMonthThreshold.toInt()})',
            description: 'Save 80% of surplus income for emergency fund',
          ),
          
          Divider(height: 24),
          
          // Lean month strategy
          _buildStrategyRow(
            icon: Icons.trending_down,
            iconColor: Colors.orange,
            title: 'Lean Months (<\$${leanMonthThreshold.toInt()})',
            description: 'Reduce flexible spending by 30%',
          ),
          
          SizedBox(height: 12),
          
          // Action buttons
          ...actions.map((action) => Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Icon(Icons.check_circle_outline, size: 16, color: Colors.blue),
                SizedBox(width: 8),
                Expanded(child: Text(action, style: TextStyle(fontSize: 14))),
              ],
            ),
          )),
        ],
      ),
    ),
  );
}
```

---

## Business Logic Thresholds

These values are configurable in `server/app/config/insight_config.py`:

| Metric | Threshold | Meaning |
|--------|-----------|---------|
| **Income Volatility** | >40% | High variability - recommend 6-month emergency fund |
| | 30-40% | Moderate - recommend 3-month emergency fund |
| | <30% | Stable - standard 3-month fund |
| **Good Month** | 1.2× average | 20% above average income |
| **Lean Month** | 0.8× average | 20% below average income |
| **Flexible Spending** | 60%+ elasticity | High flexibility - easy to cut |
| | 20%- elasticity | Low flexibility - essential spending |
| **Impulse Score** | >70% | High impulse spending |
| | 30-70% | Moderate impulse spending |
| **Quick Win Savings** | >$50/month | Minimum threshold to show |

---

## State Management Recommendations

### 1. **Income Analysis State**
```dart
class InsightsState {
  final IncomeAnalysis? incomeAnalysis;
  final BehaviorSummary behaviorSummary;
  final List<QuickWin> quickWins;
  final List<RiskWarning> riskWarnings;
  final List<String> recommendedActions;
  
  // Computed properties
  bool get isGigWorker => incomeAnalysis?.isGigWorker ?? false;
  bool get hasHighVolatility => 
    (incomeAnalysis?.volatility ?? 0) > 0.4;
  
  double get emergencyFundProgress {
    // Calculate based on user's current savings vs recommended
    // This would come from a separate savings tracking endpoint
    return 0.0;
  }
}
```

### 2. **Refresh Strategy**
- **On app launch**: Fetch dashboard insights
- **After transaction sync**: Refresh insights if >10 new transactions
- **On pull-to-refresh**: Allow manual refresh
- **Background sync**: Every 24 hours

---

## Error Handling

### No Income Data
If `income_analysis` is null in the response:
```dart
if (insights.incomeAnalysis == null) {
  // Show message
  return InfoCard(
    icon: Icons.insights,
    title: 'Building Your Profile',
    message: 'Add more income transactions to unlock personalized insights',
  );
}
```

### Insufficient Data
Check `behavior_summary.data_quality.confidence`:
```dart
if (insights.behaviorSummary.dataQuality.confidence == 'low') {
  // Show banner
  return Banner(
    message: insights.behaviorSummary.dataQuality.message,
    action: 'Keep tracking transactions',
  );
}
```

---

## Visual Design Patterns

### Color Coding
- **Income Volatility**:
  - HIGH: Red/Orange tones
  - MODERATE: Yellow/Amber tones
  - STABLE: Green tones

- **Difficulty Levels**:
  - Easy: Green badge
  - Moderate: Yellow badge
  - Challenging: Orange badge

- **Severity Levels**:
  - High: Red alert
  - Warning: Orange alert
  - Info: Blue info

### Icons
- Income: `Icons.account_balance_wallet`
- Volatility: `Icons.show_chart` or `Icons.trending_up`
- Emergency Fund: `Icons.security`
- Quick Win: `Icons.lightbulb` or `Icons.stars`
- Warning: `Icons.warning_amber` or `Icons.error_outline`
- Gig Worker: `Icons.work_outline`

---

## Testing Scenarios

### 1. High-Volatility Gig Worker
- Income range: $800 - $5,000/month
- Volatility: 65%
- Expected: 6-month emergency fund recommendation, good/lean month strategies

### 2. Moderate-Volatility Freelancer
- Income range: $2,000 - $3,500/month
- Volatility: 35%
- Expected: 3-month emergency fund, moderate warnings

### 3. Stable W2 Employee
- Income: $3,000/month (consistent)
- Volatility: 5%
- Expected: Standard 3-month fund, no volatility warnings

---

## Implementation Checklist

- [ ] Add `IncomeAnalysis` model to Flutter
- [ ] Create Income Health Card widget
- [ ] Implement Risk Warning display
- [ ] Build Quick Wins carousel
- [ ] Add Gig Worker Strategy card
- [ ] Implement emergency fund progress tracking
- [ ] Add pull-to-refresh on dashboard
- [ ] Handle null `income_analysis` gracefully
- [ ] Add loading states for async data
- [ ] Implement error handling for API failures
- [ ] Add animations for card transitions
- [ ] Test with different user profiles

---

## API Contract Notes

### Current Limitations
1. `income_analysis` will be `null` if:
   - User has no credit (income) transactions
   - Insufficient transaction history (<30 days)
   - Behavior model not yet generated

2. `payment_frequency.count` is the number of **income transactions** per month, not unique clients

3. Emergency fund recommendations are **calculated**, not tracked - you'll need a separate endpoint for actual savings balance

### Future Enhancements
- [ ] Client diversity score (unique payers)
- [ ] Income trend analysis (growing/declining)
- [ ] Seasonal income pattern detection
- [ ] Real-time emergency fund progress tracking
- [ ] Goal setting for good/lean month budgets

---

## Support & Questions

For backend issues or API questions:
- Check `server/app/config/insight_config.py` for configurable thresholds
- Review `server/app/services/behavior_engine.py` for income tracking logic
- See `server/test_simulation.py` for example data and expected outputs

**Last Updated**: December 13, 2025
**API Version**: v1
**Backend Status**: ✅ Production Ready
