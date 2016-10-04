@testable import Aftermath

// MARK: - Commands

struct TestCommand: Command {
  typealias Output = String
}

struct SubtractionCommand: Command {
  typealias Output = Calculator

  let value1: Int
  let value2: Int
}

struct AdditionCommand: Command {
  typealias Output = Calculator

  let value1: Int
  let value2: Int
}

struct TestCommandBuilder: CommandBuilder {

  func buildCommand() throws -> AnyCommand {
    return TestCommand()
  }
}

struct TestAction: Action {
  typealias Output = String

  let result: String
  var callback: ((TestAction) -> Void)?

  init(result: String = "", callback: ((TestAction) -> Void)? = nil) {
    self.result = result
    self.callback = callback
  }

  func handle(_ command: TestAction) throws -> Event<TestAction> {
    callback?(command)
    return Event.data(result)
  }
}

struct TestFact: Fact {
  let result: String
}

// MARK: - Command handlers

struct TestCommandHandler: CommandHandler {

  let result: String
  var callback: ((TestCommand) -> Void)?

  init(result: String = "", callback: ((TestCommand) -> Void)? = nil) {
    self.result = result
    self.callback = callback
  }

  func handle(_ command: TestCommand) throws -> Event<TestCommand> {
    callback?(command)
    return Event.data(result)
  }
}

struct AdditionCommandHandler: CommandHandler {

  var callback: ((AnyCommand) -> Void)?

  init(result: String = "", callback: ((AnyCommand) -> Void)? = nil) {
    self.callback = callback
  }

  func handle(_ command: AdditionCommand) throws -> Event<AdditionCommand> {
    callback?(command)
    return Event.data(Calculator(result: command.value1 + command.value2))
  }
}

struct SubtractionCommandHandler: CommandHandler {

  var callback: ((AnyCommand) -> Void)?

  init(result: String = "", callback: ((AnyCommand) -> Void)? = nil) {
    self.callback = callback
  }

  func handle(_ command: SubtractionCommand) throws -> Event<SubtractionCommand> {
    callback?(command)
    return Event.data(Calculator(result: command.value1 - command.value2))
  }
}

// MARK: - Command middleware

struct LogCommandMiddleware: CommandMiddleware {

  var callback: ((AnyCommand) -> Void)?

  func intercept(_ command: AnyCommand, execute: Execute, next: Execute) throws {
    callback?(command)
    try next(command)
  }
}

struct AbortCommandMiddleware: CommandMiddleware {

  var callback: ((AnyCommand) -> Void)?

  func intercept(_ command: AnyCommand, execute: Execute, next: Execute) throws {
    callback?(command)
  }
}

struct AdditionCommandMiddleware: CommandMiddleware {

  var callback: ((AnyCommand) -> Void)?

  func intercept(_ command: AnyCommand, execute: Execute, next: Execute) throws {
    callback?(command)

    switch command {
    case let command as SubtractionCommand:
      try execute(AdditionCommand(value1: command.value1, value2: command.value2))
    default:
      try next(command)
    }
  }
}
