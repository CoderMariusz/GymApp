# Detailed Context: Story 4.5 - Private Journaling (E2E Encrypted)

**Epic:** Epic 4 - Mind & Emotion MVP
**Story:** 4.5 - Private Journaling (E2E Encrypted)
**Priority:** P0
**Story Points:** 4
**Status:** Ready for Implementation

---

## Table of Contents

1. [Overview](#1-overview)
2. [AES-256-GCM Encryption Implementation](#2-aes-256-gcm-encryption-implementation)
3. [Key Management & Secure Storage](#3-key-management--secure-storage)
4. [Complete Service Implementation](#4-complete-service-implementation)
5. [AI Sentiment Analysis (Opt-In)](#5-ai-sentiment-analysis-opt-in)
6. [Security Best Practices & Threat Model](#6-security-best-practices--threat-model)
7. [Performance Optimization](#7-performance-optimization)
8. [Export & GDPR Compliance](#8-export--gdpr-compliance)
9. [Testing Strategy](#9-testing-strategy)
10. [Troubleshooting Guide](#10-troubleshooting-guide)

---

## 1. Overview

### 1.1 Why This Story is Complex

**Security-Critical Requirements:**
- Client-side encryption/decryption (NEVER send plaintext to server unless AI analysis is enabled)
- Secure key generation and storage (must survive app reinstalls on same device)
- Random IV per entry (prevent pattern detection)
- Performance (<50ms encrypt/decrypt, no UI lag)
- GDPR compliance (opt-in AI analysis, export capability)

**Key Challenge:** Balance between maximum privacy (E2E encryption) and useful features (AI sentiment analysis, search).

### 1.2 Architecture Decision

```
┌─────────────────────────────────────────────────────────────┐
│                    Journal Entry Flow                        │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  User writes entry → Encrypt (AES-256-GCM) → Save locally   │
│                           ↓                                   │
│                   Sync encrypted blob to Supabase            │
│                           ↓                                   │
│         (IF AI analysis enabled) → Decrypt → Send to AI     │
│                           ↓                                   │
│                  Get sentiment → Save sentiment only         │
│                                                               │
└─────────────────────────────────────────────────────────────┘
```

**Critical Security Principle:** Supabase ONLY stores encrypted blobs. Decryption happens client-side only.

---

## 2. AES-256-GCM Encryption Implementation

### 2.1 Why AES-256-GCM?

**AES-256-GCM** (Galois/Counter Mode) chosen because:
- **Authenticated Encryption:** Provides both confidentiality AND integrity (detects tampering)
- **Industry Standard:** NIST-approved, used by Signal, WhatsApp, Google
- **Fast:** Hardware-accelerated on most devices
- **Secure:** No known practical attacks against AES-256

**Comparison with alternatives:**
| Algorithm | Confidentiality | Integrity | Performance | Verdict |
|-----------|----------------|-----------|-------------|---------|
| AES-256-CBC | ✅ | ❌ (needs HMAC) | Fast | Requires additional MAC |
| AES-256-GCM | ✅ | ✅ (built-in) | Very Fast | **WINNER** |
| ChaCha20-Poly1305 | ✅ | ✅ (built-in) | Fast (no HW) | Good alternative |

### 2.2 Complete Encryption Service

**File:** `lib/features/mind/services/encryption_service.dart`

```dart
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'dart:typed_data';

class EncryptionService {
  final FlutterSecureStorage _secureStorage;

  EncryptionService(this._secureStorage);

  // Key identifier for secure storage
  static const String _keyStorageKey = 'journal_encryption_key_v1';
  static const String _saltStorageKey = 'journal_encryption_salt_v1';

  /// Get or create encryption key (stored in secure storage)
  ///
  /// CRITICAL: This key is device-specific. If user reinstalls app,
  /// they CANNOT decrypt old journal entries (by design for E2E privacy).
  ///
  /// Future enhancement: Allow user-provided passphrase for key derivation
  /// (enables multi-device access with master password).
  Future<encrypt.Key> _getEncryptionKey() async {
    String? keyString = await _secureStorage.read(key: _keyStorageKey);

    if (keyString == null) {
      // Generate new 256-bit key (secure random)
      final key = encrypt.Key.fromSecureRandom(32);  // 32 bytes = 256 bits
      await _secureStorage.write(key: _keyStorageKey, value: key.base64);

      print('[EncryptionService] New encryption key generated and stored securely');
      return key;
    }

    return encrypt.Key.fromBase64(keyString);
  }

  /// Encrypt journal content (AES-256-GCM)
  ///
  /// Returns: EncryptedData containing:
  /// - encryptedContent (base64 encoded ciphertext + auth tag)
  /// - iv (base64 encoded initialization vector)
  ///
  /// Performance target: <50ms
  Future<EncryptedData> encryptJournal(String plaintext) async {
    final stopwatch = Stopwatch()..start();

    try {
      // Get encryption key (cached in secure storage)
      final key = await _getEncryptionKey();

      // Generate random IV (16 bytes for AES)
      // CRITICAL: NEVER reuse IV with the same key!
      final iv = encrypt.IV.fromSecureRandom(16);

      // Create AES-GCM encrypter
      final encrypter = encrypt.Encrypter(
        encrypt.AES(key, mode: encrypt.AESMode.gcm),
      );

      // Encrypt plaintext
      final encrypted = encrypter.encrypt(plaintext, iv: iv);

      stopwatch.stop();
      print('[EncryptionService] Encrypted ${plaintext.length} chars in ${stopwatch.elapsedMilliseconds}ms');

      if (stopwatch.elapsedMilliseconds > 50) {
        print('[WARNING] Encryption took longer than 50ms target');
      }

      return EncryptedData(
        encryptedContent: encrypted.base64,
        iv: iv.base64,
      );
    } catch (e) {
      print('[ERROR] Encryption failed: $e');
      rethrow;
    }
  }

  /// Decrypt journal content (AES-256-GCM)
  ///
  /// Throws: Exception if decryption fails (wrong key, corrupted data, tampering)
  ///
  /// Performance target: <50ms
  Future<String> decryptJournal(String encryptedContent, String ivString) async {
    final stopwatch = Stopwatch()..start();

    try {
      // Get encryption key
      final key = await _getEncryptionKey();
      final iv = encrypt.IV.fromBase64(ivString);

      // Create AES-GCM encrypter
      final encrypter = encrypt.Encrypter(
        encrypt.AES(key, mode: encrypt.AESMode.gcm),
      );

      // Decrypt ciphertext
      // GCM mode automatically verifies authentication tag (detects tampering)
      final decrypted = encrypter.decrypt64(encryptedContent, iv: iv);

      stopwatch.stop();
      print('[EncryptionService] Decrypted in ${stopwatch.elapsedMilliseconds}ms');

      return decrypted;
    } catch (e) {
      print('[ERROR] Decryption failed: $e');
      print('[SECURITY] Possible tampering detected or corrupted data');
      throw EncryptionException('Failed to decrypt journal entry. Data may be corrupted.');
    }
  }

  /// Verify encryption/decryption works (health check)
  Future<bool> verifyEncryption() async {
    try {
      const testPlaintext = 'LifeOS encryption test 🔒';

      final encrypted = await encryptJournal(testPlaintext);
      final decrypted = await decryptJournal(encrypted.encryptedContent, encrypted.iv);

      return decrypted == testPlaintext;
    } catch (e) {
      print('[ERROR] Encryption verification failed: $e');
      return false;
    }
  }

  /// Delete encryption key (use with EXTREME caution!)
  ///
  /// WARNING: This will make ALL existing journal entries permanently unreadable!
  /// Only call this during account deletion or if user explicitly requests it.
  Future<void> deleteEncryptionKey() async {
    await _secureStorage.delete(key: _keyStorageKey);
    await _secureStorage.delete(key: _saltStorageKey);
    print('[EncryptionService] Encryption key deleted (all journal entries now unreadable)');
  }
}

/// Encrypted data container
class EncryptedData {
  final String encryptedContent;  // Base64-encoded ciphertext + auth tag
  final String iv;                // Base64-encoded initialization vector

  EncryptedData({
    required this.encryptedContent,
    required this.iv,
  });
}

/// Custom exception for encryption errors
class EncryptionException implements Exception {
  final String message;
  EncryptionException(this.message);

  @override
  String toString() => 'EncryptionException: $message';
}
```

### 2.3 Why Random IV Per Entry?

**IV (Initialization Vector) Requirements:**
- MUST be random and unique for each encryption
- MUST NEVER be reused with the same key

**Security Risk if IV is reused:**
```
Entry 1: Encrypt("I feel happy today", key, iv=0x1234) → Ciphertext A
Entry 2: Encrypt("I feel happy today", key, iv=0x1234) → Ciphertext A (IDENTICAL!)

Attacker can see that Entry 1 and Entry 2 have the same content!
```

**Solution:** Generate random IV for EACH entry using `IV.fromSecureRandom(16)`.

---

## 3. Key Management & Secure Storage

### 3.1 Flutter Secure Storage

**Package:** `flutter_secure_storage: ^9.0.0`

**Platform-Specific Security:**
- **iOS:** Stores key in **Keychain** (hardware-backed encryption on devices with Secure Enclave)
- **Android:** Stores key in **KeyStore** (hardware-backed encryption on devices with TEE)
- **Windows/Linux:** Uses OS-specific secure storage

**Initialization:**

```dart
// File: lib/core/services/secure_storage_service.dart

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static final FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,  // Use EncryptedSharedPreferences
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,  // Available after first device unlock
    ),
  );

  static FlutterSecureStorage get instance => _storage;
}
```

**Provider Setup:**

```dart
// File: lib/features/mind/providers/encryption_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

final encryptionServiceProvider = Provider<EncryptionService>((ref) {
  return EncryptionService(SecureStorageService.instance);
});
```

### 3.2 Key Persistence & Recovery

**Scenario 1: App Reinstall (Same Device)**
- ✅ iOS: Keychain persists (key survives reinstall)
- ✅ Android: KeyStore persists (key survives reinstall)
- Result: User can decrypt old journal entries after reinstall

**Scenario 2: New Device**
- ❌ Key is device-specific (NOT synced to cloud)
- Result: User CANNOT decrypt journal entries from old device
- Mitigation: GDPR export creates decrypted backup (user responsibility)

**Scenario 3: OS Restore from Backup**
- ✅ iOS: Keychain backed up to iCloud Keychain (if enabled)
- ⚠️ Android: KeyStore NOT backed up (user loses key)
- Mitigation: Warn user during onboarding

**Future Enhancement: Password-Derived Key**

```dart
/// Derive encryption key from user password (enables multi-device access)
Future<encrypt.Key> deriveKeyFromPassword(String password, String salt) async {
  final saltBytes = base64.decode(salt);

  // PBKDF2 with 100,000 iterations (OWASP recommendation)
  final derivedKey = await Pbkdf2(
    macAlgorithm: Hmac.sha256(),
    iterations: 100000,
    bits: 256,
  ).deriveKey(
    secretKey: SecretKey(utf8.encode(password)),
    nonce: saltBytes,
  );

  final keyBytes = await derivedKey.extractBytes();
  return encrypt.Key(Uint8List.fromList(keyBytes));
}
```

---

## 4. Complete Service Implementation

### 4.1 JournalService

**File:** `lib/features/mind/services/journal_service.dart`

```dart
import 'package:uuid/uuid.dart';

class JournalService {
  final EncryptionService _encryption;
  final JournalRepository _repository;
  final AIService _aiService;
  final SettingsRepository _settingsRepository;
  final SyncQueue _syncQueue;
  final String _currentUserId;

  JournalService({
    required EncryptionService encryption,
    required JournalRepository repository,
    required AIService aiService,
    required SettingsRepository settingsRepository,
    required SyncQueue syncQueue,
    required String currentUserId,
  })  : _encryption = encryption,
        _repository = repository,
        _aiService = aiService,
        _settingsRepository = settingsRepository,
        _syncQueue = syncQueue,
        _currentUserId = currentUserId;

  /// Create journal entry (E2E encrypted)
  ///
  /// Flow:
  /// 1. Encrypt content client-side
  /// 2. (Optional) AI sentiment analysis if enabled
  /// 3. Save encrypted blob locally
  /// 4. Queue for Supabase sync
  Future<String> createJournalEntry(String content) async {
    final stopwatch = Stopwatch()..start();

    try {
      // 1. Encrypt content client-side (<50ms target)
      final encrypted = await _encryption.encryptJournal(content);

      // 2. Optional: AI sentiment analysis (opt-in only)
      String? sentiment;
      final aiAnalysisEnabled = await _settingsRepository.isAIJournalAnalysisEnabled();

      if (aiAnalysisEnabled) {
        print('[JournalService] AI analysis enabled, analyzing sentiment...');
        sentiment = await _aiService.analyzeSentiment(content);  // Send plaintext to AI
        print('[JournalService] Sentiment: $sentiment');
      } else {
        print('[JournalService] AI analysis disabled (privacy mode)');
      }

      // 3. Create journal entry
      final entry = JournalEntry(
        id: Uuid().v4(),
        userId: _currentUserId,
        encryptedContent: encrypted.encryptedContent,
        encryptionIv: encrypted.iv,
        sentiment: sentiment,
        createdAt: DateTime.now().toUtc(),
      );

      // 4. Save to local DB (instant feedback)
      await _repository.saveJournalEntry(entry);

      // 5. Queue for Supabase sync (background)
      await _syncQueue.add(SyncItem(
        type: SyncItemType.journalEntry,
        data: entry,
        priority: SyncPriority.medium,
      ));

      stopwatch.stop();
      print('[JournalService] Journal entry created in ${stopwatch.elapsedMilliseconds}ms');

      return entry.id;
    } catch (e) {
      print('[ERROR] Failed to create journal entry: $e');
      rethrow;
    }
  }

  /// Get journal entries (decrypt on read)
  ///
  /// Performance considerations:
  /// - Decrypt entries lazily (only decrypt when user opens entry)
  /// - Cache decrypted content in memory (invalidate on app restart)
  Future<List<DecryptedJournalEntry>> getJournalEntries({
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    final stopwatch = Stopwatch()..start();

    try {
      // Fetch encrypted entries from local DB
      final entries = await _repository.getJournalEntries(
        userId: _currentUserId,
        startDate: startDate,
        endDate: endDate,
        limit: limit,
      );

      // Decrypt all entries in parallel
      final decrypted = await Future.wait(entries.map((entry) async {
        try {
          final content = await _encryption.decryptJournal(
            entry.encryptedContent,
            entry.encryptionIv,
          );

          return DecryptedJournalEntry(
            id: entry.id,
            content: content,
            sentiment: entry.sentiment,
            createdAt: entry.createdAt,
          );
        } catch (e) {
          print('[ERROR] Failed to decrypt entry ${entry.id}: $e');

          // Return corrupted entry indicator
          return DecryptedJournalEntry(
            id: entry.id,
            content: '[ERROR: Unable to decrypt this entry]',
            sentiment: null,
            createdAt: entry.createdAt,
          );
        }
      }));

      stopwatch.stop();
      print('[JournalService] Decrypted ${decrypted.length} entries in ${stopwatch.elapsedMilliseconds}ms');

      return decrypted;
    } catch (e) {
      print('[ERROR] Failed to get journal entries: $e');
      rethrow;
    }
  }

  /// Delete journal entry
  Future<void> deleteJournalEntry(String entryId) async {
    await _repository.deleteJournalEntry(entryId);

    // Queue deletion sync
    await _syncQueue.add(SyncItem(
      type: SyncItemType.journalEntryDeletion,
      data: {'id': entryId},
      priority: SyncPriority.high,
    ));
  }

  /// Export journal (decrypted plaintext for GDPR)
  Future<File> exportJournal() async {
    final entries = await getJournalEntries();

    // Create plaintext export (JSON format)
    final exportData = entries.map((entry) => {
      'date': entry.createdAt.toIso8601String(),
      'content': entry.content,
      'sentiment': entry.sentiment,
    }).toList();

    final jsonString = jsonEncode(exportData);

    // Save to temporary file
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/journal_export_${DateTime.now().millisecondsSinceEpoch}.json');
    await file.writeAsString(jsonString);

    print('[JournalService] Exported ${entries.length} journal entries to ${file.path}');

    return file;
  }
}

/// Decrypted journal entry (in-memory only)
class DecryptedJournalEntry {
  final String id;
  final String content;      // Plaintext content (decrypted)
  final String? sentiment;   // 'positive' | 'neutral' | 'negative'
  final DateTime createdAt;

  DecryptedJournalEntry({
    required this.id,
    required this.content,
    required this.sentiment,
    required this.createdAt,
  });
}
```

---

## 5. AI Sentiment Analysis (Opt-In)

### 5.1 Privacy-First Design

**Default:** AI analysis is **OFF** (maximum privacy)

**If user enables AI analysis:**
1. Plaintext content sent to AI API
2. AI returns sentiment: 'positive' | 'neutral' | 'negative'
3. ONLY sentiment stored in database (NOT full content)

**Settings UI:**

```dart
// File: lib/features/settings/screens/privacy_settings_screen.dart

SwitchListTile(
  title: Text('AI analysis of journal entries'),
  subtitle: Text('Sentiment analysis (opt-in only)'),
  value: isAIJournalAnalysisEnabled,
  onChanged: (value) async {
    if (value) {
      // Show warning dialog
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Enable AI Analysis?'),
          content: Text(
            'Journal entries will be sent to AI for sentiment analysis. '
            'Your journal will no longer be fully end-to-end encrypted.\n\n'
            'You can disable this anytime.'
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text('Enable'),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        await ref.read(settingsRepositoryProvider).updateAIJournalAnalysis(true);
      }
    } else {
      // Disable without warning
      await ref.read(settingsRepositoryProvider).updateAIJournalAnalysis(false);
    }
  },
)
```

### 5.2 Sentiment Analysis Implementation

**Supabase Edge Function:** `analyze-journal-sentiment`

```typescript
// File: supabase/functions/analyze-journal-sentiment/index.ts

import { serve } from 'https://deno.land/std@0.177.0/http/server.ts'

serve(async (req) => {
  const { userId, content } = await req.json()

  // Check if user has AI analysis enabled
  const { data: settings } = await supabase
    .from('user_settings')
    .select('ai_journal_analysis_enabled')
    .eq('user_id', userId)
    .single()

  if (!settings?.ai_journal_analysis_enabled) {
    return new Response(JSON.stringify({ error: 'AI analysis not enabled' }), { status: 403 })
  }

  // Call AI API (Claude Haiku for cost efficiency)
  const prompt = `Analyze the sentiment of this journal entry. Respond with ONLY one word: positive, neutral, or negative.\n\nJournal entry:\n${content}`

  const response = await fetch('https://api.anthropic.com/v1/messages', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'x-api-key': Deno.env.get('ANTHROPIC_API_KEY')!,
      'anthropic-version': '2023-06-01',
    },
    body: JSON.stringify({
      model: 'claude-3-haiku-20240307',  // Cheapest model ($0.25/MTok input)
      max_tokens: 10,
      messages: [{
        role: 'user',
        content: prompt,
      }],
    }),
  })

  const aiResponse = await response.json()
  const sentiment = aiResponse.content[0].text.trim().toLowerCase()

  // Validate sentiment
  if (!['positive', 'neutral', 'negative'].includes(sentiment)) {
    return new Response(JSON.stringify({ sentiment: 'neutral' }), { status: 200 })
  }

  return new Response(JSON.stringify({ sentiment }), { status: 200 })
})
```

**Cost Analysis:**
- Average journal entry: 200 words (~300 tokens)
- Claude Haiku: $0.25/MTok input, $1.25/MTok output
- Cost per analysis: ~$0.0001 (0.01 cent)
- 10,000 users × 5 entries/month = 50,000 entries/month = **$5/month**

---

## 6. Security Best Practices & Threat Model

### 6.1 Threat Model

**What E2E Encryption PROTECTS Against:**
✅ Supabase database breach (attacker gets encrypted blobs, cannot read content)
✅ Malicious Supabase admin (cannot read journal entries)
✅ Man-in-the-middle attack (encrypted data in transit)
✅ Backup compromise (cloud backups contain encrypted data)

**What E2E Encryption DOES NOT Protect Against:**
❌ Device theft (if device is unlocked, attacker can access app)
❌ Malware on device (can capture plaintext before encryption)
❌ User enabling AI analysis (plaintext sent to AI API)
❌ Forensic analysis of device RAM (decrypted content in memory)

### 6.2 Security Best Practices

**DO:**
- ✅ Use AES-256-GCM (authenticated encryption)
- ✅ Generate random IV per entry
- ✅ Store key in flutter_secure_storage
- ✅ Verify encryption/decryption works on app start
- ✅ Clear decrypted content from memory when not needed
- ✅ Warn user about AI analysis privacy tradeoff

**DON'T:**
- ❌ NEVER send plaintext to server (unless AI analysis enabled)
- ❌ NEVER reuse IV
- ❌ NEVER log plaintext content
- ❌ NEVER store decrypted content in shared preferences
- ❌ NEVER sync encryption key to cloud

### 6.3 Data Flow Diagram

```
┌──────────────────────────────────────────────────────────────┐
│                     Data Flow (E2E Encrypted)                 │
├──────────────────────────────────────────────────────────────┤
│                                                                │
│  USER WRITES JOURNAL ENTRY                                    │
│         ↓                                                      │
│  [Client] Encrypt with AES-256-GCM                            │
│         ↓                                                      │
│  [Drift] Save encrypted blob locally                          │
│         ↓                                                      │
│  [Supabase] Sync encrypted blob (CANNOT read content)        │
│         ↓                                                      │
│  [Client] Fetch encrypted blob                               │
│         ↓                                                      │
│  [Client] Decrypt with local key                             │
│         ↓                                                      │
│  USER READS DECRYPTED JOURNAL ENTRY                          │
│                                                                │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │ OPTIONAL: AI Sentiment Analysis (Opt-In)                │ │
│  │                                                          │ │
│  │  [Client] Decrypt entry                                 │ │
│  │      ↓                                                   │ │
│  │  [Edge Function] Send plaintext to AI API               │ │
│  │      ↓                                                   │ │
│  │  [AI API] Return sentiment (positive/neutral/negative)  │ │
│  │      ↓                                                   │ │
│  │  [Supabase] Save sentiment ONLY (not content)           │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                                │
└──────────────────────────────────────────────────────────────┘
```

---

## 7. Performance Optimization

### 7.1 Performance Targets

| Operation | Target | P95 Target |
|-----------|--------|------------|
| Encrypt entry | <50ms | <100ms |
| Decrypt entry | <50ms | <100ms |
| Save entry (local) | <200ms | <500ms |
| Load 30 entries | <1s | <2s |

### 7.2 Optimization Strategies

**1. Lazy Decryption**

Don't decrypt all entries upfront. Decrypt only when user opens entry.

```dart
// BAD: Decrypt all entries on list load
Future<List<DecryptedJournalEntry>> getJournalEntries() async {
  final entries = await _repository.getJournalEntries();
  return Future.wait(entries.map((e) => _decrypt(e)));  // Decrypts ALL entries!
}

// GOOD: Return encrypted entries, decrypt on demand
Future<List<JournalEntry>> getJournalEntries() async {
  return _repository.getJournalEntries();  // Returns encrypted entries
}

Future<String> decryptEntry(JournalEntry entry) async {
  return _encryption.decryptJournal(entry.encryptedContent, entry.encryptionIv);
}
```

**2. In-Memory Cache**

Cache decrypted entries for current session (invalidate on app restart).

```dart
class JournalService {
  final Map<String, String> _decryptionCache = {};

  Future<String> getDecryptedContent(JournalEntry entry) async {
    // Check cache first
    if (_decryptionCache.containsKey(entry.id)) {
      return _decryptionCache[entry.id]!;
    }

    // Decrypt and cache
    final decrypted = await _encryption.decryptJournal(
      entry.encryptedContent,
      entry.encryptionIv,
    );

    _decryptionCache[entry.id] = decrypted;
    return decrypted;
  }

  void clearCache() {
    _decryptionCache.clear();
  }
}
```

**3. Pagination**

Load entries in batches (30 entries per page).

```dart
Future<List<JournalEntry>> getJournalEntries({
  int page = 0,
  int pageSize = 30,
}) async {
  return _repository.getJournalEntries(
    userId: _currentUserId,
    offset: page * pageSize,
    limit: pageSize,
  );
}
```

---

## 8. Export & GDPR Compliance

### 8.1 GDPR Requirements

**Right to Data Portability (Article 20):**
- User can request export of ALL journal entries
- Export format: JSON (machine-readable)
- Export includes: date, content (decrypted), sentiment

**Implementation:**

```dart
Future<File> exportJournal() async {
  final entries = await getJournalEntries();

  final exportData = {
    'export_date': DateTime.now().toIso8601String(),
    'user_id': _currentUserId,
    'total_entries': entries.length,
    'entries': entries.map((entry) => {
      'id': entry.id,
      'date': entry.createdAt.toIso8601String(),
      'content': entry.content,  // Decrypted plaintext
      'sentiment': entry.sentiment,
    }).toList(),
  };

  final jsonString = JsonEncoder.withIndent('  ').convert(exportData);

  final tempDir = await getTemporaryDirectory();
  final file = File('${tempDir.path}/journal_export_${DateTime.now().millisecondsSinceEpoch}.json');
  await file.writeAsString(jsonString);

  return file;
}
```

**UI Flow:**

```dart
// Settings > Data Privacy > Export Journal
ElevatedButton(
  onPressed: () async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Export Journal?'),
        content: Text('Your journal will be exported as a JSON file with decrypted content.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);

              // Show loading
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => Center(child: CircularProgressIndicator()),
              );

              // Export journal
              final file = await ref.read(journalServiceProvider).exportJournal();

              Navigator.pop(context);  // Close loading

              // Share file
              await Share.shareXFiles([XFile(file.path)], text: 'Journal Export');
            },
            child: Text('Export'),
          ),
        ],
      ),
    );
  },
  child: Text('Export Journal'),
)
```

---

## 9. Testing Strategy

### 9.1 Unit Tests

**File:** `test/features/mind/services/encryption_service_test.dart`

```dart
void main() {
  late EncryptionService encryptionService;
  late MockFlutterSecureStorage mockSecureStorage;

  setUp(() {
    mockSecureStorage = MockFlutterSecureStorage();
    encryptionService = EncryptionService(mockSecureStorage);
  });

  group('EncryptionService', () {
    test('encrypts and decrypts successfully', () async {
      const plaintext = 'This is my private journal entry';

      final encrypted = await encryptionService.encryptJournal(plaintext);
      final decrypted = await encryptionService.decryptJournal(
        encrypted.encryptedContent,
        encrypted.iv,
      );

      expect(decrypted, equals(plaintext));
    });

    test('generates unique IV for each encryption', () async {
      const plaintext = 'Same content';

      final encrypted1 = await encryptionService.encryptJournal(plaintext);
      final encrypted2 = await encryptionService.encryptJournal(plaintext);

      // Different IVs
      expect(encrypted1.iv, isNot(equals(encrypted2.iv)));

      // Different ciphertexts (because of different IVs)
      expect(encrypted1.encryptedContent, isNot(equals(encrypted2.encryptedContent)));
    });

    test('throws exception on corrupted ciphertext', () async {
      const plaintext = 'Test content';

      final encrypted = await encryptionService.encryptJournal(plaintext);

      // Corrupt ciphertext
      final corruptedCiphertext = encrypted.encryptedContent.substring(0, encrypted.encryptedContent.length - 5) + 'XXXXX';

      expect(
        () => encryptionService.decryptJournal(corruptedCiphertext, encrypted.iv),
        throwsA(isA<EncryptionException>()),
      );
    });

    test('encryption performance <50ms', () async {
      const plaintext = 'A' * 5000;  // 5000 characters

      final stopwatch = Stopwatch()..start();
      await encryptionService.encryptJournal(plaintext);
      stopwatch.stop();

      expect(stopwatch.elapsedMilliseconds, lessThan(50));
    });

    test('decryption performance <50ms', () async {
      const plaintext = 'A' * 5000;
      final encrypted = await encryptionService.encryptJournal(plaintext);

      final stopwatch = Stopwatch()..start();
      await encryptionService.decryptJournal(encrypted.encryptedContent, encrypted.iv);
      stopwatch.stop();

      expect(stopwatch.elapsedMilliseconds, lessThan(50));
    });
  });
}
```

### 9.2 Integration Tests

**File:** `integration_test/journal_e2e_test.dart`

```dart
void main() {
  testWidgets('Create encrypted journal entry end-to-end', (tester) async {
    await tester.pumpWidget(MyApp());

    // Navigate to Journal
    await tester.tap(find.text('Mind'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Journal'));
    await tester.pumpAndSettle();

    // Create new entry
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    // Write content
    await tester.enterText(find.byType(TextField), 'This is my private thought');

    // Save entry
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    // Verify entry appears in list
    expect(find.text('This is my private thought'), findsOneWidget);

    // Verify entry is encrypted in database
    final db = await openDatabase('lifeos.db');
    final result = await db.query('journal_entries', limit: 1, orderBy: 'created_at DESC');

    expect(result.first['encrypted_content'], isNotNull);
    expect(result.first['encrypted_content'], isNot(contains('This is my private thought')));

    await db.close();
  });
}
```

### 9.3 Security Tests

**Test Cases:**
1. ✅ Encrypted content does NOT contain plaintext substrings
2. ✅ Decryption fails on tampered ciphertext
3. ✅ Different IVs for same content produce different ciphertexts
4. ✅ Key persists across app restarts
5. ✅ AI analysis only works when enabled in settings

---

## 10. Troubleshooting Guide

### 10.1 Common Issues

**Issue 1: "Failed to decrypt journal entry"**

**Symptoms:**
- User sees "[ERROR: Unable to decrypt this entry]"
- Logs show: `Decryption failed: Invalid or corrupted AAD block`

**Root Causes:**
1. Encryption key was deleted (e.g., user cleared app data)
2. Database corruption
3. App restored from backup on different device

**Solutions:**
1. Check if encryption key exists:
   ```dart
   final keyExists = await _secureStorage.containsKey(key: 'journal_encryption_key_v1');
   if (!keyExists) {
     // Key was deleted, journal entries are unrecoverable
     showDialog('Your journal encryption key was lost. Entries cannot be recovered.');
   }
   ```
2. Verify encryption works:
   ```dart
   final isHealthy = await _encryptionService.verifyEncryption();
   if (!isHealthy) {
     // Encryption service broken
   }
   ```
3. Advise user to export journal regularly (GDPR export creates decrypted backup)

---

**Issue 2: "Encryption taking >100ms"**

**Symptoms:**
- UI lag when creating journal entries
- Logs show: `Encrypted in 150ms`

**Root Causes:**
1. Very long journal entries (>10,000 characters)
2. Slow device (low-end Android)

**Solutions:**
1. Add character limit (5,000 characters recommended)
2. Show loading indicator for long entries
3. Optimize encryption (use Isolate for very long entries):
   ```dart
   Future<EncryptedData> encryptJournal(String plaintext) async {
     if (plaintext.length > 5000) {
       // Run encryption in isolate (avoid blocking UI)
       return compute(_encryptInIsolate, plaintext);
     }

     return _encryptSync(plaintext);
   }
   ```

---

**Issue 3: "AI sentiment analysis not working"**

**Symptoms:**
- Sentiment remains `null` even with AI analysis enabled
- Logs show: `AI analysis enabled, analyzing sentiment...` but no sentiment returned

**Root Causes:**
1. User setting not persisted correctly
2. Edge Function error (API key invalid, rate limit)

**Solutions:**
1. Check setting:
   ```dart
   final enabled = await _settingsRepository.isAIJournalAnalysisEnabled();
   print('AI analysis enabled: $enabled');
   ```
2. Check Edge Function logs (Supabase Dashboard > Edge Functions > Logs)
3. Fallback to 'neutral' if AI call fails

---

**Issue 4: "Journal entries lost after app reinstall"**

**Symptoms:**
- User reinstalls app, all journal entries gone

**Root Causes:**
1. User cleared app data (deletes local Drift database)
2. Sync failed (entries never uploaded to Supabase)

**Solutions:**
1. Ensure sync queue is working:
   ```dart
   await _syncQueue.processQueue();  // Force sync before uninstall
   ```
2. On app start, fetch journal entries from Supabase:
   ```dart
   final cloudEntries = await _supabase.from('journal_entries')
     .select()
     .eq('user_id', userId);

   for (final entry in cloudEntries) {
     await _repository.saveJournalEntry(entry);  // Restore to local DB
   }
   ```

---

## Summary

**Story 4.5 Implementation Checklist:**

**Security:**
- ✅ AES-256-GCM client-side encryption
- ✅ Random IV per entry
- ✅ Key stored in flutter_secure_storage
- ✅ AI analysis opt-in only (default OFF)
- ✅ No plaintext sent to server (except AI analysis)

**Performance:**
- ✅ Encrypt/decrypt <50ms
- ✅ Lazy decryption (decrypt on demand)
- ✅ In-memory cache for session
- ✅ Pagination (30 entries per page)

**GDPR:**
- ✅ Export journal (JSON with decrypted content)
- ✅ Delete journal entries
- ✅ Privacy controls in Settings

**Testing:**
- ✅ Unit tests (encryption, decryption, performance)
- ✅ Integration tests (E2E journal creation)
- ✅ Security tests (tampering detection, IV uniqueness)

**Key Files:**
- `lib/features/mind/services/encryption_service.dart` (197 lines)
- `lib/features/mind/services/journal_service.dart` (142 lines)
- `supabase/functions/analyze-journal-sentiment/index.ts` (45 lines)
- `test/features/mind/services/encryption_service_test.dart` (87 lines)

**Estimated Implementation Time:** 2-3 days (1 developer)

---

**Next Steps:**
1. Implement EncryptionService
2. Implement JournalService
3. Create Supabase Edge Function for sentiment analysis
4. Build Journal UI (editor + history)
5. Add privacy settings toggle
6. Write tests
7. Security review
8. Deploy to TestFlight/Internal Testing
