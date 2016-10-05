import XCTest
@testable import Aftermath

class ReactionDisposerTests: XCTestCase {

  var disposer: ReactionDisposer!
  var producer: Controller!
  var eventBus: EventBus!

  override func setUp() {
    super.setUp()

    eventBus = EventBus()
    disposer = ReactionDisposer(eventBus: eventBus)
    producer = Controller()
  }

  override func tearDown() {
    super.tearDown()
  }

  // MARK: - Tests

  func testInit() {
    XCTAssertTrue(disposer.tokens.isEmpty)
  }

  func testAppend() {
    disposer.append("token1", from: producer)
    XCTAssertEqual(disposer.tokens.count, 1)
    XCTAssertEqual(disposer.tokens[Controller.identifier]?.count, 1)

    disposer.append("token1", from: producer)
    XCTAssertEqual(disposer.tokens.count, 1)
    XCTAssertEqual(disposer.tokens[Controller.identifier]?.count, 1)

    disposer.append("token2", from: producer)
    XCTAssertEqual(disposer.tokens.count, 1)
    XCTAssertEqual(disposer.tokens[Controller.identifier]?.count, 2)

    disposer.append("token2", from: TestReactionProducer())
    XCTAssertEqual(disposer.tokens.count, 2)
    XCTAssertEqual(disposer.tokens[Controller.identifier]?.count, 2)
    XCTAssertEqual(disposer.tokens[TestReactionProducer.identifier]?.count, 1)
  }

  func testDispose() {
    disposer.append("token1", from: producer)
    disposer.append("token2", from: producer)
    disposer.dispose(token: "token1", from: producer)

    XCTAssertEqual(disposer.tokens.count, 1)
    XCTAssertEqual(disposer.tokens[Controller.identifier]?.count, 1)
  }

  func testDisposeAllFromProducer() {
    disposer.append("token1", from: producer)
    disposer.append("token2", from: producer)
    disposer.append("token2", from: TestReactionProducer())
    disposer.disposeAll(from: producer)

    XCTAssertEqual(disposer.tokens.count, 1)
    XCTAssertNil(disposer.tokens[Controller.identifier])
    XCTAssertEqual(disposer.tokens[TestReactionProducer.identifier]?.count, 1)
  }

  func testDisposeAll() {
    disposer.append("token1", from: producer)
    disposer.append("token2", from: producer)
    disposer.append("token2", from: TestReactionProducer())
    disposer.disposeAll()

    XCTAssertEqual(disposer.tokens.count, 0)
  }
}
