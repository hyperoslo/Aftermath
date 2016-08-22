import XCTest
@testable import Uniflow

class ReactionProducerTests: XCTestCase {

  var controller: Controller!

  override func setUp() {
    super.setUp()
    controller = Controller()
  }

  override func tearDown() {
    super.tearDown()
    Engine.sharedInstance.eventBus.disposeAll()
  }

  // MARK: - Tests

  func testReactWithProgress() {
    controller.react(controller.reaction)
    let event = Event<Calculator>.Progress
    Engine.sharedInstance.eventBus.publish(event)

    XCTAssertEqual(controller.state, .Progress)
  }

  func testReactWithSuccess() {
    controller.react(controller.reaction)
    let event = Event<Calculator>.Success(Calculator(result: 11))
    Engine.sharedInstance.eventBus.publish(event)

    XCTAssertEqual(controller.state, .Success)
  }

  func testReactWithError() {
    controller.react(controller.reaction)
    let event = Event<Calculator>.Error(TestError.Test)
    Engine.sharedInstance.eventBus.publish(event)

    XCTAssertEqual(controller.state, .Error)
  }
}
