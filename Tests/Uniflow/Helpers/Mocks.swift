@testable import Uniflow

extension String: Projection {}

struct Calculator: Projection {
  let result: Int
}

enum State: Int {
  case Progress, Success, Error
}

enum TestError: ErrorType {
  case Test
}

// MARK: - Commands

struct TestCommand: Command {
  typealias ProjectionType = Calculator
}

struct SubtractionCommand: Command {
  typealias ProjectionType = Calculator

  let value1: Int
  let value2: Int
}

struct AdditionCommand: Command {
  typealias ProjectionType = Calculator

  let value1: Int
  let value2: Int
}

// MARK: - Command middleware

struct LogCommandMiddleware: CommandMiddleware {

  var callback: (AnyCommand -> Void)?

  func intercept(command: AnyCommand, execute: Execute, next: Execute) throws {
    callback?(command)
    try next(command)
  }
}

struct AbortCommandMiddleware: CommandMiddleware {

  var callback: (AnyCommand -> Void)?

  func intercept(command: AnyCommand, execute: Execute, next: Execute) throws {
    callback?(command)
  }
}

struct AdditionCommandMiddleware: CommandMiddleware {

  var callback: (AnyCommand -> Void)?

  func intercept(command: AnyCommand, execute: Execute, next: Execute) throws {
    callback?(command)

    switch command {
    case let command as SubtractionCommand:
      try execute(AdditionCommand(value1: command.value1, value2: command.value2))
    default:
      try next(command)
    }
  }
}

// MARK: - Event middleware

struct LogEventMiddleware: EventMiddleware {

  var callback: (AnyEvent -> Void)?

  func intercept(event: AnyEvent, publish: Publish, next: Publish) throws {
    callback?(event)
    try next(event)
  }
}

struct AbortEventMiddleware: EventMiddleware {

  var callback: (AnyEvent -> Void)?

  func intercept(command: AnyEvent, publish: Publish, next: Publish) throws {
    callback?(command)
  }
}

struct ErrorEventMiddleware: EventMiddleware {

  var callback: (AnyEvent -> Void)?

  func intercept(event: AnyEvent, publish: Publish, next: Publish) throws {
    callback?(event)

    guard let calcEvent = event as? Event<Calculator> else {
      try next(event)
      return
    }

    switch calcEvent {
    case .Success:
      try publish(Event<Calculator>.Error(TestError.Test))
    default:
      try next(event)
    }
  }
}

// MARK: - Reactions

class Controller: ReactionProducer {

  var reaction: Reaction<Calculator>!
  var state: State?

  init() {
    reaction = Reaction(
      progress: {
        self.state = .Progress
      },
      done: { result in
        self.state = .Success
      },
      fail: { error in
        self.state = .Error
    })
  }
}
