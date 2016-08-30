import XCTest
@testable import Aftermath

class ReactionProducerTests: XCTestCase {

  var controller: Controller!

  override func setUp() {
    super.setUp()
    controller = Controller()
  }

  override func tearDown() {
    super.tearDown()
    Engine.sharedInstance.invalidate()
  }

  // MARK: - Tests

  func testReactWithProgress() {
    controller.react(to: AdditionCommand.self, with: controller.reaction)
    XCTAssertEqual((Engine.sharedInstance.eventBus as? EventBus)?.listeners.count, 1)
    XCTAssertEqual(Engine.sharedInstance.reactionDisposer.tokens[Controller.identifier]?.count, 1)

    let event = Event<AdditionCommand>.Progress
    Engine.sharedInstance.eventBus.publish(event)

    XCTAssertEqual(controller.state, .Progress)
    XCTAssertFalse(controller.completed)
  }

  func testReactWithSuccess() {
    controller.react(to: AdditionCommand.self, with: controller.reaction)
    XCTAssertEqual((Engine.sharedInstance.eventBus as? EventBus)?.listeners.count, 1)
    XCTAssertEqual(Engine.sharedInstance.reactionDisposer.tokens[Controller.identifier]?.count, 1)

    let event = Event<AdditionCommand>.Success(Calculator(result: 11))
    Engine.sharedInstance.eventBus.publish(event)

    XCTAssertEqual(controller.state, .Success)
    XCTAssertTrue(controller.completed)
  }

  func testReactWithSuccessClosure() {
    controller.react(to: AdditionCommand.self, done: controller.reaction.done!)
    XCTAssertEqual((Engine.sharedInstance.eventBus as? EventBus)?.listeners.count, 1)
    XCTAssertEqual(Engine.sharedInstance.reactionDisposer.tokens[Controller.identifier]?.count, 1)

    let event = Event<AdditionCommand>.Success(Calculator(result: 11))
    Engine.sharedInstance.eventBus.publish(event)

    XCTAssertEqual(controller.state, .Success)
    XCTAssertFalse(controller.completed)
  }

  func testReactWithError() {
    controller.react(to: AdditionCommand.self, with: controller.reaction)
    XCTAssertEqual((Engine.sharedInstance.eventBus as? EventBus)?.listeners.count, 1)
    XCTAssertEqual(Engine.sharedInstance.reactionDisposer.tokens[Controller.identifier]?.count, 1)

    let event = Event<AdditionCommand>.Error(TestError.Test)
    Engine.sharedInstance.eventBus.publish(event)

    XCTAssertEqual(controller.state, .Error)
    XCTAssertTrue(controller.completed)
  }

  func testDispose() {
    let token = controller.react(to: AdditionCommand.self, with: controller.reaction)
    XCTAssertEqual((Engine.sharedInstance.eventBus as? EventBus)?.listeners.count, 1)
    XCTAssertEqual(Engine.sharedInstance.reactionDisposer.tokens[Controller.identifier]?.count, 1)

    controller.dispose(token)
    XCTAssertEqual((Engine.sharedInstance.eventBus as? EventBus)?.listeners.count, 0)
    XCTAssertNil(Engine.sharedInstance.reactionDisposer.tokens[Controller.identifier])
  }

  func testDisposeAll() {
    controller.react(to: AdditionCommand.self, with: controller.reaction)
    XCTAssertEqual((Engine.sharedInstance.eventBus as? EventBus)?.listeners.count, 1)
    XCTAssertEqual(Engine.sharedInstance.reactionDisposer.tokens[Controller.identifier]?.count, 1)

    controller.disposeAll()
    XCTAssertEqual((Engine.sharedInstance.eventBus as? EventBus)?.listeners.count, 0)
    XCTAssertNil(Engine.sharedInstance.reactionDisposer.tokens[Controller.identifier])
  }
}
