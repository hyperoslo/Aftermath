// Aftermath iOS Playground

import UIKit
import PlaygroundSupport
import Aftermath

// Let's say we want to fetch a list of models.

struct Book {

  static var list: [Book] {
    return [
      Book(title: "The Catcher in the Rye", author: "J.D. Salinger"),
      Book(title: "On the Road", author: "Jack Kerouac")
    ]
  }

  let title: String
  let author: String
}

// Start by creating a command that has an output set to be a list of books.

struct BooksCommand: Command {
  typealias Output = [Book]
}

// Command is an intention that needs to be translated into an action by handler.
// The command handler is responsible for publishing events to notify about
// results of the operation it performs.

struct BooksCommandHandler: CommandHandler {

  func handle(command: BooksCommand) throws -> Event<BooksCommand> {
    // Start network request to fetch data.
    // Here we simulate it with 2 seconds delay.
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
      var books = Book.list
      books.append(Book(title: "The Crying of Lot 49", author: "Thomas Pynchon"))

      self.publish(data: books)
    }

    // Load data from local database/cache.
    let localBooks = Book.list

    // If the list is empty let the listeners know that operation is in the process.
    return Book.list.isEmpty ? Event.progress : Event.data(localBooks)
  }
}

// Every command handler needs to be registered on Aftermath Engine.

Engine.shared.use(handler: BooksCommandHandler())

// Every action needs a reaction.
// Let's make a controller that executes a command and reacts on output events.

class ViewController: UITableViewController, CommandProducer, ReactionProducer {

  let reuseIdentifier = "book"
  var books = [Book]()

  deinit {
    // Don't forget to dispose all reaction tokens.
    disposeAll()
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
    refreshControl = UIRefreshControl()
    refreshControl?.addTarget(self, action: #selector(refreshData), for: .valueChanged)

    // React to events.
    react(to: BooksCommand.self, with: Reaction(
      wait: { [weak self] in
        self?.refreshControl?.beginRefreshing()
      },
      consume: { [weak self] books in
        self?.books = books
        self?.refreshControl?.endRefreshing()
        self?.tableView.reloadData()
      },
      rescue: { [weak self] error in
        self?.refreshControl?.endRefreshing()
        print(error)
    }))
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    refreshData()
  }

  func refreshData() {
    execute(command: BooksCommand())
  }

  // MARK: - Table view

  override func tableView(_ tableView: UITableView,
                          numberOfRowsInSection section: Int) -> Int{
    return books.count
  }

  override func tableView(_ tableView: UITableView,
                          cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(
      withIdentifier: reuseIdentifier, for: indexPath)
    let book = self.books[indexPath.row]
    cell.textLabel?.text = "\(book.author) - \(book.title)"

    return cell
  }
}

var controller = ViewController()
PlaygroundPage.current.liveView = controller.view
