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
    Engine.shared.invalidate()
  }

  // MARK: - Tests

  func testReactToWithProgress() {
    controller.react(to: AdditionCommand.self, with: controller.reaction)
    XCTAssertEqual((Engine.shared.eventBus as? EventBus)?.listeners.count, 1)
    XCTAssertEqual(Engine.shared.reactionDisposer.tokens[Controller.identifier]?.count, 1)

    let event = Event<AdditionCommand>.progress
    Engine.shared.eventBus.publish(event: event)

    XCTAssertEqual(controller.state, .progress)
  }

  func testReactToWithData() {
    controller.react(to: AdditionCommand.self, with: controller.reaction)
    XCTAssertEqual((Engine.shared.eventBus as? EventBus)?.listeners.count, 1)
    XCTAssertEqual(Engine.shared.reactionDisposer.tokens[Controller.identifier]?.count, 1)

    let event = Event<AdditionCommand>.data(Calculator(result: 11))
    Engine.shared.eventBus.publish(event: event)

    XCTAssertEqual(controller.state, .data)
  }

  func testReactToWithError() {
    controller.react(to: AdditionCommand.self, with: controller.reaction)
    XCTAssertEqual((Engine.shared.eventBus as? EventBus)?.listeners.count, 1)
    XCTAssertEqual(Engine.shared.reactionDisposer.tokens[Controller.identifier]?.count, 1)

    let event = Event<AdditionCommand>.error(TestError.test)
    Engine.shared.eventBus.publish(event: event)

    XCTAssertEqual(controller.state, .error)
  }

  func testDisposeToken() {
    let token = controller.react(to: AdditionCommand.self, with: controller.reaction)
    XCTAssertEqual((Engine.shared.eventBus as? EventBus)?.listeners.count, 1)
    XCTAssertEqual(Engine.shared.reactionDisposer.tokens[Controller.identifier]?.count, 1)

    controller.dispose(token: token)
    XCTAssertEqual((Engine.shared.eventBus as? EventBus)?.listeners.count, 0)
    XCTAssertNil(Engine.shared.reactionDisposer.tokens[Controller.identifier])
  }

  func testDisposeAll() {
    controller.react(to: AdditionCommand.self, with: controller.reaction)
    XCTAssertEqual((Engine.shared.eventBus as? EventBus)?.listeners.count, 1)
    XCTAssertEqual(Engine.shared.reactionDisposer.tokens[Controller.identifier]?.count, 1)

    controller.disposeAll()
    XCTAssertEqual((Engine.shared.eventBus as? EventBus)?.listeners.count, 0)
    XCTAssertNil(Engine.shared.reactionDisposer.tokens[Controller.identifier])
  }
}
