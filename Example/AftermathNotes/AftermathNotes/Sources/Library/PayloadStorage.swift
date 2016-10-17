import Cache

typealias JSONDictionary = [String: AnyObject]
typealias JSONArray = [JSONDictionary]

struct PayloadStorage {

  static let sharedInstance = PayloadStorage()

  let cache = Cache<JSON>(name: "AftermathPayloadCache")

  // MARK: - Save

  func save(array array: JSONArray, with key: String, completion: (() -> Void)? = nil) {
    let expiry = Expiry.Date(NSDate().dateByAddingTimeInterval(60 * 60 * 24))

    cache.add(key, object: JSON.Array(array), expiry: expiry) {
      dispatch_async(dispatch_get_main_queue()) {
        completion?()
      }
    }
  }

  // MARK: - Load

  func load(key: String, completion: JSONArray? -> Void) {
    cache.object(key) { json in
      dispatch_async(dispatch_get_main_queue()) {
        completion(json?.object as? JSONArray)
      }
    }
  }

  // MARK: - Remove

  func remove(key: String) {
    cache.remove(key)
  }

  func clear() {
    cache.clear()
  }
}
