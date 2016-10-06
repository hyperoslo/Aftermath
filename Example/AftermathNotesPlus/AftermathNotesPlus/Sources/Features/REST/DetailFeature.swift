import Aftermath
import Malibu
import Tailor

// MARK: - Feature

protocol DetailFeature: RESTFeature {}

// MARK: - Request

struct DetailRequest: GETRequestable {
  var message: Message

  init(resource: String, id: Int) {
    message = Message(resource: "\(resource)/\(id)")
  }
}

// MARK: - Command

struct DetailCommand<Feature: DetailFeature>: Aftermath.Command {
  typealias Output = Feature.Model

  let id: Int
}

// MARK: - Command handler

class DetailCommandHandler<Feature: DetailFeature>: Aftermath.CommandHandler {
  typealias Command = DetailCommand<Feature>

  let feature: Feature

  init(feature: Feature) {
    self.feature = feature
  }

  func handle(command: Command) throws -> Event<Command> {
    // Make network request to fetch data.
    let request = DetailRequest(resource: feature.resource, id: command.id)

    Malibu.networking("base").GET(request)
      .validate()
      .toJSONDictionary()
      .then({ try Feature.Model($0) })
      .done({ note in
        self.publish(data: note)
      })
      .fail({ error in
        self.publish(error: error)
      })

    return Event.Progress
  }
}
