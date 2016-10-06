import Tailor
import Aftermath

struct Note: Entity {
  let id: Int
  let userId: Int
  var title: String
  var body: String

  init(_ map: JSONDictionary) throws {
    id = try <-map.property("id")
    userId = try <-map.property("userId")
    title = try <-map.property("title")
    body = try <-map.property("body")
  }
}
