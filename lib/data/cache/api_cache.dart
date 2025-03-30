class ApiCache {
  static final _instance = ApiCache._internal();
  factory ApiCache() => _instance;
  ApiCache._internal();

  final _cache = <String, CacheEntry>{};
  final Duration defaultCacheDuration = const Duration(minutes: 2);

  dynamic get(String key) {
    final entry = _cache[key];
    if (entry != null && !entry.isExpired) {
      return entry.data;
    }
    _cache.remove(key);
    return null;
  }

  void set(String key, dynamic data, {Duration? duration}) {
    print('Setting cache for $key');
    print('Cache data: $data');
    _cache[key] = CacheEntry(
      data: data,
      expiresAt: DateTime.now().add(duration ?? defaultCacheDuration),
    );
  }

  void clear() => _cache.clear();
}

class CacheEntry {
  final dynamic data;
  final DateTime expiresAt;

  CacheEntry({required this.data, required this.expiresAt});

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}