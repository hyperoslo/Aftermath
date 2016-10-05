import Foundation
import Tailor
import Sugar

struct User: SafeMappable {

  let id: Int
  let name: String
  let username: String
  let email: String
  let phone: String
  let website: String

  init(_ map: JSONDictionary) throws {
    id = try <-map.property("id")
    name = try <-map.property("name")
    username = try <-map.property("username")
    email = try <-map.property("email")
    phone = try <-map.property("phone")
    website = try <-map.property("website")
  }
}
