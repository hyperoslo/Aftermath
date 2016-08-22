import XCTest
@testable import Uniflow

class CommandBusTests: XCTestCase {

  var bus: CommandBus!

  override func setUp() {
    super.setUp()
  }

  override func tearDown() {
    super.tearDown()
    Engine.sharedInstance.commandBus.disposeAll()
    Engine.sharedInstance.eventBus.disposeAll()
  }

  // MARK: - Tests
}
