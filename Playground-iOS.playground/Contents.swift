// Aftermath iOS Playground

import UIKit
import XCPlayground
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

// Start by creating a command which has an output set to be a list of books.

struct BooksCommand: Command {
  typealias Output = [Book]
}

// Command is an intention that needs to be translated into action by handler.

struct BooksCommandHandler: CommandHandler {

  func handle(command: BooksCommand) throws -> Event<BooksCommand> {
    // Start network request to fetch data.
    // Here we simulate it with 2 seconds delay.
    let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(2 * Double(NSEC_PER_SEC)))
    dispatch_after(delayTime, dispatch_get_main_queue()) {
      var books = Book.list
      books.append(Book(title: "The Crying of Lot 49", author: "Thomas Pynchon"))

      self.publish(data: books)
    }

    // Load data from local database/cache.
    let localBooks = Book.list

    // If the list is empty let the listeners know that operation is in the process
    return Book.list.isEmpty ? Event.Progress : Event.Data(localBooks)
  }
}

// Every command handler needs to be registered on Aftermath Engine

Engine.sharedInstance.use(BooksCommandHandler())

// Every action needs a reaction.
// Let's make a controller that executes a command and reacts on output events.

class ViewController: UITableViewController, CommandProducer, ReactionProducer {

  let reuseIdentifier = "book"
  var books = [Book]()

  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.registerClass(UITableViewCell.self,
                            forCellReuseIdentifier: reuseIdentifier)
    refreshControl = UIRefreshControl()
    refreshControl?.addTarget(self, action: #selector(refreshData), forControlEvents: .ValueChanged)

    // Reac on events
    react(to: BooksCommand.self, with: Reaction(
      wait: {
        self.refreshControl?.beginRefreshing()
      },
      consume: { books in
        self.books = books
        self.refreshControl?.endRefreshing()
        self.tableView.reloadData()
      },
      rescue: { error in
        self.refreshControl?.endRefreshing()
        print(error)
    }))
  }

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    refreshData()
  }

  func refreshData() {
    execute(command: BooksCommand())
  }

  // MARK: - Table view

  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
    return books.count
  }

  override func tableView(tableView: UITableView,
                          cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier(
      reuseIdentifier, forIndexPath: indexPath)
    let book = self.books[indexPath.row]
    cell.textLabel?.text = "\(book.author) - \(book.title)"

    return cell
  }
}

var controller = ViewController()
XCPlaygroundPage.currentPage.liveView = controller.view
