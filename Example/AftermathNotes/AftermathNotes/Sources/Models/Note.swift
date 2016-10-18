import Foundation
import Tailor
import Aftermath

struct Note: SafeMappable, Identifiable {

  let id: Int
  let userId: Int
  let title: String
  let body: String

  init(_ map: JsonDictionary) throws {
    id = try <-map.property("id")
    userId = try <-map.property("userId")
    title = try <-map.property("title")
    body = try <-map.property("body")
  }
}
