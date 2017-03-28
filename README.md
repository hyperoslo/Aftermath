⚠️ **DEPRECATED, NO LONGER MAINTAINED**

![Aftermath](https://github.com/hyperoslo/Aftermath/blob/master/Images/cover.png)

[![CI Status](http://img.shields.io/travis/hyperoslo/Aftermath.svg?style=flat)](https://travis-ci.org/hyperoslo/Aftermath)
[![Version](https://img.shields.io/cocoapods/v/Aftermath.svg?style=flat)](http://cocoadocs.org/docsets/Aftermath)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
![Swift](https://img.shields.io/badge/%20in-swift%203.0-orange.svg)
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

The following diagram demonstrates the data flow in **Aftermath** architecture
in details:

<div align="center">
<img src="https://github.com/hyperoslo/Aftermath/blob/master/Images/detailed_flow.png" />
</div><br/>

## Table of Contents

* [Core components](#core-components)
* [The flow](#the-flow)
* [Extra](#extra)
* [Engine](#engine)
* [Life hacks](#life-hacks)
* [Tools](#tools)
* [Summary](#summary)
* [Installation](#installation)
* [Examples](#examples)
* [Extensions](#extensions)
* [Alternatives](#alternatives)
* [Author](#author)
* [Influences](#influences)
* [Contributing](#contributing)
* [License](#License)

## Core components

### Command

**Command** is a message with a set of instructions describing an intention to
execute the corresponding behavior. Command could lead to data fetching,
data mutation and any sort of sync or async operation that
produces desirable output needed to update application/view state.

Every command can produce only one **Output** type.

### Command Handler

**Command Handler** layer is responsible for business logic in the application.
The submission of a command is received by a command handler, which usually
performs short- or long-term operation, such as network request, database query,
cache read/white process, etc. Command handler can be sync and publish the
result immediately. On the other hand it's the best place in the
application to write asynchronous code.

The restriction is to create only one command handler per command.

### Event

Command Handler is responsible for publishing **events** that will be
consumed by reactions. There are 3 types of events:

- `progress` event indicates that the operation triggered by command has been
started and is in the pending state at the moment.
- `data` event holds the output produced by the command execution.
- `error` notifies that an error has been occurred during the command
execution.

### Reaction

**Reaction** responds to event published by command handler. It is supposed
to handle 3 possible event types by describing the desired behavior in the
each scenario:

- `wait` function reacts on `progress` type of the event
- `consume` function reacts on `data` type of the event.
- `rescue` function is a fallback for the case when `error` event has been
received.

Normally reaction performs UI updates, but could also be used for other kinds
of output processing.

## The flow

Taking 4 core components described before, we can build a simplified version
of the data flow:

<div align="center">
<img src="https://github.com/hyperoslo/Aftermath/blob/master/Images/simplified_flow.png" />
</div><br/>

### Command execution

The first step is to declare a command. Your command type has to conform to the
`Aftermath.Command` protocol and the `Output` type must be implicitly specified.

Let's say we want to fetch a list of books from some untrusted resource and
correct typos in titles and author names 🤓.

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

**Note** that any type can play the role of `Output`, so if we want to add a
date to our `BookUpdateCommand` it could look like the following:

```swift
typealias Output = (Book, Date)
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

Command is an intention that needs to be translated into an action by a handler.
The command handler is responsible for publishing events to notify about results of
the operation it performs. The command handlers type has to conform to
`Aftermath.CommandHandler` protocol, that needs to know about the command type
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
    return Book.list.isEmpty ? Event.progress : Event.data(localBooks)
  }
}
```

**Note** that every command handler needs to be registered on
[Aftermath Engine](#engine).

```swift
Engine.shared.use(handler: BookListCommandHandler())
```

### Reacting to events

The last step, but not the least, is to react to events published by the command
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

  // ...
}
```

**It's important** to dispose all reaction tokens when your `ReactionProducer`
instance is about to be deallocated or reaction needs to be unsubscribed from
events.

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
is no need to register an action, it will be automatically added to the list of
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
    return Event.progress
  }
}

// Execute action

struct WelcomeManager: CommandProducer {

  func salute() {
    execute(action: WelcomeAction(userId: 11))
  }
}
```

### Fact

**Fact** works like notification, with no async operations involved. It can
be used when there is no need for a handler to generate an output. Fact is an
output itself, so the only thing you want to do is notify all
subscribers that something happened in the system, and they will react
accordingly. In this sense it's closer to a type-safe alternative to
`Notification`.

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

### Middleware

**Middleware** is a layer where commands and events can be intercepted before
they reach their listeners.

It means you can modify/cancel/extend the executed command in
**Command Middleware** before it's processed by the command handler:

<div align="center">
<img src="https://github.com/hyperoslo/Aftermath/blob/master/Images/command_middleware.png" />
</div><br/>

Or you can do appropriate operation in **Event Middleware** before the
published event is received by its reactions.

<div align="center">
<img src="https://github.com/hyperoslo/Aftermath/blob/master/Images/event_middleware.png" />
</div><br/>

It's handy for logging, crash reporting, aborting particular commands or
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

Engine.shared.pipeCommands(through: [ErrorCommandMiddleware()])

// Event middleware
struct LogEventMiddleware: EventMiddleware {

  // Don't forget to call `next` to invoke the next function in the chain.
  func intercept(event: AnyEvent, publish: Publish, next: Publish) throws {
    print("Event published -> \(event)")
    try next(event)
  }
}

Engine.shared.pipeEvents(through: [LogEventMiddleware()])
```

**Note** that it's necessary to call `next` to invoke the next function in the
chain while building your custom middleware.

`AnyCommand` and `AnyEvent` are special protocols that every `Command` or
`Event` conform to. They are used mostly in [middleware](#middleware) to
workaround restrictions of working with Swift generic protocols that have
`associatedtype`.

## Engine

**Engine** is the main entry point for **Aftermath** configuration:

- Register command handlers:

```swift
Engine.shared.use(handler: BookListCommandHandler())
```

- Add command and event middleware:

```swift
// Commands
Engine.shared.pipeCommands(through: [LogCommandMiddleware(), ErrorCommandMiddleware()])
// Events
Engine.shared.pipeEvents(through: [LogEventMiddleware(), ErrorEventMiddleware()])
```

- Set global error handler to catch all unexpected errors and framework
warnings:

```swift
struct EngineErrorHandler: ErrorHandler {

  func handleError(error: Error) {
    if let error = error as? Failure {
      print("Engine error -> \(error)")
    } else if let warning = error as? Warning {
      print("Engine warning -> \(warning)")
    } else {
      print("Unknown error -> \(error)")
    }
  }
}

Engine.shared.errorHandler = EngineErrorHandler()
```

- Dispose all registered command handlers and event listeners (reactions):

```swift
Engine.shared.invalidate()
```

## Life hacks

### Stories

Naming is hard. It doesn't feel right to have names like `BookListCommand`,
`BookListCommandHandler` and `BookListWhatever`, does it? If you agree, then
you can work around this issue by introducing a new idea into the mix.
You can group all related types into stories, which make the flow more concrete.

```swift
struct BookListStory {

  struct Command: Aftermath.Command {
    // ...
  }

  struct Handler: Aftermath.CommandHandler {
    // ...
  }
}
```

In this sense, it's close to user stories used in agile software development
methodologies.

You can find more detailed example in [AftermathNotes](https://github.com/hyperoslo/Aftermath/blob/master/Example/Aftermath)
demo project.

### Features

Some of the stories may seem very similar. Then in makes sense to make them
more generic and reusable according to the [DRY](https://en.wikipedia.org/wiki/Don%27t_repeat_yourself)
principle. For example, let's say we have the flow to fetch a single resource
by id.

```swift
import Aftermath
import Malibu

// Generic feature
protocol DetailFeature {
  associatedtype Model: Entity
  var resource: String { get }
}

// Command
struct DetailCommand<Feature: DetailFeature>: Aftermath.Command {
  typealias Output = Feature.Model
  let id: Int
}

// Command handler
struct DetailCommandHandler<Feature: DetailFeature>: Aftermath.CommandHandler {
  typealias Command = DetailCommand<Feature>

  let feature: Feature

  func handle(command: Command) throws -> Event<Command> {
    fetchDetail("\(feature.resource)/\(command.id)") { json, error in
      if let error = error {
        self.publish(error: error)
        return
      }

      do {
        self.publish(data: try Feature.Model(json))
      } catch {
        self.publish(error: error)
      }
    }

    return Event.progress
  }
}

// Concrete feature
struct BookFeature: ListFeature, DeleteFeature, CommandProducer {
  typealias Model = Todo
  var resource = "books"
}

// Execute command to load a single resource.
execute(command: DetailCommand<BookFeature>(id: id))

// Register reaction listener.
react(to: DetailCommand<BookFeature>.self, with: reaction)
```

You can find more detailed example in [AftermathNotesPlus](https://github.com/hyperoslo/Aftermath/blob/master/Example/AftermathNotes)
demo project.

## Summary

We believe that in iOS applications, in most of the cases, there is no real need
for single global state (single source of truth) or multiple sub-states
distributed between stores. Data is stored on disc in local persistence layer,
such as database and cache, or it's fetched from network. Then this content,
assembled piece by piece from different sources, is translated into the
"view state", which is readable by the view to render it on the screen. This
"view state" is kept in memory and valid at a given instant in time until we
switch the context and the current view is deallocated.

Keeping that in mind, it makes more sense to dispose the "view state" together
with the view it belongs to, rather than retain no longer used replication in
any sort of global state.

It should be enough to restore a state by re-playing previous events from the
history.

**Advantages of Aftermath**

- Separation of concerns
- Code reusability
- Unidirectional data flow
- Type safety

**Disadvantages of **Aftermath**

- No state (?)
- Focusing on command output instead of actual data
- Async command handler could confuse the flow

**P.S.** Even though **Aftermath** is a stateless framework at the moment, we
have plans to introduce some sort of optional store(s) for better state
management. It might be a new feature in v2, keep watching.

## Tools

- **Aftermath** comes with a set of development tools, such as additional
helpers, useful command and event middleware for logging, error handling, etc.

```swift
// Commands
Engine.sharedInstance.pipeCommands(through: [LogCommandMiddleware(), ErrorCommandMiddleware()])
// Events
Engine.sharedInstance.pipeEvents(through: [LogEventMiddleware(), ErrorEventMiddleware()])
```

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
data cache layer using **Aftermath**. It uses the concept of [stories](#stories)
to group related types and make the `command -> event` flow more readable.

- [AftermathNotesPlus](https://github.com/hyperoslo/Aftermath/blob/master/Example/AftermathNotes)
is a more advanced example that extends [AftermathNotes](https://github.com/hyperoslo/Aftermath/blob/master/Example/AftermathNotes)
demo. It plays with generics and introduces the concept of [features](#features)
in order to reuse view controllers and RESTful network requests.

## Extensions

This repository aims to be the core implementation of framework, but there are
also a range of extensions that integrate **Aftermath** with other libraries
and extend it with more features:

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

Still not sure about state management? It's not that easy to cover all
scenarios and find a silver bullet for all occasions. But if you think it's
time to break conventions and try new architecture in your next application,
there are some links for further reading and research:

- [ReSwift](https://github.com/ReSwift/ReSwift) - Unidirectional data flow in
Swift, inspired by [Redux](http://redux.js.org).

- [SwiftFlux](https://github.com/yonekawa/SwiftFlux) - A type-safe
[Flux](https://facebook.github.io/flux/) implementation in Swift.

- [fantastic-ios-architecture](https://github.com/onmyway133/fantastic-ios-architecture) -
A list of resources related to iOS architecture topic.

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
