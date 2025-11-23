import '../error/failures.dart';

/// Rate limiter for controlling request frequency
/// Uses token bucket algorithm for fair rate limiting
class RateLimiter {
  final int requestsPerMinute;
  final int burstSize;
  final Map<String, _TokenBucket> _buckets = {};

  RateLimiter({
    required this.requestsPerMinute,
    int? burstSize,
  }) : burstSize = burstSize ?? requestsPerMinute;

  /// Check if a request is allowed for the given key
  /// Throws RateLimitFailure if rate limit is exceeded
  void checkLimit(String key) {
    final bucket = _buckets.putIfAbsent(
      key,
      () => _TokenBucket(
        capacity: burstSize,
        refillRate: requestsPerMinute / 60.0, // tokens per second
      ),
    );

    if (!bucket.tryConsume()) {
      throw RateLimitFailure(
        'Rate limit exceeded. Max $requestsPerMinute requests per minute. '
        'Please wait ${bucket.timeUntilNextToken().inSeconds} seconds.',
      );
    }
  }

  /// Check if a request is allowed without throwing
  /// Returns true if allowed, false if rate limit exceeded
  bool isAllowed(String key) {
    final bucket = _buckets.putIfAbsent(
      key,
      () => _TokenBucket(
        capacity: burstSize,
        refillRate: requestsPerMinute / 60.0,
      ),
    );

    return bucket.tryConsume();
  }

  /// Get time until next request is allowed
  Duration timeUntilAllowed(String key) {
    final bucket = _buckets[key];
    if (bucket == null) {
      return Duration.zero;
    }
    return bucket.timeUntilNextToken();
  }

  /// Reset rate limit for a specific key
  void reset(String key) {
    _buckets.remove(key);
  }

  /// Clear all rate limit data
  void clear() {
    _buckets.clear();
  }
}

/// Token bucket implementation for rate limiting
class _TokenBucket {
  final int capacity;
  final double refillRate; // tokens per second
  double _tokens;
  DateTime _lastRefill;

  _TokenBucket({
    required this.capacity,
    required this.refillRate,
  })  : _tokens = capacity.toDouble(),
        _lastRefill = DateTime.now();

  bool tryConsume() {
    _refill();

    if (_tokens >= 1.0) {
      _tokens -= 1.0;
      return true;
    }

    return false;
  }

  void _refill() {
    final now = DateTime.now();
    final secondsSinceLastRefill = now.difference(_lastRefill).inMilliseconds / 1000.0;

    _tokens = (_tokens + secondsSinceLastRefill * refillRate).clamp(0.0, capacity.toDouble());
    _lastRefill = now;
  }

  Duration timeUntilNextToken() {
    _refill();

    if (_tokens >= 1.0) {
      return Duration.zero;
    }

    final tokensNeeded = 1.0 - _tokens;
    final secondsNeeded = (tokensNeeded / refillRate).ceil();
    return Duration(seconds: secondsNeeded);
  }
}
