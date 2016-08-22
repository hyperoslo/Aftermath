import XCTest
@testable import Aftermath

class CommandHandlerTests: XCTestCase {

  var commandHandler: TestCommandHandler!
  var controller: Controller!
  var executed =  false

  override func setUp() {
    super.setUp()

    commandHandler = TestCommandHandler()
    controller = Controller()
    executed = false
    Engine.sharedInstance.use(commandHandler)
  }

  override func tearDown() {
    super.tearDown()
    Engine.sharedInstance.commandBus.disposeAll()
    Engine.sharedInstance.eventBus.disposeAll()
  }

  // MARK: - Tests

  func testPublish() {
    controller.react(Reaction<String>(progress: { self.executed = true }))

    XCTAssertFalse(executed)
    commandHandler.publish(Event.Progress)
    XCTAssertTrue(executed)
  }
}
