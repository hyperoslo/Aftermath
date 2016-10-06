import UIKit
import Aftermath

typealias ListControllerFeature = protocol<ListFeature, UpdateFeature, DeleteFeature>

class ListController<Feature: ListControllerFeature>: UITableViewController, CommandProducer, ReactionProducer {

  let feature: Feature
  var models: [Feature.Model] = []

  // MARK: - Initialization

  required init(feature: Feature) {
    self.feature = feature
    super.init(nibName: nil, bundle: nil)
  }

  deinit {
    // Don't forget to dispose all reaction tokens.
    disposeAll()
  }

  // MARK: - View lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()

    title = "Aftermath"
    view.stylize(Styles.Content)
    setupTableView()
    setupReactions()
  }

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)

    // Execute command to load a list of models.
    execute(command: ListCommand<Feature>())
  }

  // MARK: - Configuration

  func setupTableView() {
    tableView.registerClass(TableCell.self, forCellReuseIdentifier: TableCell.identifier)
    refreshControl = UIRefreshControl()
    refreshControl?.addTarget(self, action: #selector(refreshData(_:)), forControlEvents: .ValueChanged)
  }

  // MARK: - Reactions

  func setupReactions() {
    // React to list event
    react(to: ListCommand<Feature>.self, with: Reaction(
      wait: { [weak self] in
        self?.refreshControl?.beginRefreshing()
      },
      consume: { [weak self] models in
        self?.models = models
        self?.tableView.reloadData()
        self?.refreshControl?.endRefreshing()
      },
      rescue: { [weak self] error in
        self?.refreshControl?.endRefreshing()
        self?.showAlert(message: (error as NSError).description)
      }))

    // React to update event
    react(to: UpdateCommand<Feature>.self, with: Reaction(
      consume: { [weak self] model in
        guard let row = self?.models.indexOf({ $0.id == model.id }) else {
          return
        }

        let indexPath = NSIndexPath(forRow: row, inSection: 0)

        self?.models[row] = model
        self?.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
      },
      rescue: { [weak self] error in
        self?.showAlert(message: (error as NSError).description)
      }))

    // React to delete event
    react(to: DeleteCommand<Feature>.self, with: Reaction(
      consume: { [weak self] id in
        guard let row = self?.models.indexOf({ $0.id == id }) else {
          return
        }

        let indexPath = NSIndexPath(forRow: row, inSection: 0)
        self?.models.removeAtIndex(row)
        self?.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
      },
      rescue: { [weak self] error in
        self?.showAlert(message: (error as NSError).description)
      }))
  }

  // MARK: - Actions

  func refreshData(refreshControl: UIRefreshControl) {
    execute(command: ListCommand<Feature>())
  }

  // MARK: - UITableViewDataSource

  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }

  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    let count = models.count
    tableView.backgroundView?.hidden = count > 0

    return count
  }

  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier(TableCell.identifier,
                                                           forIndexPath: indexPath)
    let model = models[indexPath.item]
    feature.render(model, on: cell)

    return cell
  }

  // MARK: - UITableViewDelegate

  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return 64
  }

  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: true)

    let model = models[indexPath.row]
    feature.select(model, controller: self)
  }

  override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    return true
  }

  override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle,
                          forRowAtIndexPath indexPath: NSIndexPath) {
    let model = models[indexPath.item]

    if editingStyle == UITableViewCellEditingStyle.Delete {
      execute(command: DeleteCommand<Feature>(id: model.id))
    }
  }
}
