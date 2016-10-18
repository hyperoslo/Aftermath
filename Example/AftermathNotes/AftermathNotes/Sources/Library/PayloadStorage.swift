import Cache

typealias JsonDictionary = [String: Any]
typealias JsonArray = [JsonDictionary]

struct PayloadStorage {

  static let shared = PayloadStorage()

  let cache = Cache<JSON>(name: "AftermathPayloadCache")

  // MARK: - Save

  func save(array: JsonArray, with key: String, completion: (() -> Void)? = nil) {
    let expiry = Expiry.date(Date().addingTimeInterval(60 * 60 * 24))

    cache.add(key, object: JSON.array(array), expiry: expiry) {
      DispatchQueue.main.async {
        completion?()
      }
    }
  }

  // MARK: - Load

  func load(key: String, completion: @escaping (JsonArray?) -> Void) {
    cache.object(key) { json in
      DispatchQueue.main.async {
        completion(json?.object as? JsonArray)
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
