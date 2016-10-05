import Aftermath
import Malibu
import Tailor

protocol LoadFeature {
  associatedtype Model: SafeMappable
  associatedtype Cell: UITableViewCell

  var request: GETRequestable { get }

  func present(model: Model, on cell: Cell)
  func select(model: Model, on controller: UITableViewController)
}

struct LoadCommand<Feature: LoadFeature>: Aftermath.Command {
  typealias Output = [Feature.Model]
}

struct LoadHandler<Feature: LoadFeature>: Aftermath.CommandHandler {

  typealias Command = LoadCommand<Feature>

  func handle(command: Command) throws -> Event<Command> {
    let request = PostsRequest()

    Malibu.networking("base").GET(request)
      .validate()
      .toJSONArray()
      .then({ array -> [Feature.Model] in try array.map({ try Feature.Model($0) }) })
      .done({ posts in
        self.publish(data: posts)
      })
      .fail({ error in
        self.publish(error: error)
      })

    return Event.Progress
  }
}
