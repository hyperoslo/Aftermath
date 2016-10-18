import Aftermath
import Malibu
import Tailor

// MARK: - Feature

protocol DeleteFeature: RESTFeature {}

// MARK: - Request

struct DeleteRequest: DELETERequestable {
  var message: Message

  init(resource: String, id: Int) {
    message = Message(resource: "\(resource)/\(id)")
  }
}

// MARK: - Command

struct DeleteCommand<Feature: DeleteFeature>: Aftermath.Command {
  typealias Output = Int

  let id: Int
}

// MARK: - Command handler

class DeleteCommandHandler<Feature: DeleteFeature>: Aftermath.CommandHandler {
  typealias Command = DeleteCommand<Feature>

  let feature: Feature

  init(feature: Feature) {
    self.feature = feature
  }

  func handle(command: Command) throws -> Event<Command> {
    // Make network request to fetch data.
    let request = DeleteRequest(resource: feature.resource, id: command.id)

    Malibu.networking("base").DELETE(request)
      .validate()
      .done({ _ in
        self.publish(data: command.id)
      })
      .fail({ error in
        self.publish(error: error)
      })

    return Event.progress
  }
}
