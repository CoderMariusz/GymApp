# Security Architecture

<!-- AI-INDEX: security, e2ee, encryption, gdpr, privacy, authentication, rls, aes-256 -->

**Wersja:** 2.0
**Decision:** D5 - Client-Side AES-256-GCM for E2EE

---

## Spis Treści

1. [Security Overview](#1-security-overview)
2. [Authentication](#2-authentication)
3. [End-to-End Encryption (E2EE)](#3-end-to-end-encryption-e2ee)
4. [Row Level Security (RLS)](#4-row-level-security-rls)
5. [GDPR Compliance](#5-gdpr-compliance)
6. [Threat Model](#6-threat-model)
7. [Implementation](#7-implementation)

---

## 1. Security Overview

### Security Principles

1. **Zero Trust:** Assume breach, encrypt sensitive data
2. **Client-Side E2EE:** Server never sees plaintext journals
3. **RLS Everywhere:** Row-level security for data isolation
4. **Minimal Exposure:** Only expose what's necessary

### Data Classification

| Classification | Examples | Protection |
|----------------|----------|------------|
| **Highly Sensitive** | Journals, mental health | E2EE (AES-256-GCM) |
| **Sensitive** | Mood, stress, workouts | RLS, TLS |
| **General** | Exercise library, templates | TLS |

### Encryption at Rest and Transit

| Location | Encryption |
|----------|------------|
| **In Transit** | HTTPS/TLS 1.3 |
| **At Rest (Supabase)** | AES-256 (managed) |
| **At Rest (Device)** | Drift SQLite + Secure Storage |
| **Sensitive Fields** | Client-side E2EE |

---

## 2. Authentication

### Supabase Auth

| Provider | Platform | Status |
|----------|----------|--------|
| Email + Password | All | ✅ |
| Google OAuth 2.0 | All | ✅ |
| Apple Sign-In | iOS | ✅ |

### Password Requirements

```
Minimum 8 characters
1 uppercase letter
1 number
1 special character (!@#$%^&*)
```

### Session Management

| Setting | Value |
|---------|-------|
| Session Duration | 30 days inactivity |
| Token Storage | flutter_secure_storage |
| Auto-Refresh | Before expiration |
| Logout | Clears all tokens |

### MFA (Phase 1)

- Email-based 2FA
- Optional for users
- Required for admin

### Implementation

```dart
// lib/core/auth/auth_service.dart

class AuthService {
  final SupabaseClient _supabase;
  final FlutterSecureStorage _secureStorage;

  Future<AuthResult> signInWithEmail(String email, String password) async {
    final response = await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (response.session != null) {
      await _secureStorage.write(
        key: 'session_token',
        value: response.session!.accessToken,
      );
      return AuthResult.success(response.user!);
    }

    return AuthResult.failure('Invalid credentials');
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
    await _secureStorage.deleteAll();
  }
}
```

---

## 3. End-to-End Encryption (E2EE)

### What's Encrypted

| Data Type | Encrypted | Reason |
|-----------|-----------|--------|
| **Journal Entries** | ✅ E2EE | Highly personal |
| **Mental Health Notes** | ✅ E2EE | Medical sensitivity |
| **Private Goals (user-marked)** | ✅ E2EE | User preference |
| **Mood Score (1-10)** | ❌ | Needed for CMI patterns |
| **Stress Level (1-10)** | ❌ | Needed for CMI patterns |
| **Workout Data** | ❌ | Needed for progress tracking |

### Encryption Flow

```
User writes journal entry
    ↓
AES-256-GCM encryption (client-side)
    Key: Derived from user password + salt
    ↓
Encrypted blob → Supabase Storage
    ↓
Key stored in flutter_secure_storage
    (iOS Keychain / Android KeyStore)
```

### Key Derivation

```dart
// lib/core/encryption/encryption_service.dart

class EncryptionService {
  static const int _keyLength = 32; // 256 bits
  static const int _saltLength = 16;
  static const int _nonceLength = 12;
  static const int _iterations = 100000;

  Future<SecretKey> deriveKey(String password, Uint8List salt) async {
    final pbkdf2 = Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: _iterations,
      bits: _keyLength * 8,
    );

    return await pbkdf2.deriveKey(
      secretKey: SecretKey(utf8.encode(password)),
      nonce: salt,
    );
  }

  Future<EncryptedData> encrypt(String plaintext, SecretKey key) async {
    final algorithm = AesGcm.with256bits();
    final nonce = algorithm.newNonce();

    final secretBox = await algorithm.encrypt(
      utf8.encode(plaintext),
      secretKey: key,
      nonce: nonce,
    );

    return EncryptedData(
      ciphertext: base64.encode(secretBox.cipherText),
      nonce: base64.encode(nonce),
      mac: base64.encode(secretBox.mac.bytes),
    );
  }

  Future<String> decrypt(EncryptedData data, SecretKey key) async {
    final algorithm = AesGcm.with256bits();

    final secretBox = SecretBox(
      base64.decode(data.ciphertext),
      nonce: base64.decode(data.nonce),
      mac: Mac(base64.decode(data.mac)),
    );

    final plaintext = await algorithm.decrypt(
      secretBox,
      secretKey: key,
    );

    return utf8.decode(plaintext);
  }
}
```

### Key Storage

```dart
// iOS: Keychain
// Android: KeyStore (hardware-backed on supported devices)

class KeyStorageService {
  final FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  Future<void> storeEncryptionKey(String userId, Uint8List key) async {
    await _storage.write(
      key: 'enc_key_$userId',
      value: base64.encode(key),
    );
  }

  Future<Uint8List?> getEncryptionKey(String userId) async {
    final encoded = await _storage.read(key: 'enc_key_$userId');
    return encoded != null ? base64.decode(encoded) : null;
  }
}
```

---

## 4. Row Level Security (RLS)

### RLS Policies

**All user-owned tables have RLS enabled:**

```sql
-- Enable RLS
ALTER TABLE journal_entries ENABLE ROW LEVEL SECURITY;

-- Users can only access their own data
CREATE POLICY "Users own their journal entries"
  ON journal_entries FOR ALL
  USING (auth.uid() = user_id);

-- Users can insert their own data
CREATE POLICY "Users can insert their own entries"
  ON journal_entries FOR INSERT
  WITH CHECK (auth.uid() = user_id);
```

### Subscription-Based Access

```sql
-- Premium features require subscription
CREATE POLICY "Premium meditation access"
  ON meditation_sessions FOR SELECT
  USING (
    auth.uid() = user_id AND
    EXISTS (
      SELECT 1 FROM subscriptions
      WHERE user_id = auth.uid()
      AND tier IN ('single', 'pack', 'plus')
      AND (expires_at IS NULL OR expires_at > NOW())
    )
  );
```

### Admin Access (Service Role)

```sql
-- Only service role can bypass RLS
-- Used for Edge Functions, migrations
```

---

## 5. GDPR Compliance

### User Rights

| Right | Implementation |
|-------|----------------|
| **Right to Access** | Export all data (JSON + CSV) |
| **Right to Rectification** | Edit profile, goals, entries |
| **Right to Erasure** | Delete account + all data |
| **Right to Portability** | Export in machine-readable format |

### Data Export Endpoint

```typescript
// supabase/functions/gdpr-export/index.ts

serve(async (req) => {
  const { data: { user } } = await supabase.auth.getUser()

  const exportData = {
    profile: await getProfile(user.id),
    workouts: await getWorkouts(user.id),
    goals: await getGoals(user.id),
    check_ins: await getCheckIns(user.id),
    mood_logs: await getMoodLogs(user.id),
    // Note: Journal entries returned as encrypted blobs
    journal_entries: await getJournalEntries(user.id),
  }

  // Generate ZIP file
  const zip = await createZip(exportData)

  return new Response(zip, {
    headers: {
      'Content-Type': 'application/zip',
      'Content-Disposition': 'attachment; filename=lifeos_export.zip'
    }
  })
})
```

### Data Deletion

```typescript
// supabase/functions/gdpr-delete/index.ts

serve(async (req) => {
  const { data: { user } } = await supabase.auth.getUser()

  // Soft delete with 30-day retention
  await supabase
    .from('users_pending_deletion')
    .insert({
      user_id: user.id,
      requested_at: new Date(),
      delete_at: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000)
    })

  // Sign out user
  await supabase.auth.admin.deleteUser(user.id)

  return new Response(JSON.stringify({
    message: 'Deletion scheduled',
    delete_at: '30 days from now'
  }))
})

// Cron job: Actually delete after 30 days
```

### Privacy Policy

- Clear, visible in app
- GDPR-compliant language
- Explains what data collected
- Explains how data used
- Explains user rights
- No selling to third parties

### Data Retention

| Data Type | Retention |
|-----------|-----------|
| Active user data | While account active |
| Deleted user data | 30 days (backup) |
| Analytics | Anonymous, 2 years |
| Logs | 90 days |

---

## 6. Threat Model

### Covered Threats

| Threat | Mitigation | Status |
|--------|------------|--------|
| **Supabase breach** | E2EE - encrypted data unreadable | ✅ |
| **MITM attack** | HTTPS/TLS 1.3 + cert pinning | ✅ |
| **Device theft** | Biometric unlock + secure storage | ✅ |
| **SQL injection** | Supabase RLS, parameterized queries | ✅ |
| **XSS** | Input sanitization | ✅ |
| **API abuse** | Rate limiting (100 req/min) | ✅ |
| **Credential stuffing** | Rate limiting + lockout | ✅ |

### Attack Surface

```
┌─────────────────────────────────────────────────────────────┐
│                      Attack Surface                          │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  [Flutter App] ──TLS──> [Supabase API] ──> [PostgreSQL]    │
│       │                      │                  │           │
│       │                      │                  │           │
│   Secure Storage        Rate Limiting          RLS          │
│   (Keys, Tokens)        (100 req/min)      (User Isolation) │
│       │                      │                  │           │
│       └──────────────────────┼──────────────────┘           │
│                              │                              │
│                         [Edge Functions]                    │
│                              │                              │
│                       AI API Keys                           │
│                    (Never exposed to client)                │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Security Audits

- **Frequency:** Quarterly (P1)
- **Scope:** Penetration testing, code review
- **Tools:** OWASP ZAP, Burp Suite, SonarQube

---

## 7. Implementation

### Certificate Pinning (P1)

```dart
// lib/core/api/http_client.dart

class SecureHttpClient {
  static final _expectedCert = '''
-----BEGIN CERTIFICATE-----
MIIDrzCCA... (Supabase SSL certificate)
-----END CERTIFICATE-----
''';

  static HttpClient createClient() {
    final client = HttpClient();
    client.badCertificateCallback = (cert, host, port) {
      return cert.pem == _expectedCert;
    };
    return client;
  }
}
```

### Input Sanitization

```dart
// lib/core/utils/sanitizer.dart

class Sanitizer {
  static String sanitizeText(String input) {
    // Remove potential XSS
    return input
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#x27;');
  }

  static String sanitizeForDatabase(String input) {
    // Supabase handles this, but extra safety
    return input.replaceAll(RegExp(r'[;\'"\\]'), '');
  }
}
```

### Security Headers

```typescript
// Supabase Edge Functions response headers

const securityHeaders = {
  'X-Content-Type-Options': 'nosniff',
  'X-Frame-Options': 'DENY',
  'X-XSS-Protection': '1; mode=block',
  'Strict-Transport-Security': 'max-age=31536000; includeSubDomains',
  'Content-Security-Policy': "default-src 'self'",
};
```

---

## Powiązane Dokumenty

- [ARCH-overview.md](./ARCH-overview.md) - Architecture overview
- [ARCH-database-schema.md](./ARCH-database-schema.md) - RLS details
- [PRD-nfr.md](../product/PRD-nfr.md) - Security NFRs

---

*E2EE for Sensitive Data | RLS Everywhere | GDPR Compliant*
