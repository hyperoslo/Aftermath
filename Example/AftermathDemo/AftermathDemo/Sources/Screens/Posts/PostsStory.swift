import Aftermath
import Brick
import Malibu

struct PostsStory {

  struct Command: Aftermath.Command {
    typealias Output = [ViewModel]
  }

  struct Handler: Aftermath.CommandHandler {

    func handle(command: Command) throws -> Event<Command> {
      let request = PostsRequest()

      Malibu.networking("base").GET(request)
        .validate()
        .toJSONArray()
        .then({ array -> [Post] in try array.map({ try Post($0) }) })
        .then({ posts -> [ViewModel] in
          return posts.map({ post in
            ViewModel(
              identifier: post.id,
              title: post.title.capitalizedString,
              subtitle: "User ID: \(post.userId)",
              action: "posts:\(post.id)")
          })
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
