import XCTest
@testable import Uniflow

class CommandProducerTests: XCTestCase {

  var producer: CommandProducer!
  var commandHandler: TestCommandHandler!
  var executedCommand: TestCommand?

  override func setUp() {
    super.setUp()

    producer = Controller()
    executedCommand = nil
    commandHandler = TestCommandHandler { executedCommand in
      self.executedCommand = executedCommand
    }

    Engine.sharedInstance.use(commandHandler)
  }

  override func tearDown() {
    super.tearDown()
    Engine.sharedInstance.commandBus.disposeAll()
  }

  // MARK: - Tests

  func testExecute() {
    producer.execute(TestCommand())
    XCTAssertNotNil(executedCommand)
  }

  func testExecuteWithReaction() {
  }
}
