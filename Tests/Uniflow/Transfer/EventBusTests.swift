import XCTest
@testable import Uniflow

class EventBusTests: XCTestCase {

  var bus: EventBus!

  override func setUp() {
    super.setUp()
  }

  override func tearDown() {
    super.tearDown()
    Engine.sharedInstance.commandBus.disposeAll()
    Engine.sharedInstance.eventBus.disposeAll()
  }

  // MARK: - Tests

  func testListen() {

  }

  func testPublish() {

  }

  func testPeform() {

  }

  func testHandleError() {

  }
}
