import XCTest
@testable import Uniflow

class EventBusTests: XCTestCase {

  var eventBus: EventBus!
  var errorHandler: ErrorManager!
  var reaction: Reaction<Calculator>!
  var state: State?

  override func setUp() {
    super.setUp()

    eventBus = EventBus()
    errorHandler = ErrorManager()
    eventBus.errorHandler = errorHandler

    reaction = Reaction(
      progress: {
        self.state = .Progress
      },
      done: { result in
        self.state = .Success
      },
      fail: { error in
        self.state = .Error
    })
  }

  override func tearDown() {
    super.tearDown()
    eventBus.disposeAll()
  }

  // MARK: - Tests

  func testListen() {
    XCTAssertEqual(eventBus.listeners.count, 0)

    eventBus.listen { event in
      self.reaction.invoke(with: event)
    }
    
    XCTAssertEqual(eventBus.listeners.count, 1)
  }

  func testPublish() {

  }

  func testPeform() {

  }

  func testHandleError() {

  }
}
