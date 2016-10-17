import UIKit
import Aftermath

typealias ListControllerFeature = ListFeature & UpdateFeature & DeleteFeature

class ListController<Feature: ListControllerFeature>: UITableViewController, CommandProducer, ReactionProducer {

  let feature: Feature
  var models: [Feature.Model] = []

  // MARK: - Initialization

  required init(feature: Feature) {
    self.feature = feature
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  deinit {
    // Don't forget to dispose all reaction tokens.
    disposeAll()
  }

  // MARK: - View lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()

    title = "Aftermath"
    setupTableView()
    setupReactions()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    refreshData()
  }

  // MARK: - Configuration

  func setupTableView() {
    tableView.register(TableCell.self, forCellReuseIdentifier: TableCell.identifier)
    refreshControl = UIRefreshControl()
    refreshControl?.addTarget(self, action: #selector(refreshData), for: .valueChanged)
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
        self?.showAlert(title: "Oops!", message: (error as NSError).description)
      }))

    // React to update event
    react(to: UpdateCommand<Feature>.self, with: Reaction(
      consume: { [weak self] model in
        guard let row = self?.models.index(where: { $0.id == model.id }) else {
          return
        }

        let indexPath = IndexPath(row: row, section: 0)

        self?.models[row] = model
        self?.tableView.reloadRows(at: [indexPath], with: .automatic)
      },
      rescue: { [weak self] error in
        self?.showAlert(error: error)
      }))

    // React to delete event
    react(to: DeleteCommand<Feature>.self, with: Reaction(
      consume: { [weak self] id in
        guard let row = self?.models.index(where: { $0.id == id }) else {
          return
        }

        let indexPath = IndexPath(row: row, section: 0)
        self?.models.remove(at: row)
        self?.tableView.deleteRows(at: [indexPath], with: .automatic)
      },
      rescue: { [weak self] error in
        self?.showAlert(error: error)
      }))
  }

  // MARK: - Actions

  func refreshData() {
    // Execute command to load a list of models.
    execute(command: ListCommand<Feature>())
  }

  // MARK: - UITableViewDataSource

  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    let count = models.count
    tableView.backgroundView?.isHidden = count > 0

    return count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: TableCell.identifier,
                                                           for: indexPath)
    let model = models[indexPath.item]
    feature.render(model: model, on: cell)

    return cell
  }

  // MARK: - UITableViewDelegate

  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 64
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)

    let model = models[indexPath.row]
    feature.select(model: model, controller: self)
  }

  override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    return true
  }

  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle,
                          forRowAt indexPath: IndexPath) {
    let model = models[indexPath.item]

    if editingStyle == UITableViewCellEditingStyle.delete {
      execute(command: DeleteCommand<Feature>(id: model.id))
    }
  }
}
