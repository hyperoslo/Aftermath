import Aftermath
import Malibu
import Tailor

// MARK: - Feature

protocol ListFeature: RESTFeature {
  func render(model: Model, on cell: UITableViewCell)
  func select(model: Model, controller: UITableViewController)
}

// MARK: - Request

struct ListRequest: GETRequestable {
  var message = Message(resource: "todos")

  init(resource: String) {
    message = Message(resource: "\(resource)")
  }
}

// MARK: - Command

struct ListCommand<Feature: RESTFeature>: Aftermath.Command {
  typealias Output = [Feature.Model]
}

// MARK: - Command handler

class ListCommandHandler<Feature: RESTFeature>: Aftermath.CommandHandler {
  typealias Command = ListCommand<Feature>

  let feature: Feature
  var isFetched = false

  init(feature: Feature) {
    self.feature = feature
  }

  func handle(command: Command) throws -> Event<Command> {
    // Load data from cache storage.
    loadLocalData()

    // Make network request to fetch updated data.
    isFetched = false
    refresh()

    return Event.progress
  }

  func loadLocalData() {
    PayloadStorage.shared.load(key: Feature.Model.identifier) { array in
      guard let array = array, !self.isFetched else {
        return
      }

      do {
        let models = try array.map({ try Feature.Model($0) })
        self.publish(data: models)
      } catch {
        self.publish(error: error)
      }
    }
  }

  func refresh() {
    let request = ListRequest(resource: feature.resource)

    Malibu.networking("base").GET(request)
      .validate()
      .toJsonArray()
      .then({ array -> [Feature.Model] in
        PayloadStorage.shared.save(array: array, with: Feature.Model.identifier)
        return try array.map({
          try Feature.Model($0)
        })
      })
      .done({ models in
        self.isFetched = true
        self.publish(data: models)
      })
      .fail({ error in
        self.isFetched = false
        self.publish(error: error)
      })
  }
}
