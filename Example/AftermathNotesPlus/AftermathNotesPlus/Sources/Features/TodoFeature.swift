import UIKit
import Malibu
import Aftermath

// MARK: - List, Delete

struct TodoFeature: ListFeature, DeleteFeature, CommandProducer {
  typealias Model = Todo

  var resource = "todos"

  func render(model: Todo, on cell: UITableViewCell) {
    cell.textLabel?.text = model.title.capitalizedString
    cell.accessoryType = model.completed ? .Checkmark : .None
  }

  func select(model: Todo, controller: UITableViewController) {
    var model = model
    model.completed = !model.completed

    execute(command: UpdateCommand<TodoFeature>(model: model))
  }
}

// MARK: - Update

extension TodoFeature: UpdateFeature {

  struct UpdateRequest: PATCHRequestable {
    var message: Message

    init(model: Todo) {
      message = Message(resource: "todos/\(model.id)")
      message.parameters = [
        "completed" : model.completed
      ]
    }
  }

  func buildUpdateRequest(from model: Model) -> PATCHRequestable {
    return UpdateRequest(model: model)
  }
}
