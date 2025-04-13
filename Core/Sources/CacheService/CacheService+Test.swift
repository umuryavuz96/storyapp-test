import Foundation
import Dependencies

extension CacheService {
    public static func test(maxSize: Int = 100) -> Self {
        // Using a serial queue for thread-safe access
        let queue = DispatchQueue(label: "com.storyapp.cacheservice.test")
        var storage: [String: Data] = [:]
        
        return Self(
            set: { @Sendable value, key in
                queue.sync {
                    if storage.count >= maxSize {
                        // FIFO: remove oldest entry (first key)
                        storage.removeValue(forKey: storage.keys.first ?? "")
                    }
                    storage[key] = value
                }
            },
            get: { @Sendable key in
                queue.sync {
                    storage[key]
                }
            },
            remove: { @Sendable key in
                queue.sync {
                    storage.removeValue(forKey: key)
                }
            },
            clear: { @Sendable in
                queue.sync {
                    storage.removeAll()
                }
            }
        )
    }
    
    public static var preview: Self {
        .test(maxSize: 10)
    }
    
    public static var mock: Self {
        .test(maxSize: 5)
    }
} 
