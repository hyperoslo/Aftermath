![Aftermath](https://github.com/hyperoslo/Aftermath/blob/master/Images/cover.png)

[![CI Status](http://img.shields.io/travis/hyperoslo/Aftermath.svg?style=flat)](https://travis-ci.org/hyperoslo/Aftermath)
[![Version](https://img.shields.io/cocoapods/v/Aftermath.svg?style=flat)](http://cocoadocs.org/docsets/Aftermath)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
![Swift](https://img.shields.io/badge/%20in-swift%202.2-orange.svg)
[![License](https://img.shields.io/cocoapods/l/Aftermath.svg?style=flat)](http://cocoadocs.org/docsets/Aftermath)
[![Platform](https://img.shields.io/cocoapods/p/Aftermath.svg?style=flat)](http://cocoadocs.org/docsets/Aftermath)

## Description

**Aftermath** is a stateless message-driven micro-framework in Swift, which is
based on the concept of the unidirectional data flow architecture.

At first sight **Aftermath** may seem to be just a type-safe implementation of
the publish-subscribe messaging pattern, but actually it could be considered as
a distinct mental model in application design, different from familiar MVC,
MVVM or MVP approaches. Utilizing the ideas behind
[Event Sourcing](http://martinfowler.com/eaaDev/EventSourcing.html)
and [Flux](https://facebook.github.io/flux/) patterns it helps to separate
concerns, reduce code dependencies and make data flow more predictable.

## Core components

The following diagram demonstrates a simplified version of the flow
in **Aftermath** architecture and defines 4 main components that form the core
of the framework:

<div align="center">
<img src="https://github.com/hyperoslo/Aftermath/blob/master/Images/diagram1.png" />
</div><br/>

### Command

**Command** is a message with a set of instructions describing an intention to
execute the corresponding behavior. Command could lead to data fetching,
data mutation and any sort of sync or async operation that
produces desirable output needed to update application/view state.

Every command can produce only one output type.

### Command Handler

**Command Handler** layer is responsible for business logic in the application.
The submission of a command is received by a command handler, which usually
performs short- or long-term operation, such as network request, database query,
cache read/white process, etc. Command handler can be sync and publish the
result immediately. On the other hand it's the best place in the
application to write asynchronous code.

The restriction is to create only one command handler for each command.

### Event

**Command Handler** is responsible for publishing **events** that will be
consumed by reactions. There are 3 types of events:

- **Progress** event indicates that the operation triggered by command has been
started and is in the pending state at the moment.
- **Data** event holds the output produced by the command execution
- **Error** notifies that an error has been occurred during the command
execution

### Reaction

**Reaction** responds to event published by command handler. It is supposed
to handle 3 possible event types by describing the desired behavior in the
each scenario:

- **Wait** function reacts on `Progress` type of the event
- **Consume** function reacts on `Data` type of the event.
- **Rescue** function is a fallback for the case when `Error` type of the event
has been received.

Normally reaction performs UI updates, but could also be used for other kinds
of output processing.

## The flow

### Command execution

The first step is to declare a command. Let's say we want to fetch a list of
books from some untrusted resource and correct typos in titles and author names.
Your command type has to conform to `Aftermath.Command` protocol and the
`Output` must be implicitly specified:

```swift
// This is our model we are going to work with.
struct Book {
  let id: Int
  let title: String
  let author: String
}

struct BookListCommand: Command {
  // Result of this command will be a list of books.
  typealias Output = [Book]
}

struct BookUpdateCommand: Command {
  // Result of this command will be an updated book.
  typealias Output = Book

  // Let's pass the entire model to the command to simplify this example.
  // Ideally we wouldn't do that because a command is supposed to be as simple
  // as possible, only with attributes that are needed for handler.
  let book: Book
}
```

In order to execute a command you have to conform to `CommandProducer` protocol:

```swift
class ViewController: UITableViewController, CommandProducer {

  // Fetch a list of books.
  func load() {
    execute(command: BookListCommand())
  }

  // Update a single book with corrected title and/or author name.
  func update(book: Book) {
    execute(command: BookUpdateCommand(book: book))
  }
}
```

### Command handling

Command is an intention that needs to be translated into action by handler.
Command handler is responsible for publishing events to notify about results of
the operation it performs. Command handler type has to conform to
`Aftermath.CommandHandler` protocol that needs to know about the command type
it will work with:

```swift
struct BookListCommandHandler: CommandHandler {

  func handle(command: BookListCommand) throws -> Event<BooksCommand> {
    // Start network request to fetch data.
    fetchBooks { books, error in
      if let error = error {
        // Publish error.
        self.publish(error: error)
        return
      }

      // Publish fetched data.
      self.publish(data: books)
    }

    // Load data from local database/cache.
    let localBooks = loadLocalBooks()

    // If the list is empty let the listeners know that operation is in the process.
    return Book.list.isEmpty ? Event.Progress : Event.Data(localBooks)
  }
}
```

Every command handler needs to be registered on [Aftermath Engine](#engine).

```swift
Engine.sharedInstance.use(BookListCommandHandler())
```

### Reacting to events

The last step, but not the least, is to react to events published by command
handlers. Just conform to `ReactionProducer` protocol, implement reaction
behavior and you're ready to go:

```swift
class ViewController: UITableViewController, CommandProducer, ReactionProducer {

  var books = [Book]()

  deinit {
    // Don't forget to dispose all reaction tokens.
    disposeAll()
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    // React to events.
    react(to: BookListCommand.self, with: Reaction(
      wait: { [weak self] in
        // Wait for results to come.
        self?.refreshControl?.beginRefreshing()
      },
      consume: { [weak self] books in
        // We're lucky, there are some books to display.
        self?.books = books
        self?.refreshControl?.endRefreshing()
        self?.tableView.reloadData()
      },
      rescue: { [weak self] error in
        // Well, seems like something went wrong.
        self?.refreshControl?.endRefreshing()
        print(error)
    }))
  }
}
```

**It's important** to dispose all reaction tokens when your `ReactionProducer`
instance is about to be deallocated or reaction needs to be unsubscribed from
event.

```swift
// Disposes all reaction tokens for the current `ReactionProducer`.
disposeAll()

// Disposes a specified reaction token.
let token = react(to: BookListCommand.self, with: reaction)
dispose(token: token)
```

## Extra

### Action

**Action** is a variation of command that handles itself. It's a possibility to
simplify the code when command itself or business logic are super tiny. There
is no need to register action, it will be automatically added to the list of
active command handlers on the fly, when it's executed as a command.

```swift
import Sugar

struct WelcomeAction: Action {
  typealias Output = String

  let userId: String

  func handle(command: WelcomeAction) throws -> Event<WelcomeAction> {
    fetchUser(id: userId) { user in
      self.publish(data: "Hello \(user.name)")
    }
    return Event.Progress
  }
}

// Execute action

struct WelcomeManager: CommandProducer {

  func salute() {
    execute(WelcomeAction(userId: 11))
  }
}
```

### Fact

**Fact** works like notification with no async operations involved. It could
be used when there is no need to have a handler and generate an output, fact is
already an output itself and the only thing you want to do is notify all
subscribers that something happened in the system and they will react
accordingly. In this sense it's closer to a type-safe alternative to
`NSNotification`

```swift
struct LoginFact: Fact {
  let username: String
}

class ProfileController: UIViewController, ReactionProducer {

  override func viewDidLoad() {
    super.viewDidLoad()

    // React
    next { (fact: LoginFact) in
      title = fact.username
    }
  }
}

struct AuthService: FactProducer {
  func login() {
    let fact = LoginFact(username: "John Doe")
    // Publish
    post(fact: fact)  
  }
}
```

### Any types

`AnyCommand` and `AnyEvent` are special protocols that every `Command` or
`Event` conform to. They are used mostly in [middleware](#middleware) to
workaround restrictions with `associatedtype` in Swift protocols.

### Middleware

**Middleware** is a layer where commands and events could be intercepted before
the moment they reach listeners. It means you can modify/cancel/extend the
executed command in **Command Middleware**, or do appropriate operation in
**Event Middleware** before the published event is received by its reactions.
It's handy for logging, crash reporting, aborting particular commands and
events, etc.

```swift
// Command middleware
struct ErrorCommandMiddleware: CommandMiddleware {

  func intercept(command: AnyCommand, execute: Execute, next: Execute) throws {
    do {
      // Don't forget to call `next` to invoke the next function in the chain.
      try next(command)
    } catch {
      print("Command failed with error -> \(command)")
      throw error
    }
  }
}

Engine.sharedInstance.pipeCommands(through: [ErrorCommandMiddleware()])

// Event middleware
struct LogEventMiddleware: EventMiddleware {

  // Don't forget to call `next` to invoke the next function in the chain.
  func intercept(event: AnyEvent, publish: Publish, next: Publish) throws {
    print("Event published -> \(event)")
    try next(event)
  }
}

Engine.sharedInstance.pipeEvents(through: [LogEventMiddleware()])
```

**It's important** to call `next` to invoke the next function in the chain while
building your custom middleware.

## Engine

**Engine** in the main entry point for **Aftermath** configuration:

- Register command handlers:

```swift
Engine.sharedInstance.use(BookListCommandHandler())
```

- Add command and event middleware:

```swift
// Commands
Engine.sharedInstance.pipeCommands(through: [LogCommandMiddleware(), ErrorCommandMiddleware()])
// Events
Engine.sharedInstance.pipeEvents(through: [LogEventMiddleware(), ErrorEventMiddleware()])
```

- Set global error handler to catch all unexpected errors and framework
warnings:

```swift
struct EngineErrorHandler: ErrorHandler {

  func handleError(error: ErrorType) {
    if let error = error as? Error {
      print("Engine error -> \(error)")
    } else if let warning = error as? Warning {
      print("Engine warning -> \(warning)")
    } else {
      print("Unknown error -> \(error)")
    }
  }
}

Engine.sharedInstance.errorHandler = EngineErrorHandler()
```

- Dispose all registered command handlers and event listeners (reactions):

```swift
Engine.sharedInstance.invalidate()
```

## Summary

We believe that in iOS applications in most of the cases there is no real need
for single global state (single source of truth) or multiple sub-states
distributed between stores. Data is stored on disc in local persistence layer,
such as database and cache, or fetched from network. Then this content,
assembled piece by piece from different sources, is translated into the
"view state", which is readable by the view to render it on the screen. This
"view state" is kept in memory and valid at a given instant in time until we
switch the context and the current view is deallocated. Keeping that in mind,
it makes more sense to dispose the "view state" together with the view it
belongs to, rather than retain no longer used replication in any sort of global
state. It should be enough to restore a state by re-playing previous events
from the history.

**Advantages of Aftermath**

- Separation of concerns
- Code reusability
- Unidirectional data flow
- Type safety

**Disadvantages of **Aftermath**

- No state
- Async command handler could confuse the flow
- Focusing on command output instead of actual data

## Installation

**Aftermath** is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'Aftermath'
```

**Aftermath** is also available through [Carthage](https://github.com/Carthage/Carthage).
To install just write into your Cartfile:

```ruby
github "hyperoslo/Aftermath"
```

**Aftermath** can also be installed manually. Just download and drop `Sources`
folders in your project.

## Examples

- [iOS Playground](https://github.com/hyperoslo/Aftermath/blob/master/Playground-iOS.playground/Content.swift)
uses live view of interactive playground to show how to fetch data from network
and display it in the `UITableView`.

- [AftermathNotes](https://github.com/hyperoslo/Aftermath/blob/master/Example/AftermathNotes)
is a simple application that demonstrates how to setup networking stack and
data cache layer using **Aftermath**. It uses the concept of `stories` to group
related types and make the `command -> event` flow more readable.

- [AftermathNotesPlus](https://github.com/hyperoslo/Aftermath/blob/master/Example/AftermathNotes)
is a more advanced example that extends [AftermathNotes](https://github.com/hyperoslo/Aftermath/blob/master/Example/AftermathNotes)
demo. It plays with generics and introduces the concept of `features` in order
to reuse view controllers and RESTful network requests.

## Extensions

This repository aims to be the core implementation of framework, but there are
also a range of extensions that integrate **Aftermath** with other libraries
and extend it with more features:

- [AftermathTools](https://github.com/hyperoslo/AftermathTools) is a set of
development tools for **Aftermath** where you can find additional helpers,
useful command and event middleware for logging, error handling, etc.

- [AftermathCompass](https://github.com/hyperoslo/AftermathCompass) is a
message-driven routing system built on top of **Aftermath** and
[Compass](https://github.com/hyperoslo/Compass).

- [AftermathSpots](https://github.com/hyperoslo/AftermathSpots) is made to
improve development routines of building component-based UIs using
[Spots](https://github.com/hyperoslo/Spots) cross-platform view controller
framework. It comes with custom reactions and injectable behaviors that move
code reusability to the next level and make your application even more
decoupled and flexible.

## Alternatives

Still not sure about state management? Yeah, it's not that easy to find a
silver bullet for all occasions and cover all scenarios. The are some links
that for further reading and research:

- [ReSwift](https://github.com/ReSwift/ReSwift) - Unidirectional Data Flow in
Swift, inspired by Redux.

- [SwiftFlux](https://github.com/yonekawa/SwiftFlux) - A type-safe Flux
implementation in Swift.

- [fantastic-ios-architecture](https://github.com/onmyway133/fantastic-ios-architecture)
- A list of resources related to iOS architecture topic.

## Author

Hyper Interaktiv AS, ios@hyper.no

## Influences

**Aftermath** is inspired by the idea of unidirectional data flow in
[Flux](https://facebook.github.io/flux/) and utilizes some concepts like
sequence of commands and events from
[Event Sourcing](http://martinfowler.com/eaaDev/EventSourcing.html).

## Contributing

We would love you to contribute to **Aftermath**, check the [CONTRIBUTING](https://github.com/hyperoslo/Aftermath/blob/master/CONTRIBUTING.md)
file for more info.

## License

**Aftermath** is available under the MIT license. See the [LICENSE](https://github.com/hyperoslo/Aftermath/blob/master/LICENSE.md)
file for more info.
