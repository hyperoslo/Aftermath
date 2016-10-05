import Aftermath
import Malibu

struct PostStory {

  struct Command: Aftermath.Command {
    typealias Output = Post

    let id: Int
  }

  struct Handler: Aftermath.CommandHandler {

    func handle(command: Command) throws -> Event<Command> {
      let request = PostRequest(id: command.id)

      Malibu.networking("base").GET(request)
        .validate()
        .toJSONDictionary()
        .then({ try Post($0) })
        .done({ post in
          self.publish(data: post)
        })
        .fail({ error in
          self.publish(error: error)
        })

      return Event.Progress
    }
  }
}
