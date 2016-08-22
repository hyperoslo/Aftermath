import XCTest
@testable import Uniflow

class CommandBusTests: XCTestCase {

  var commandBus: CommandBus!
  var eventBus: EventBus!
  var errorHandler: ErrorManager!
  var commandHandler: TestCommandHandler!
  var executedCommand: TestCommand?

  override func setUp() {
    super.setUp()

    eventBus = EventBus()
    errorHandler = ErrorManager()
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
  }

  // MARK: - Tests

  func testUse() {
    XCTAssertEqual(commandBus.listeners.count, 0)

    commandBus.use(commandHandler)
    XCTAssertEqual(commandBus.listeners.count, 1)
  }

  func testUseWithDuplicate() {
    XCTAssertEqual(commandBus.listeners.count, 0)

    commandBus.use(commandHandler)
    XCTAssertEqual(commandBus.listeners.count, 1)

    commandBus.use(commandHandler)
    XCTAssertEqual(commandBus.listeners.count, 1)

    if let error = errorHandler.lastError as? Warning {
      switch error {
      case .DuplicatedCommandHandler(let command):
        XCTAssertTrue(command == TestCommand.self)
      default:
        XCTFail("Invalid error was thrown: \(error)")
      }
    } else {
      XCTFail("Duplicated command warning wasnt's thrown")
    }
  }

  func testExecute() {

  }

  func testPerform() {
    let token = commandBus.use(commandHandler)
    XCTAssertEqual(commandBus.listeners[token]?.status, .Pending)

    commandBus.execute(TestCommand())
    XCTAssertEqual(commandBus.listeners[token]?.status, .Issued)
    XCTAssertNotNil(executedCommand)
  }

  func testPerformWithoutListeners() {
    let token = commandBus.use(commandHandler)
    XCTAssertEqual(commandBus.listeners[token]?.status, .Pending)

    commandBus.execute(AdditionCommand(value1: 1, value2: 3))
    XCTAssertEqual(commandBus.listeners[token]?.status, .Pending)
    XCTAssertNil(executedCommand)

    if let error = errorHandler.lastError as? Warning {
      switch error {
      case .NoCommandHandlers(let command):
        XCTAssertTrue(command is AdditionCommand)
      default:
        XCTFail("Invalid error was thrown: \(error)")
      }
    } else {
      XCTFail("No command handlers warning wasnt's thrown")
    }
  }

  func testHandleError() {

  }
}
