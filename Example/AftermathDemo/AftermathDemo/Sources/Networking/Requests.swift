import Malibu

struct PostsRequest: GETRequestable {
  var message = Message(resource: "posts")
}

struct PostRequest: GETRequestable {
  var message: Message

  init(id: Int) {
    message = Message(resource: "posts/\(id)")
  }
}
