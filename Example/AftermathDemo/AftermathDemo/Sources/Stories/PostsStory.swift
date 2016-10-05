import Aftermath
import Malibu

struct PostsStory {

  struct Command: Aftermath.Command {
    typealias Output = [Post]
  }

  struct Handler: Aftermath.CommandHandler {

    func handle(command: Command) throws -> Event<Command> {
      let request = PostsRequest()

      Malibu.networking("base").GET(request)
        .validate()
        .toJSONArray()
        .then({ array -> [Post] in try array.map({ try Post($0) }) })
        .done({ posts in
          self.publish(data: posts)
        })
        .fail({ error in
          self.publish(error: error)
        })

      return Event.Progress
    }
  }
}
