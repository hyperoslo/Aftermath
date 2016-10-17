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
    view.stylize(MainStylesheet.Style.content)
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
    // React to note events
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
        self?.showAlert(error: error)
      }))
  }

  // MARK: - Actions

  func refreshData() {
    // Execute command to load a list of notes.
    execute(command: NoteListStory.Command())
  }

  // MARK: - UITableViewDataSource

  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    let count = notes.count
    tableView.backgroundView?.isHidden = count > 0

    return count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: TableCell.identifier, for: indexPath)
    let note = notes[indexPath.item]

    cell.textLabel?.text = note.title.capitalized
    cell.detailTextLabel?.text = "Note ID: \(note.id)"

    return cell
  }

  // MARK: - UITableViewDelegate

  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 64
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)

    let note = notes[indexPath.row]
    let controller = NoteDetailController(id: note.id)

    navigationController?.pushViewController(controller, animated: true)
  }
}
