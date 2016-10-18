import UIKit
import Malibu

// MARK: - List, Detail, Delete

struct NoteFeature: ListFeature, DetailFeature, DeleteFeature {
  typealias Model = Note

  var resource = "posts"

  func render(model: Note, on cell: UITableViewCell) {
    cell.textLabel?.text = model.title.capitalized
    cell.detailTextLabel?.text = "Note ID: \(model.id)"
  }

  func select(model: Note, controller: UITableViewController) {
    let detailController = NoteDetailController(id: model.id)
    controller.navigationController?.pushViewController(detailController, animated: true)
  }
}

// MARK: - Update

extension NoteFeature: UpdateFeature {

  struct Request: PATCHRequestable {
    var message: Message

    init(model: Note) {
      message = Message(resource: "posts/\(model.id)")
      message.parameters = [
        "title" : model.title,
        "body"  : model.body
      ]
    }
  }

  func buildUpdateRequest(from model: Model) -> PATCHRequestable {
    return Request(model: model)
  }
}
