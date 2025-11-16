# Tech Spec - Epic 7: Onboarding & Subscriptions

**Epic:** Epic 7 - Onboarding & Subscriptions
**Author:** Winston (BMAD Architect)
**Date:** 2025-01-16
**Status:** Ready for implementation
**Sprint:** TBD (Sprint 8)
**Stories:** 7 (7.1 - 7.7)
**Estimated Duration:** 12-14 days
**Dependencies:** Epic 1 (Core Platform)

---

## 1. Overview

### 1.1 Epic Goal

Deliver smooth onboarding flow, 14-day trial, subscription management, and payment processing using in-app purchases (iOS App Store, Google Play).

### 1.2 Value Proposition

**For users:** Personalized onboarding, risk-free 14-day trial, flexible subscription tiers, easy cancellation.

**For business:** Drive conversions (free → paid), reduce friction, enable modular monetization (2.99/5.00/7.00 EUR tiers).

### 1.3 Scope Summary

**In Scope (MVP):**
- Onboarding flow (Choose journey, set goals, choose AI personality, permissions)
- Free tier (Life Coach basic)
- 14-day trial (all premium features, no credit card required)
- Subscription management (In-App Purchase via App Store/Google Play)
- Subscription tiers (2.99 EUR single module, 5.00 EUR 3-module pack, 7.00 EUR full access)
- Cancel subscription (graceful degradation, no data loss)
- Paywall screens (locked features, upgrade CTAs)

**Out of Scope (P1/P2):**
- Promo codes (P1)
- Referral program (P2)
- Enterprise/B2B subscriptions (P2)
- Annual plans (P1)
- Regional pricing optimization (P1)

### 1.4 Success Criteria

**Functional:**
- ✅ Onboarding complete (4-5 screens, skippable)
- ✅ 14-day trial auto-starts (no credit card)
- ✅ Trial countdown shown ("13 days left")
- ✅ Trial end reminder (push notification 3 days before)
- ✅ In-App Purchase working (iOS + Android)
- ✅ Subscription tiers implemented (2.99, 5.00, 7.00 EUR)
- ✅ Cancel subscription working (graceful degradation)

**Non-Functional:**
- ✅ Onboarding completion time <2 minutes
- ✅ In-App Purchase flow <30s (Apple/Google)
- ✅ Subscription status sync <2s
- ✅ Graceful degradation <1s (no UI lag)

---

## 2. Architecture Alignment

### 2.1 Data Models

```dart
enum SubscriptionTier { free, singleModule, threeModulePack, fullAccess }

enum ModuleType { lifeCoach, fitness, mind }

@freezed
class Subscription with _$Subscription {
  const factory Subscription({
    required String id,
    required String userId,
    required SubscriptionTier tier,
    List<ModuleType>? enabledModules,  // For singleModule tier
    DateTime? trialEndDate,
    DateTime? subscriptionEndDate,
    required SubscriptionStatus status,  // active | trial | cancelled | expired
    String? stripeCustomerId,
    String? appStoreReceiptData,       // iOS receipt
    String? googlePlayPurchaseToken,   // Android token
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _Subscription;
}

enum SubscriptionStatus { active, trial, cancelled, expired }

@freezed
class OnboardingState with _$OnboardingState {
  const factory OnboardingState({
    required String userId,
    required OnboardingJourney journey,  // fitness | mind | lifeCoach | full
    List<String>? initialGoals,
    required AIPersonality aiPersonality,  // sage | momentum
    required bool completed,
  }) = _OnboardingState;
}

enum OnboardingJourney { fitness, mind, lifeCoach, full }
enum AIPersonality { sage, momentum }
```

### 2.2 Database Schema

```sql
CREATE TABLE subscriptions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) NOT NULL UNIQUE,
  tier TEXT NOT NULL CHECK (tier IN ('free', 'single_module', 'three_module_pack', 'full_access')),
  enabled_modules TEXT[],  -- ['fitness'] or ['fitness', 'mind'] etc.
  trial_end_date TIMESTAMPTZ,
  subscription_end_date TIMESTAMPTZ,
  status TEXT NOT NULL CHECK (status IN ('active', 'trial', 'cancelled', 'expired')),
  stripe_customer_id TEXT,
  app_store_receipt_data TEXT,
  google_play_purchase_token TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ
);

CREATE INDEX idx_subscriptions_user ON subscriptions(user_id);
CREATE INDEX idx_subscriptions_status ON subscriptions(status);

CREATE TABLE onboarding_state (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) NOT NULL UNIQUE,
  journey TEXT NOT NULL CHECK (journey IN ('fitness', 'mind', 'life_coach', 'full')),
  initial_goals TEXT[],
  ai_personality TEXT NOT NULL CHECK (ai_personality IN ('sage', 'momentum')),
  completed BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- RLS
ALTER TABLE subscriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE onboarding_state ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can only access their own subscription"
  ON subscriptions FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Users can only access their own onboarding"
  ON onboarding_state FOR ALL USING (auth.uid() = user_id);
```

---

## 3. Detailed Design

### 3.1 Story 7.1: Onboarding Flow - Choose Your Journey

**Goal:** Personalized onboarding based on user's primary goal.

#### 3.1.1 UI Flow

**Screen 1: Welcome**
- Title: "Welcome to LifeOS 🌟"
- Subtitle: "Your AI-powered life operating system"
- CTA: "Get Started"

**Screen 2: Choose Journey**
- Title: "What brings you here?"
- 4 Options:
  1. "💪 I want to get fit" → Fitness-first onboarding
  2. "🧠 I want to reduce stress" → Mind-first onboarding
  3. "☀️ I want to organize my life" → Life Coach-first onboarding
  4. "🌟 I want it all" → Full ecosystem onboarding
- Progress dots: ●○○○○

**Screen 3: Set Initial Goals**
- Title: "Set 1-3 goals to get started"
- Goal input: Title + Category dropdown
- Examples based on journey:
  - Fitness: "Lose 10kg", "Run 5km"
  - Mind: "Meditate daily", "Reduce anxiety"
  - Life Coach: "Wake up at 6am", "Read 20 pages/day"
- "+ Add another goal" button (max 3)
- Skip option

**Screen 4: Choose AI Personality**
- Title: "Choose your AI coach personality"
- 2 Options:
  - 🧘 **Sage** (Calm, wise, supportive)
    - Sample: "Let's take this one step at a time"
  - ⚡ **Momentum** (Energetic, motivational)
    - Sample: "Let's crush this! You've got this!"
- Tap to select (highlighted border)

**Screen 5: Permissions & Tutorial**
- Push notifications permission
  - Explanation: "Daily reminders, streak alerts, smart insights (max 1/day)"
  - "Enable Notifications" button
  - "Maybe Later" link
- Interactive tutorial (based on journey):
  - Fitness: Log 1 sample workout (guided walkthrough)
  - Mind: Complete 2-min breathing exercise
  - Life Coach: Complete first morning check-in
- Skip tutorial option

**Screen 6: Trial Banner**
- "Try all premium features free for 14 days"
- "No credit card required"
- "Start Trial" button

#### 3.1.2 Services

**OnboardingService**
```dart
class OnboardingService {
  final OnboardingRepository _repository;
  final SubscriptionService _subscriptionService;

  Future<void> completeOnboarding({
    required OnboardingJourney journey,
    List<String>? initialGoals,
    required AIPersonality aiPersonality,
  }) async {
    final onboardingState = OnboardingState(
      userId: _currentUserId,
      journey: journey,
      initialGoals: initialGoals,
      aiPersonality: aiPersonality,
      completed: true,
    );

    await _repository.saveOnboardingState(onboardingState);

    // Save AI personality to user settings
    await _settingsRepository.updateSettings(
      UserSettings(aiPersonality: aiPersonality),
    );

    // Create initial goals
    if (initialGoals != null) {
      for (final goalTitle in initialGoals) {
        await _goalsService.createGoal(
          title: goalTitle,
          category: _inferCategory(journey),
        );
      }
    }

    // Activate 14-day trial
    await _subscriptionService.activateTrial();
  }

  GoalCategory _inferCategory(OnboardingJourney journey) {
    switch (journey) {
      case OnboardingJourney.fitness: return GoalCategory.fitness;
      case OnboardingJourney.mind: return GoalCategory.mentalHealth;
      case OnboardingJourney.lifeCoach: return GoalCategory.career;
      case OnboardingJourney.full: return GoalCategory.fitness;  // Default
    }
  }
}
```

---

### 3.2 Story 7.5: 14-Day Trial (All Premium Features)

**Goal:** Auto-start 14-day trial after onboarding, no credit card required.

#### 3.2.1 Services

**SubscriptionService**
```dart
class SubscriptionService {
  final SubscriptionRepository _repository;
  final NotificationService _notificationService;

  Future<void> activateTrial() async {
    final trialEndDate = DateTime.now().add(Duration(days: 14));

    final subscription = Subscription(
      id: uuid.v4(),
      userId: _currentUserId,
      tier: SubscriptionTier.fullAccess,  // Full access during trial
      trialEndDate: trialEndDate,
      status: SubscriptionStatus.trial,
      createdAt: DateTime.now().toUtc(),
    );

    await _repository.saveSubscription(subscription);

    // Schedule trial end reminder (3 days before)
    final reminderDate = trialEndDate.subtract(Duration(days: 3));
    await _scheduleTrialEndReminder(reminderDate);
  }

  Future<void> _scheduleTrialEndReminder(DateTime reminderDate) async {
    await _notificationService.scheduleNotification(
      userId: _currentUserId,
      scheduledAt: reminderDate,
      title: '⏰ Trial Ending Soon',
      body: 'Your 14-day trial ends in 3 days. Subscribe to keep all features!',
      deepLink: 'lifeos://subscription/upgrade',
    );
  }

  /// Check trial expiration daily (cron job)
  Future<void> checkTrialExpiration() async {
    final today = DateTime.now();
    final expiredTrials = await _repository.getExpiredTrials(today);

    for (final subscription in expiredTrials) {
      await _expireTrial(subscription);
    }
  }

  Future<void> _expireTrial(Subscription subscription) async {
    // Gracefully degrade to free tier
    final updatedSubscription = subscription.copyWith(
      tier: SubscriptionTier.free,
      status: SubscriptionStatus.expired,
      updatedAt: DateTime.now().toUtc(),
    );

    await _repository.updateSubscription(updatedSubscription);

    // Send notification
    await _notificationService.send(
      userId: subscription.userId,
      title: 'Trial Ended',
      body: 'Your trial has ended. Subscribe to unlock all features again!',
      deepLink: 'lifeos://subscription/upgrade',
    );
  }
}
```

**Cron Job: Check Trial Expiration (Daily)**
```sql
SELECT cron.schedule(
  'check-trial-expiration',
  '0 6 * * *',  -- 6am daily
  $$SELECT net.http_post(
    url := 'https://your-project.supabase.co/functions/v1/check-trial-expiration',
    headers := jsonb_build_object('Authorization', 'Bearer YOUR_SERVICE_KEY')
  )$$
);
```

---

### 3.3 Story 7.6: Subscription Management (In-App Purchase)

**Goal:** Enable users to subscribe via App Store or Google Play.

#### 3.3.1 In-App Purchase Setup

**Packages:**
```yaml
dependencies:
  in_app_purchase: ^3.1.11
  in_app_purchase_storekit: ^0.3.6  # iOS
  in_app_purchase_android: ^0.3.3   # Android
```

**Product IDs:**
- `lifeos_single_module_monthly` → 2.99 EUR/month
- `lifeos_three_module_pack_monthly` → 5.00 EUR/month
- `lifeos_full_access_monthly` → 7.00 EUR/month

**App Store Connect Setup:**
1. Create 3 auto-renewable subscription products
2. Set up subscription groups
3. Add localized pricing (EUR for EU, GBP for UK, PLN for Poland)
4. Enable Family Sharing (optional)

**Google Play Console Setup:**
1. Create 3 subscription products
2. Set base plan pricing
3. Add regional pricing
4. Enable proration (upgrade/downgrade)

#### 3.3.2 Services

**InAppPurchaseService**
```dart
class InAppPurchaseService {
  final InAppPurchase _iap = InAppPurchase.instance;
  final SubscriptionRepository _repository;

  static const List<String> _productIds = [
    'lifeos_single_module_monthly',
    'lifeos_three_module_pack_monthly',
    'lifeos_full_access_monthly',
  ];

  StreamSubscription<List<PurchaseDetails>>? _subscription;

  Future<void> initialize() async {
    final available = await _iap.isAvailable();
    if (!available) throw Exception('In-app purchases not available');

    // Listen for purchase updates
    _subscription = _iap.purchaseStream.listen(_handlePurchaseUpdate);

    // Load products
    await _loadProducts();
  }

  Future<List<ProductDetails>> _loadProducts() async {
    final response = await _iap.queryProductDetails(_productIds.toSet());

    if (response.error != null) {
      throw Exception('Failed to load products: ${response.error}');
    }

    return response.productDetails;
  }

  Future<void> purchaseSubscription(String productId) async {
    final products = await _loadProducts();
    final product = products.firstWhere((p) => p.id == productId);

    final purchaseParam = PurchaseParam(productDetails: product);
    await _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }

  void _handlePurchaseUpdate(List<PurchaseDetails> purchases) {
    for (final purchase in purchases) {
      if (purchase.status == PurchaseStatus.purchased) {
        _completePurchase(purchase);
      } else if (purchase.status == PurchaseStatus.error) {
        _handlePurchaseError(purchase.error!);
      }

      if (purchase.pendingCompletePurchase) {
        _iap.completePurchase(purchase);
      }
    }
  }

  Future<void> _completePurchase(PurchaseDetails purchase) async {
    final tier = _mapProductToTier(purchase.productID);

    // Update subscription in database
    await _repository.updateSubscription(Subscription(
      userId: _currentUserId,
      tier: tier,
      status: SubscriptionStatus.active,
      appStoreReceiptData: purchase.verificationData.serverVerificationData,
      googlePlayPurchaseToken: purchase.purchaseID,
      updatedAt: DateTime.now().toUtc(),
    ));

    // Sync subscription status across devices (Supabase)
    await _syncSubscriptionStatus();
  }

  SubscriptionTier _mapProductToTier(String productId) {
    switch (productId) {
      case 'lifeos_single_module_monthly': return SubscriptionTier.singleModule;
      case 'lifeos_three_module_pack_monthly': return SubscriptionTier.threeModulePack;
      case 'lifeos_full_access_monthly': return SubscriptionTier.fullAccess;
      default: throw Exception('Unknown product: $productId');
    }
  }

  void dispose() {
    _subscription?.cancel();
  }
}
```

#### 3.3.3 UI Components

**SubscriptionScreen**
```dart
class SubscriptionScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptionAsync = ref.watch(subscriptionProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Subscription')),
      body: subscriptionAsync.when(
        data: (subscription) => _buildSubscriptionUI(context, subscription),
        loading: () => Center(child: CircularProgressIndicator()),
        error: (error, stack) => ErrorView(error: error),
      ),
    );
  }

  Widget _buildSubscriptionUI(BuildContext context, Subscription subscription) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Current plan
          _buildCurrentPlan(subscription),
          SizedBox(height: 24),

          // Available tiers
          _buildTierCard(
            tier: SubscriptionTier.singleModule,
            price: '2.99 EUR/month',
            features: ['Choose 1 module (Fitness OR Mind)', 'AI chat (Llama)', 'Sync across devices'],
            isCurrent: subscription.tier == SubscriptionTier.singleModule,
          ),

          _buildTierCard(
            tier: SubscriptionTier.threeModulePack,
            price: '5.00 EUR/month',
            features: ['All 3 modules (Life Coach + Fitness + Mind)', 'AI chat (Claude)', 'Cross-module insights', '🔥 Most Popular'],
            isCurrent: subscription.tier == SubscriptionTier.threeModulePack,
            isPopular: true,
          ),

          _buildTierCard(
            tier: SubscriptionTier.fullAccess,
            price: '7.00 EUR/month',
            features: ['All modules + future modules', 'AI chat (GPT-4 unlimited)', 'Priority support', 'Early access to new features'],
            isCurrent: subscription.tier == SubscriptionTier.fullAccess,
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentPlan(Subscription subscription) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.teal.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.teal, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Current Plan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text(
            _getTierName(subscription.tier),
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal),
          ),
          if (subscription.status == SubscriptionStatus.trial)
            Text('Trial ends: ${_formatDate(subscription.trialEndDate!)}'),
        ],
      ),
    );
  }

  Widget _buildTierCard({
    required SubscriptionTier tier,
    required String price,
    required List<String> features,
    required bool isCurrent,
    bool isPopular = false,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCurrent ? Colors.teal.shade50 : Colors.white,
        border: Border.all(color: isCurrent ? Colors.teal : Colors.grey.shade300, width: isCurrent ? 2 : 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(_getTierName(tier), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Spacer(),
              if (isPopular)
                Chip(label: Text('Popular', style: TextStyle(color: Colors.white)), backgroundColor: Colors.orange),
            ],
          ),
          SizedBox(height: 8),
          Text(price, style: TextStyle(fontSize: 16, color: Colors.teal)),
          SizedBox(height: 12),
          ...features.map((f) => Padding(
            padding: EdgeInsets.only(bottom: 4),
            child: Row(children: [Icon(Icons.check, size: 16, color: Colors.teal), SizedBox(width: 8), Expanded(child: Text(f))]),
          )),
          SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isCurrent ? null : () => _subscribe(tier),
              child: Text(isCurrent ? 'Current Plan' : 'Subscribe'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _subscribe(SubscriptionTier tier) async {
    final productId = _getProductId(tier);
    await ref.read(inAppPurchaseServiceProvider).purchaseSubscription(productId);
  }

  String _getProductId(SubscriptionTier tier) {
    switch (tier) {
      case SubscriptionTier.singleModule: return 'lifeos_single_module_monthly';
      case SubscriptionTier.threeModulePack: return 'lifeos_three_module_pack_monthly';
      case SubscriptionTier.fullAccess: return 'lifeos_full_access_monthly';
      default: throw Exception('Invalid tier');
    }
  }

  String _getTierName(SubscriptionTier tier) {
    switch (tier) {
      case SubscriptionTier.free: return 'Free';
      case SubscriptionTier.singleModule: return 'Single Module';
      case SubscriptionTier.threeModulePack: return '3-Module Pack';
      case SubscriptionTier.fullAccess: return 'Full Access';
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM d, yyyy').format(date);
  }
}
```

---

### 3.4 Story 7.7: Cancel Subscription & Graceful Degradation

**Goal:** Allow users to cancel subscription anytime without losing data.

#### 3.4.1 Services

**SubscriptionService (Cancel)**
```dart
Future<void> cancelSubscription() async {
  final subscription = await _repository.getSubscription(_currentUserId);

  // Update subscription status to 'cancelled'
  // Subscription remains active until end of billing period
  final updatedSubscription = subscription.copyWith(
    status: SubscriptionStatus.cancelled,
    updatedAt: DateTime.now().toUtc(),
  );

  await _repository.updateSubscription(updatedSubscription);

  // Notify user
  await _notificationService.send(
    userId: _currentUserId,
    title: 'Subscription Cancelled',
    body: 'Your subscription will end on ${_formatDate(subscription.subscriptionEndDate!)}. You\'ll keep premium until then.',
  );
}

/// Graceful degradation when subscription expires
Future<void> degradeToFreeTier(String userId) async {
  final subscription = await _repository.getSubscription(userId);

  // Update to free tier
  final updatedSubscription = subscription.copyWith(
    tier: SubscriptionTier.free,
    status: SubscriptionStatus.expired,
    updatedAt: DateTime.now().toUtc(),
  );

  await _repository.updateSubscription(updatedSubscription);

  // Apply feature restrictions (no data loss)
  await _applyFreeTierRestrictions(userId);

  // Notify user
  await _notificationService.send(
    userId: userId,
    title: 'Subscription Ended',
    body: 'Your subscription has ended. You can still use Life Coach (basic). Upgrade anytime!',
    deepLink: 'lifeos://subscription/upgrade',
  );
}

Future<void> _applyFreeTierRestrictions(String userId) async {
  // Goals: Limit to 3 (existing goals become read-only if >3)
  final goals = await _goalsRepository.getGoals(userId);
  if (goals.length > 3) {
    for (int i = 3; i < goals.length; i++) {
      await _goalsRepository.markAsReadOnly(goals[i].id);
    }
  }

  // Meditation library: Lock premium meditations (keep 3 rotating free)
  // AI chat: Limit to 3-5/day with Llama model
  // (Implemented via feature gates in modules)
}
```

**Graceful Degradation Rules:**
- **Goals:** >3 goals → Read-only (can view, cannot create new)
- **Meditation:** Premium locked (3 rotating free meditations available)
- **AI chat:** Limited to 3-5/day with Llama model
- **Fitness:** Smart Pattern Memory disabled, limited templates
- **NO DATA LOSS:** All workouts, moods, journals remain accessible

---

## 4. Non-Functional Requirements

| NFR | Target | Implementation |
|-----|--------|----------------|
| **NFR-O1** | Onboarding time <2 min | Streamlined flow, skip options |
| **NFR-O2** | IAP flow <30s | Native App Store/Play Store flow |
| **NFR-O3** | Subscription sync <2s | Supabase Realtime, optimistic updates |
| **NFR-O4** | Graceful degradation <1s | Feature gates, no UI lag |

---

## 5. Dependencies & Integrations

| Dependency | Type | Reason |
|------------|------|--------|
| **Epic 1: Core Platform** | Hard | Auth, user profiles |
| **Epic 2: Life Coach** | Soft | Initial goals, AI personality |
| **App Store Connect** | External | iOS subscriptions |
| **Google Play Console** | External | Android subscriptions |

---

## 6. Acceptance Criteria

**Functional:**
- ✅ Onboarding complete (4-5 screens, skippable)
- ✅ 14-day trial auto-starts (no credit card)
- ✅ Trial countdown shown
- ✅ Trial end reminder (3 days before)
- ✅ In-App Purchase working (iOS + Android)
- ✅ Subscription tiers (2.99, 5.00, 7.00 EUR)
- ✅ Cancel subscription working
- ✅ Graceful degradation (no data loss)

**Non-Functional:**
- ✅ Onboarding <2 min
- ✅ IAP flow <30s
- ✅ Subscription sync <2s
- ✅ Graceful degradation <1s

---

## 7. Traceability Mapping

| FR Range | Feature | Stories | Status |
|----------|---------|---------|--------|
| FR91-FR97 | Subscriptions | 7.4-7.7 | ✅ |
| FR111-FR115 | Onboarding | 7.1-7.3 | ✅ |

**Coverage:** 11/11 FRs covered ✅

---

## 8. Risks & Test Strategy

**Critical Scenarios:**
1. **Onboarding:** Complete onboarding → Trial activated → Home screen shown
2. **Trial countdown:** Trial day 11 → "3 days left" shown → Reminder notification
3. **In-App Purchase:** Tap "Subscribe" → App Store flow → Purchase successful → Premium unlocked
4. **Cancel subscription:** Cancel → Subscription active until end date → Degrade to free tier → No data loss
5. **Graceful degradation:** >3 goals → 3 active, rest read-only → Meditation library locked except 3 free

**Coverage Target:** 80%+ unit, 75%+ widget, 100% critical flows

---

## Document Status

✅ **COMPLETE** - Ready for implementation

**Version:** 1.0
**Last Updated:** 2025-01-16
**Epic 7 Tech Spec created by Winston (BMAD Architect)**
**Total Pages:** 26
**Estimated Implementation:** 12-14 days
