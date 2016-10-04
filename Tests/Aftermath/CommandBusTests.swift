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

  func testUse() {
    XCTAssertEqual(commandBus.listeners.count, 0)

    _ = commandBus.use(commandHandler)
    XCTAssertEqual(commandBus.listeners.count, 1)
  }

  func testUseWithDuplicate() {
    XCTAssertEqual(commandBus.listeners.count, 0)

    _ = commandBus.use(commandHandler)
    XCTAssertEqual(commandBus.listeners.count, 1)

    _ = commandBus.use(commandHandler)
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

  func testContains() {
    XCTAssertEqual(commandBus.listeners.count, 0)
    XCTAssertFalse(commandBus.contains(TestCommandHandler.self))

    _ = commandBus.use(commandHandler)
    XCTAssertTrue(commandBus.contains(TestCommandHandler.self))
  }

  func testExecute() {
    let token = commandBus.use(commandHandler)
    XCTAssertEqual(commandBus.listeners[token]?.status, .pending)

    commandBus.execute(TestCommand())
    XCTAssertEqual(commandBus.listeners[token]?.status, .issued)
    XCTAssertNotNil(executedCommand)
  }

  func testExecuteBuilder() {
    let token = commandBus.use(commandHandler)
    XCTAssertEqual(commandBus.listeners[token]?.status, .pending)

    commandBus.execute(TestCommandBuilder())
    XCTAssertEqual(commandBus.listeners[token]?.status, .issued)
    XCTAssertNotNil(executedCommand)
  }

  func testExecuteWithoutListeners() {
    let token = commandBus.use(commandHandler)
    XCTAssertEqual(commandBus.listeners[token]?.status, .pending)

    commandBus.execute(AdditionCommand(value1: 1, value2: 3))
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

  func testExecuteWithMiddleware() {
    var executed = false
    let middleware = LogCommandMiddleware { _ in
      executed = true
    }

    let token = commandBus.use(commandHandler)
    XCTAssertEqual(commandBus.listeners[token]?.status, .pending)

    commandBus.middlewares.append(middleware)
    commandBus.execute(TestCommand())

    XCTAssertEqual(commandBus.listeners[token]?.status, .issued)
    XCTAssertNotNil(executedCommand)
    XCTAssertTrue(executed)
  }

  func testPerform() {
    let token = commandBus.use(commandHandler)
    XCTAssertEqual(commandBus.listeners[token]?.status, .pending)

    do {
      try commandBus.perform(TestCommand())
      XCTAssertEqual(commandBus.listeners[token]?.status, .issued)
      XCTAssertNotNil(executedCommand)
    } catch {
      XCTFail("Command bus perform failed with error: \(error)")
    }
  }

  func testPerformWithoutListeners() {
    let token = commandBus.use(commandHandler)
    XCTAssertEqual(commandBus.listeners[token]?.status, .pending)

    do {
      try commandBus.perform(AdditionCommand(value1: 1, value2: 3))
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

    commandBus.handleError(TestError.test, on: TestCommand())
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

    commandBus.handleError(Failure.invalidCommandType, on: TestCommand())
    XCTAssertNil(reactionError)
  }
}
