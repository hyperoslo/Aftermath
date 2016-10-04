import XCTest
@testable import Aftermath

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
    Engine.sharedInstance.invalidate()
  }

  // MARK: - Tests

  func testExecute() {
    producer.execute(command: TestCommand())
    XCTAssertNotNil(executedCommand)
  }

  func testExecuteWithAnotherCommand() {
    producer.execute(command: AdditionCommand(value1: 1, value2: 3))
    XCTAssertNil(executedCommand)
  }

  func testExecuteAction() {
    var executedAction: TestAction?

    let action = TestAction(result: result) { action in
      executedAction = action
    }

    XCTAssertFalse(Engine.sharedInstance.commandBus.contains(handler: TestAction.self))

    producer.execute(action: action)
    XCTAssertTrue(Engine.sharedInstance.commandBus.contains(handler: TestAction.self))
    XCTAssertNotNil(executedAction)
  }

  func testExecuteReaction() {
    var string: String?

    producer.execute(command: TestCommand(), reaction: Reaction(
      consume: { result in
        string = result
      }))

    XCTAssertNotNil(executedCommand)
    XCTAssertEqual(string, result)
  }
}
