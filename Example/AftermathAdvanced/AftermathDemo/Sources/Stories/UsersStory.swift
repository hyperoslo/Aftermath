import Aftermath
import Malibu

struct UsersStory {

  struct Command: Aftermath.Command {
    typealias Output = [User]
  }

  struct Handler: Aftermath.CommandHandler {

    func handle(command: Command) throws -> Event<Command> {
      let request = UsersRequest()

      Malibu.networking("base").GET(request)
        .validate()
        .toJSONArray()
        .then({ array -> [User] in try array.map({ try User($0) }) })
        .done({ users in
          self.publish(data: users)
        })
        .fail({ error in
          self.publish(error: error)
        })

      return Event.Progress
    }
  }
}
