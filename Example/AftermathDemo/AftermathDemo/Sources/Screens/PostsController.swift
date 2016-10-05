import UIKit
import Aftermath

class PostsController: UITableViewController, CommandProducer, ReactionProducer {

  var posts = [Post]()

  deinit {
    // Don't forget to dispose all reaction tokens.
    disposeAll()
  }

  // MARK: - View lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()
    setupTableView()

    // Register reaction listener
    react(to: PostsStory.Command.self, with: Reaction(
      wait: { [weak self] in
        self?.refreshControl?.beginRefreshing()
      },
      consume: { [weak self] posts in
        self?.posts = posts
        self?.tableView.reloadData()
        self?.refreshControl?.endRefreshing()
      },
      rescue: { [weak self] error in
        self?.refreshControl?.endRefreshing()
        print(error)
      }))
  }

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)

    // Execute command to load a list of posts.
    execute(command: PostsStory.Command())
  }

  // MARK: - Configuration

  func setupTableView() {
    tableView.registerClass(TableCell.self, forCellReuseIdentifier: TableCell.identifier)
    refreshControl = UIRefreshControl()
    refreshControl?.addTarget(self, action: #selector(refreshData(_:)), forControlEvents: .ValueChanged)
  }

  // MARK: - UITableViewDataSource

  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }

  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    let count = posts.count
    tableView.backgroundView?.hidden = count > 0

    return count
  }

  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier(TableCell.identifier, forIndexPath: indexPath)
    let post = posts[indexPath.item]

    if let cell = cell as? TableCell {
      cell.textLabel?.text = post.title.capitalizedString
      cell.detailTextLabel?.text = "User ID: \(post.userId)"
    }

    return cell
  }

  // MARK: - UITableViewDelegate

  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return 64
  }

  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: true)

    let post = posts[indexPath.row]
    let controller = PostController(id: post.id)

    navigationController?.pushViewController(controller, animated: true)
  }

  // MARK: - Actions

  func refreshData(refreshControl: UIRefreshControl) {
    execute(command: PostsStory.Command())
  }
}
