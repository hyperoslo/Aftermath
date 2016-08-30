import Malibu

struct PostsRequest: GETRequestable {
  var message = Message(resource: "posts")
}

struct UsersRequest: GETRequestable {
  var message = Message(resource: "users")
}
