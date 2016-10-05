import Cache

typealias JSONDictionary = [String: AnyObject]
typealias JSONArray = [JSONDictionary]

struct PayloadStorage {

  enum Key: String {
    case Notes
  }

  static let sharedInstance = PayloadStorage()

  let cache = Cache<JSON>(name: "AftermathPayloadCache")

  // MARK: - Save

  func save(array array: JSONArray, with key: Key, completion: (() -> Void)? = nil) {
    let expiry = Expiry.Date(NSDate().dateByAddingTimeInterval(60 * 60 * 24))

    cache.add(key.rawValue, object: JSON.Array(array), expiry: expiry) {
      dispatch_async(dispatch_get_main_queue()) {
        completion?()
      }
    }
  }

  // MARK: - Load

  func load(key: Key, completion: JSONArray? -> Void) {
    cache.object(key.rawValue) { json in
      dispatch_async(dispatch_get_main_queue()) {
        completion(json?.object as? JSONArray)
      }
    }
  }

  // MARK: - Remove

  func remove(key: Key) {
    cache.remove(key.rawValue)
  }

  func clear() {
    cache.clear()
  }
}
