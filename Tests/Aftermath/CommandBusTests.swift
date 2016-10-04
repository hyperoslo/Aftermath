import XCTest
@testable import Aftermath

class CommandBusTests: XCTestCase {

  var commandBus: CommandBus!
  var eventBus: EventBus!
  var errorHandler: ErrorManager!
  var commandHandler: TestCommandHandler!
  var controller: Controller!
  var executedCommand: TestCommand?

  override func setUp() {
    super.setUp()

    eventBus = EventBus()
    errorHandler = ErrorManager()
    controller = Controller()
    commandBus = CommandBus(eventDispatcher: eventBus)
    commandBus.errorHandler = errorHandler

    commandHandler = TestCommandHandler() { executedCommand in
      self.executedCommand = executedCommand
    }

    executedCommand = nil
  }

  override func tearDown() {
    super.tearDown()
    commandBus.disposeAll()
    eventBus.disposeAll()
  }

  // MARK: - Tests

  func testUseHandler() {
    XCTAssertEqual(commandBus.listeners.count, 0)

    _ = commandBus.use(handler: commandHandler)
    XCTAssertEqual(commandBus.listeners.count, 1)
  }

  func testUseHandlerWithDuplicate() {
    XCTAssertEqual(commandBus.listeners.count, 0)

    _ = commandBus.use(handler: commandHandler)
    XCTAssertEqual(commandBus.listeners.count, 1)

    _ = commandBus.use(handler: commandHandler)
    XCTAssertEqual(commandBus.listeners.count, 1)

    if let error = errorHandler.lastError as? Warning {
      switch error {
      case .duplicatedCommandHandler(let command):
        XCTAssertTrue(command == TestCommand.self)
      default:
        XCTFail("Invalid error was thrown: \(error)")
      }
    } else {
      XCTFail("No duplicated command warning was thrown")
    }
  }

  func testContainsHandler() {
    XCTAssertEqual(commandBus.listeners.count, 0)
    XCTAssertFalse(commandBus.contains(handler: TestCommandHandler.self))

    _ = commandBus.use(handler: commandHandler)
    XCTAssertTrue(commandBus.contains(handler: TestCommandHandler.self))
  }

  func testExecuteCommand() {
    let token = commandBus.use(handler: commandHandler)
    XCTAssertEqual(commandBus.listeners[token]?.status, .pending)

    commandBus.execute(command: TestCommand())
    XCTAssertEqual(commandBus.listeners[token]?.status, .issued)
    XCTAssertNotNil(executedCommand)
  }

  func testExecuteBuilder() {
    let token = commandBus.use(handler: commandHandler)
    XCTAssertEqual(commandBus.listeners[token]?.status, .pending)

    commandBus.execute(builder: TestCommandBuilder())
    XCTAssertEqual(commandBus.listeners[token]?.status, .issued)
    XCTAssertNotNil(executedCommand)
  }

  func testExecuteCommandWithoutListeners() {
    let token = commandBus.use(handler: commandHandler)
    XCTAssertEqual(commandBus.listeners[token]?.status, .pending)

    commandBus.execute(command: AdditionCommand(value1: 1, value2: 3))
    XCTAssertEqual(commandBus.listeners[token]?.status, .pending)
    XCTAssertNil(executedCommand)

    if let error = errorHandler.lastError as? Warning {
      switch error {
      case .noCommandHandlers(let command):
        XCTAssertTrue(command is AdditionCommand)
      default:
        XCTFail("Invalid error was thrown: \(error)")
      }
    } else {
      XCTFail("No command handlers warning was thrown")
    }
  }

  func testExecuteCommandWithMiddleware() {
    var executed = false
    let middleware = LogCommandMiddleware { _ in
      executed = true
    }

    let token = commandBus.use(handler: commandHandler)
    XCTAssertEqual(commandBus.listeners[token]?.status, .pending)

    commandBus.middlewares.append(middleware)
    commandBus.execute(command: TestCommand())

    XCTAssertEqual(commandBus.listeners[token]?.status, .issued)
    XCTAssertNotNil(executedCommand)
    XCTAssertTrue(executed)
  }

  func testPerformCommand() {
    let token = commandBus.use(handler: commandHandler)
    XCTAssertEqual(commandBus.listeners[token]?.status, .pending)

    do {
      try commandBus.perform(command: TestCommand())
      XCTAssertEqual(commandBus.listeners[token]?.status, .issued)
      XCTAssertNotNil(executedCommand)
    } catch {
      XCTFail("Command bus perform failed with error: \(error)")
    }
  }

  func testPerformCommandWithoutListeners() {
    let token = commandBus.use(handler: commandHandler)
    XCTAssertEqual(commandBus.listeners[token]?.status, .pending)

    do {
      try commandBus.perform(command: AdditionCommand(value1: 1, value2: 3))
      XCTFail("Perform may fail with error")
    } catch {
      XCTAssertEqual(commandBus.listeners[token]?.status, .pending)
      XCTAssertNil(executedCommand)
      XCTAssertNil(errorHandler.lastError)

      if let error = error as? Warning {
        switch error {
        case .noCommandHandlers(let command):
          XCTAssertTrue(command is AdditionCommand)
        default:
          XCTFail("Invalid error was thrown: \(error)")
        }
      } else {
        XCTFail("Invalid error was thrown: \(error)")
      }
    }
  }

  func testHandleError() {
    var reactionError: Error?

    _ = eventBus.listen(to: TestCommand.self) { event in
      let reaction = Reaction<String>(rescue: { error in
        reactionError = error
      })

      reaction.invoke(with: event)
    }

    commandBus.handle(error: TestError.test, on: TestCommand())
    XCTAssertTrue(reactionError is TestError)
  }

  func testHandleErrorWithFrameworkError() {
    var reactionError: Error?

    _ = eventBus.listen(to: TestCommand.self) { event in
      let reaction = Reaction<String>(rescue: { error in
        reactionError = error
      })

      reaction.invoke(with: event)
    }

    commandBus.handle(error: Failure.invalidCommandType, on: TestCommand())
    XCTAssertNil(reactionError)
  }
}
