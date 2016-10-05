import Foundation
import Tailor
import Sugar

struct Note: SafeMappable {

  let id: Int
  let userId: Int
  let title: String
  let body: String

  init(_ map: JSONDictionary) throws {
    id = try <-map.property("id")
    userId = try <-map.property("userId")
    title = try <-map.property("title")
    body = try <-map.property("body")
  }
}
