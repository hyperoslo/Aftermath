import Aftermath
import Brick
import Malibu

struct UsersStory {

  struct Command: Aftermath.Command {
    typealias Output = [ViewModel]
  }

  struct Handler: Aftermath.CommandHandler {

    func handle(command: Command) throws -> Event<Command> {
      let request = UsersRequest()

      Malibu.networking("base").GET(request)
        .validate()
        .toJSONArray()
        .then({ array -> [User] in try array.map({ try User($0) }) })
        .then({ users -> [ViewModel] in
          return users.map({ user in
            ViewModel(
              identifier: user.id,
              title: user.name.capitalizedString,
              subtitle: "Email: \(user.email)",
              action: "users:\(user.id)")
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
