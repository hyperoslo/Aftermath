import XCTest
@testable import Uniflow

class CommandProducerTests: XCTestCase {

  var producer: Controller!
  var commandHandler: TestCommandHandler!
  var executedCommand: TestCommand?
  let result = "test"

  override func setUp() {
    super.setUp()

    producer = Controller()
    executedCommand = nil
    commandHandler = TestCommandHandler(result: result) { executedCommand in
      self.executedCommand = executedCommand
    }

    Engine.sharedInstance.use(commandHandler)
  }

  override func tearDown() {
    super.tearDown()
    Engine.sharedInstance.commandBus.disposeAll()
    Engine.sharedInstance.eventBus.disposeAll()
  }

  // MARK: - Tests

  func testExecute() {
    producer.execute(TestCommand())
    XCTAssertNotNil(executedCommand)
  }

  func testExecuteWithAnotherCommand() {
    producer.execute(AdditionCommand(value1: 1, value2: 3))
    XCTAssertNil(executedCommand)
  }

  func testExecuteReaction() {
    var string: String?

    producer.execute(TestCommand(), reaction: Reaction(
      done: { result in
        string = result
      }))

    XCTAssertNotNil(executedCommand)
    XCTAssertEqual(string, result)
  }
}
