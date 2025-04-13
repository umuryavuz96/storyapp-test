import Foundation

extension CacheService {
    public static var live: Self {
        let cache = NSCache<NSString, CacheEntry>()
        cache.countLimit = 100
        
        return Self(
            set: { value, key in
                let entry = CacheEntry(value: value)
                cache.setObject(entry, forKey: key as NSString)
            },
            get: { key in
                cache.object(forKey: key as NSString)?.value
            },
            remove: { key in
                cache.removeObject(forKey: key as NSString)
            },
            clear: {
                cache.removeAllObjects()
            }
        )
    }
}

private final class CacheEntry {
    let value: Data
    
    init(value: Data) {
        self.value = value
    }
}
