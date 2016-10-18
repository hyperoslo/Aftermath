import Aftermath
import Malibu
import Tailor

// MARK: - Feature

protocol UpdateFeature: RESTFeature {
  func buildUpdateRequest(from model: Model) -> PATCHRequestable
}

// MARK: - Command

struct UpdateCommand<Feature: UpdateFeature>: Aftermath.Command {
  typealias Output = Feature.Model

  let model: Feature.Model
}

// MARK: - Command handler

class UpdateCommandHandler<Feature: UpdateFeature>: Aftermath.CommandHandler {
  typealias Command = UpdateCommand<Feature>

  let feature: Feature

  init(feature: Feature) {
    self.feature = feature
  }

  func handle(command: Command) throws -> Event<Command> {
    // Make network request to patch data.
    let request = feature.buildUpdateRequest(from: command.model)

    Malibu.networking("base").PATCH(request)
      .validate()
      .toJsonDictionary()
      .then({ try Feature.Model($0) })
      .done({ model in
        self.publish(data: model)
      })
      .fail({ error in
        self.publish(error: error)
      })

    return Event.progress
  }
}
