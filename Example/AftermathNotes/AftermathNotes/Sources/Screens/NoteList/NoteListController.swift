import UIKit
import Aftermath

class NoteListController: UITableViewController, CommandProducer, ReactionProducer {

  var notes = [Note]()

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

    // Register reaction listener
    react(to: NoteListStory.Command.self, with: Reaction(
      wait: { [weak self] in
        self?.refreshControl?.beginRefreshing()
      },
      consume: { [weak self] notes in
        self?.notes = notes
        self?.tableView.reloadData()
        self?.refreshControl?.endRefreshing()
      },
      rescue: { [weak self] error in
        self?.refreshControl?.endRefreshing()
        self?.showAlert(message: (error as NSError).description)
      }))
  }

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)

    // Execute command to load a list of notes.
    execute(command: NoteListStory.Command())
  }

  // MARK: - Configuration

  func setupTableView() {
    tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: UITableViewCell.identifier)
    refreshControl = UIRefreshControl()
    refreshControl?.addTarget(self, action: #selector(refreshData(_:)), forControlEvents: .ValueChanged)
  }

  // MARK: - UITableViewDataSource

  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }

  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    let count = notes.count
    tableView.backgroundView?.hidden = count > 0

    return count
  }

  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier(UITableViewCell.identifier,
                                                           forIndexPath: indexPath)
    let note = notes[indexPath.item]

    cell.textLabel?.text = note.title.capitalizedString
    cell.detailTextLabel?.text = "Note ID: \(note.id)"

    return cell
  }

  // MARK: - UITableViewDelegate

  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return 64
  }

  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: true)

    let note = notes[indexPath.row]
    let controller = NoteDetailController(id: note.id)

    navigationController?.pushViewController(controller, animated: true)
  }

  // MARK: - Actions

  func refreshData(refreshControl: UIRefreshControl) {
    execute(command: NoteListStory.Command())
  }
}
