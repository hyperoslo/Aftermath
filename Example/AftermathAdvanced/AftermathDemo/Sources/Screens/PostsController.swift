import UIKit
import Aftermath

protocol ListBehavior {

  associatedtype Model
  associatedtype Cell: UITableViewCell

  func present(model: Model, on cell: Cell)
  func select(model: Model, on controller: UITableViewController)
}


class PostsController: UITableViewController, CommandProducer, ReactionProducer {

  lazy var dataSource: DataSource<Post, TableCell> = { [unowned self] in
    let dataSource = DataSource(configure: self.configure, action: self.selectAction)
    return dataSource
    }()

  deinit {
    // Don't forget to dispose all reaction tokens.
    disposeAll()
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    setupTableView()

    // Register reaction listener
    react(to: PostsStory.Command.self, with: Reaction(
      wait: { [weak self] in
        self?.refreshControl?.beginRefreshing()
      },
      consume: { [weak self] items in
        self?.dataSource.items = items
        self?.tableView.reloadData()
        self?.refreshControl?.endRefreshing()
      },
      rescue: { [weak self] error in
        self?.refreshControl?.endRefreshing()
        print(error)
      }
    ))
  }

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)

    // Execute command to load a list of posts.
    execute(command: PostsStory.Command())
  }

  // MARK: - Configuration

  func setupTableView() {
    tableView.dataSource = dataSource
    tableView.delegate = dataSource

    tableView.registerClass(TableCell.self, forCellReuseIdentifier: TableCell.identifier)

    refreshControl = UIRefreshControl()
    refreshControl?.addTarget(self, action: #selector(refreshData(_:)), forControlEvents: .ValueChanged)
  }

  func configure(post: Post, cell: TableCell) {

  }

  // MARK: - Actions

  func refreshData(refreshControl: UIRefreshControl) {
    execute(command: PostsStory.Command())
  }

  func selectAction(post: Post) {

  }
}
