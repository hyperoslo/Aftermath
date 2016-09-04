import Aftermath
import Spots
import Brick
import Malibu

struct PostsStory {

  struct Command: Aftermath.Command {
    typealias Output = [Component]
  }

  struct Handler: Aftermath.CommandHandler {

    func handle(command: Command) throws -> Event<Command> {
      let request = PostsRequest()

      Malibu.networking("base").GET(request)
        .validate()
        .toJSONArray()
        .then({ array -> [Post] in try array.map({ try Post($0) }) })
        .then({ posts -> [Component] in
          let items = posts.map({ post in
            ViewModel(
              identifier: post.id,
              title: post.title.capitalizedString,
              subtitle: "User ID: \(post.userId)",
              action: "posts:\(post.id)")
          })

          return [Component(identifier: 0, kind: Component.Kind.List.rawValue, items: items)]
        })
        .done({ items in
          self.fulfill(items)
        })
        .fail({ error in
          self.reject(error)
        })

      return progress
    }
  }
}
