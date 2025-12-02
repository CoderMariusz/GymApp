# Non-Functional Requirements (NFR)

<!-- AI-INDEX: nfr, non-functional, performance, security, scalability, gdpr, accessibility, reliability, compliance -->

**Wersja:** 2.0
**Status:** ✅ 37 NFRs zdefiniowanych

---

## Spis Treści

1. [Performance](#1-performance)
2. [Security](#2-security)
3. [Scalability](#3-scalability)
4. [Integration](#4-integration)
5. [Accessibility](#5-accessibility)
6. [Reliability](#6-reliability)
7. [Compliance](#7-compliance)
8. [Monitoring](#8-monitoring)
9. [NFR Summary](#9-nfr-summary)

---

## 1. Performance

### NFR-P1: App Responsiveness

| Metric | Target |
|--------|--------|
| Cold start time | <2s (p95) |
| Hot start time | <500ms (p95) |
| Screen transitions | <300ms |
| Button tap response | <100ms |

### NFR-P2: Smart Pattern Memory Query

| Metric | Target |
|--------|--------|
| Pre-fill last workout | <500ms p95 |
| Exercise search | <200ms after typing |
| Workout history load (90d) | <1s |

**Rationale:** Smart Pattern Memory is killer feature - must be instant.

### NFR-P3: AI Response Times

| Model | Target | Acceptable |
|-------|--------|------------|
| Llama (self-hosted) | <2s p95 | <3s |
| Claude API | <3s p95 | <4s |
| GPT-4 API | <4s p95 | <5s |
| Timeout | 10s | Show retry option |

### NFR-P4: Offline Performance

| Feature | Requirement |
|---------|-------------|
| Fitness logging | 100% offline |
| Mood tracking | 100% offline |
| Cached meditation | <100ms to start |
| Data sync on reconnect | <5s typical |

### NFR-P5: App Size & Memory

| Metric | Target |
|--------|--------|
| Initial download | <50MB |
| Memory (background) | <150MB |
| Memory (active) | <250MB |
| Meditation cache | <100MB total |

---

## 2. Security

### NFR-S1: Data Encryption

| Data Type | Encryption |
|-----------|------------|
| Journal entries | E2EE (AES-256-GCM) |
| Mental health assessments | E2EE (AES-256-GCM) |
| Passwords | bcrypt (Supabase Auth) |
| Data in transit | HTTPS/TLS 1.3 |
| Data at rest | AES-256 (Supabase) |

### NFR-S2: Authentication & Sessions

| Aspect | Requirement |
|--------|-------------|
| Session expiration | 30 days inactivity |
| Password requirements | Min 8 chars, 1 uppercase, 1 number, 1 special |
| Social auth | OAuth 2.0 (Google, Apple) |
| MFA | P1 (email-based 2FA) |

### NFR-S3: GDPR Compliance

| Right | Implementation |
|-------|----------------|
| Right to access | Export all data (JSON + CSV) |
| Right to deletion | Delete within 7 days |
| Data retention | Purge 30 days after deletion |
| Privacy policy | Clear, visible, GDPR-compliant |

### NFR-S4: Vulnerability Protection

| Protection | Implementation |
|------------|----------------|
| API rate limiting | 100 req/min per user |
| SQL injection | Supabase RLS policies |
| XSS | Input sanitization |
| Security audits | Quarterly (P1) |

### NFR-S5: Privacy

| Principle | Implementation |
|-----------|----------------|
| No data selling | Never sell to third parties |
| AI analysis | Opt-in only for journal sentiment |
| Analytics | Anonymous only (no PII) |
| Third-party SDKs | Minimal (Supabase, Firebase, Sentry) |

---

## 3. Scalability

### NFR-SC1: User Capacity

| Year | Target Users | Database |
|------|--------------|----------|
| Year 1 | 5,000 active | PostgreSQL (Supabase) |
| Year 2 | 25,000 active | Same, vertical scaling |
| Year 3 | 75,000 active | Same, scales to 100k+ |

### NFR-SC2: API Scalability

| Service | Limit |
|---------|-------|
| Supabase API | 10,000 req/sec |
| Supabase Realtime | 10,000 concurrent |
| AI calls (Free) | 3-5/day/user |
| AI calls (Standard) | 20-30/day/user |
| AI calls (Premium) | Unlimited (soft cap 200/day) |

### NFR-SC3: Data Storage

| Metric | Estimate |
|--------|----------|
| Per-user storage | 50MB/year |
| Year 3 total (75k users) | 3.75TB |
| Supabase cost | ~$79/month |

### NFR-SC4: Cost Management

| Category | Target % of Revenue |
|----------|---------------------|
| AI costs | <30% |
| Infrastructure | <20% |
| Total COGS | <50% |

---

## 4. Integration

### NFR-I1: Wearable Integration (P1)

| Platform | Data |
|----------|------|
| Apple Health | Sleep, HRV, steps, workouts |
| Google Fit | Sleep, steps, workouts |
| Sync frequency | Every app open + 1x/hour background |
| Fallback | Manual entry |

### NFR-I2: Export Integrations

| Format | Data |
|--------|------|
| CSV | Workouts, measurements |
| JSON + PDF | Journal entries |
| ZIP (GDPR) | All user data |

### NFR-I3: Third-Party APIs

| Provider | Fallback |
|----------|----------|
| OpenAI | Degrade to Claude |
| Anthropic | Degrade to Llama |
| Self-hosted Llama | Always available |
| API versioning | Pin to stable, test before upgrade |

---

## 5. Accessibility

### NFR-A1: Screen Reader Support

| Platform | Support Level |
|----------|---------------|
| iOS VoiceOver | Full core flows |
| Android TalkBack | Full core flows |
| Semantic labels | All interactive elements |
| Tab order | Logical navigation |

### NFR-A2: Visual Accessibility

| Standard | Requirement |
|----------|-------------|
| Color contrast | WCAG AA (4.5:1 body, 3:1 large) |
| Text scaling | Up to 200% system font |
| Dark mode | P1 |

### NFR-A3: Motor Accessibility

| Aspect | Requirement |
|--------|-------------|
| Touch targets | Min 44x44pt (iOS) / 48x48dp (Android) |
| Time-based interactions | None required |

### NFR-A4: Language Support

| Language | Status |
|----------|--------|
| English (EN-US, EN-GB) | MVP |
| Polish (PL) | MVP |
| German, Spanish, French | P1 |

---

## 6. Reliability

### NFR-R1: Uptime

| Metric | Target |
|--------|--------|
| Uptime | 99.5% (43h downtime/year) |
| Supabase SLA | 99.9% |
| Maintenance window | 2-5am UK/Poland |

### NFR-R2: Error Handling

| Aspect | Requirement |
|--------|-------------|
| Crash rate | <0.5% |
| Error tracking | Sentry (backend) |
| User-facing errors | Clear, actionable, no jargon |
| Graceful degradation | Offline mode, cached responses |

### NFR-R3: Data Integrity

| Aspect | Implementation |
|--------|----------------|
| Sync conflicts | Last-write-wins |
| Data validation | Server-side for all writes |
| Backups | Daily automated |
| Disaster recovery | Point-in-time to 7 days |

---

## 7. Compliance

### NFR-C1: GDPR (EU)

| Requirement | Implementation |
|-------------|----------------|
| DPA | Signed with Supabase |
| Privacy policy | Prominently displayed |
| Consent | Opt-in analytics |
| User rights | Access, rectify, delete, port |

### NFR-C2: App Store Compliance

| Store | Requirements |
|-------|--------------|
| iOS | App Store Guidelines 2025 |
| Android | Play Developer Policies |
| Privacy labels | Accurate data disclosure |
| IAP | Platform guidelines (30%/15%) |

### NFR-C3: Content Rating

| Rating | Justification |
|--------|---------------|
| PEGI 12+ / ESRB Teen | Mental health content |
| No gambling | ✅ |
| No violence | ✅ |

### NFR-C4: Mental Health Disclaimer

| Requirement | Implementation |
|-------------|----------------|
| Disclaimer | "Not replacement for professional care" |
| Crisis resources | UK: 116 123, Poland: 116 123 |
| High-risk thresholds | GAD-7 >15, PHQ-9 >20 |
| Professional help | Recommend at moderate-severe |

---

## 8. Monitoring

### NFR-M1: Analytics Events

| Category | Events |
|----------|--------|
| User behavior | workout_logged, meditation_completed, goal_set |
| Retention | DAU, WAU, MAU, D1/D3/D7/D30 |
| Conversion | free_to_paid_funnel |
| Performance | screen_load_time, api_response_time |

### NFR-M2: Crash & Error Monitoring

| Tool | Purpose |
|------|---------|
| Firebase Crashlytics | iOS + Android crashes |
| Sentry | Backend errors (Edge Functions) |
| Alert threshold | >1% crash rate → page dev |

### NFR-M3: Business Metrics Dashboard

| Metric | Frequency |
|--------|-----------|
| MRR, ARR | Daily |
| Churn rate | Weekly |
| CAC, LTV, LTV:CAC | Monthly |
| Subscription distribution | Daily |
| AI cost per user | Weekly |

---

## 9. NFR Summary

### By Category

| Category | Count |
|----------|-------|
| Performance | 5 |
| Security | 5 |
| Scalability | 4 |
| Integration | 3 |
| Accessibility | 4 |
| Reliability | 3 |
| Compliance | 4 |
| Monitoring | 3 |
| **TOTAL** | **37** |

### Critical NFRs (Must Have for MVP)

| NFR | Reason |
|-----|--------|
| NFR-P2 | Smart Pattern Memory is killer feature |
| NFR-P4 | Offline-first is core architecture |
| NFR-S1 | E2EE for mental health data |
| NFR-S3 | GDPR compliance (EU market) |
| NFR-C4 | Mental health safety |
| NFR-R2 | <0.5% crash rate |

---

## Powiązane Dokumenty

- [PRD-overview.md](./PRD-overview.md) - Przegląd produktu
- [ARCH-security.md](../architecture/ARCH-security.md) - Security architecture
- [ARCH-database-schema.md](../architecture/ARCH-database-schema.md) - Database schema

---

*37 Non-Functional Requirements | Performance, Security, Scalability, Accessibility, Reliability, Compliance*
