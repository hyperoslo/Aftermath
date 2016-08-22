import XCTest
@testable import Uniflow

class EventBusTests: XCTestCase {

  var eventBus: EventBus!
  var errorHandler: ErrorManager!
  var reaction: Reaction<Calculator>!
  var listener: (Event<Calculator> -> Void)!
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

    listener = { event in
      self.reaction.invoke(with: event)
    }
  }

  override func tearDown() {
    super.tearDown()
    eventBus.disposeAll()
  }

  // MARK: - Tests

  func testListen() {
    XCTAssertEqual(eventBus.listeners.count, 0)

    eventBus.listen(listener)
    XCTAssertEqual(eventBus.listeners.count, 1)

    eventBus.listen(listener)
    XCTAssertEqual(eventBus.listeners.count, 2)
  }

  func testPublish() {
    let token = eventBus.listen(listener)
    XCTAssertEqual(eventBus.listeners[token]?.status, .Pending)

    eventBus.publish(Event<Calculator>.Progress)
    XCTAssertEqual(eventBus.listeners[token]?.status, .Issued)
    XCTAssertEqual(state, .Progress)
  }

  func testPublishWithoutListeners() {
    let token = eventBus.listen(listener)
    XCTAssertEqual(eventBus.listeners[token]?.status, .Pending)

    eventBus.publish(Event<String>.Progress)
    XCTAssertEqual(eventBus.listeners[token]?.status, .Pending)
    XCTAssertNil(state)

    if let error = errorHandler.lastError as? Warning {
      switch error {
      case .NoEventListeners(let event):
        XCTAssertTrue(event is Event<String>)
      default:
        XCTFail("Invalid error was thrown: \(error)")
      }
    } else {
      XCTFail("No event listeners warning was thrown")
    }
  }

  func testPublishWithMiddleware() {
    var executed = false
    let middleware = LogEventMiddleware { _ in
      executed = true
    }

    let token = eventBus.listen(listener)
    XCTAssertEqual(eventBus.listeners[token]?.status, .Pending)

    eventBus.middlewares.append(middleware)
    eventBus.publish(Event<Calculator>.Progress)

    XCTAssertEqual(eventBus.listeners[token]?.status, .Issued)
    XCTAssertEqual(state, .Progress)
    XCTAssertTrue(executed)
  }

  func testPeform() {

  }

  func testHandleError() {

  }
}
