@testable import Uniflow

// MARK: - Commands

struct Calculator: Projection {
  let result: Int
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

  func intercept(command: AnyEvent, execute: Publish, next: Publish) throws {
    callback?(command)
    try next(command)
  }
}
