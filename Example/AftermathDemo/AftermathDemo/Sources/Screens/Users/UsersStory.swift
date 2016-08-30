import Aftermath
import Brick
import Malibu

struct UsersStory {

  struct Projection: Aftermath.Projection {
    let items: [ViewModel]
  }

  struct Command: Aftermath.Command {
    typealias ProjectionType = Projection
  }

  struct Handler: Aftermath.CommandHandler {

    func handle(command: Command) throws -> Event<Projection> {
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
          self.publish(Event.Success(Projection(items: items)))
        })
        .fail({ error in
          self.publish(Event.Error(error))
        })

      return Event.Progress
    }
  }
}
