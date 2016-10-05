import UIKit
import Aftermath

class DataSource<Model, Cell: Identifiable> : NSObject, UITableViewDataSource, UITableViewDelegate {

  typealias Configuration = (Model, Cell) -> Void
  typealias Action = Model -> Void

  let cellIdentifier: String
  let configure: Configuration
  var cellHeight: CGFloat = 64
  var items = [Model]()
  var action: Action?

  init(configure: Configuration, action: Action? = nil) {
    self.cellIdentifier = Cell.identifier
    self.configure = configure
    self.action = action
  }

  // MARK: - UITableViewDataSource

  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }

  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    let count = items.count
    tableView.backgroundView?.hidden = count > 0

    return count
  }

  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath)
    let item = items[indexPath.item]

    if let cell = cell as? Cell {
      configure(item, cell)
    }

    return cell
  }

  // MARK: - UITableViewDelegate

  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return cellHeight
  }

  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: true)

    guard let action = action else { return }

    let item = items[indexPath.row]
    action(item)
  }
}
