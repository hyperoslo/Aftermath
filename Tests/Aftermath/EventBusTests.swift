import XCTest
@testable import Aftermath

class EventBusTests: XCTestCase {

  var eventBus: EventBus!
  var errorHandler: ErrorManager!
  var reaction: Reaction<Calculator>!
  var listener: (Event<AdditionCommand> -> Void)!
  var state: State?
  var lastError: ErrorType?

  override func setUp() {
    super.setUp()

    eventBus = EventBus()
    errorHandler = ErrorManager()
    eventBus.errorHandler = errorHandler

    reaction = Reaction(
      wait: {
        self.state = .Progress
      },
      consume: { result in
        self.state = .Data
      },
      rescue: { error in
        self.state = .Error
        self.lastError = error
      }
    )

    listener = { event in
      self.reaction.invoke(with: event)
    }

    state = nil
    lastError = nil
  }

  override func tearDown() {
    super.tearDown()
    eventBus.disposeAll()
  }

  // MARK: - Tests

  func testListen() {
    XCTAssertEqual(eventBus.listeners.count, 0)

    eventBus.listen(to: AdditionCommand.self, listener: listener)
    XCTAssertEqual(eventBus.listeners.count, 1)

    eventBus.listen(to: AdditionCommand.self, listener: listener)
    XCTAssertEqual(eventBus.listeners.count, 2)
  }

  func testPublish() {
    let token = eventBus.listen(to: AdditionCommand.self, listener: listener)
    XCTAssertEqual(eventBus.listeners[token]?.status, .Pending)

    eventBus.publish(Event<AdditionCommand>.Progress)
    XCTAssertEqual(eventBus.listeners[token]?.status, .Issued)
    XCTAssertEqual(state, .Progress)
  }

  func testPublishWithoutListeners() {
    let token = eventBus.listen(to: AdditionCommand.self, listener: listener)
    XCTAssertEqual(eventBus.listeners[token]?.status, .Pending)

    eventBus.publish(Event<TestCommand>.Progress)
    XCTAssertEqual(eventBus.listeners[token]?.status, .Pending)
    XCTAssertNil(state)

    if let error = errorHandler.lastError as? Warning {
      switch error {
      case .NoEventListeners(let event):
        XCTAssertTrue(event is Event<TestCommand>)
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

    let token = eventBus.listen(to: AdditionCommand.self, listener: listener)
    XCTAssertEqual(eventBus.listeners[token]?.status, .Pending)

    eventBus.middlewares.append(middleware)
    eventBus.publish(Event<AdditionCommand>.Progress)

    XCTAssertEqual(eventBus.listeners[token]?.status, .Issued)
    XCTAssertEqual(state, .Progress)
    XCTAssertTrue(executed)
  }

  func testPerform() {
    let token = eventBus.listen(to: AdditionCommand.self, listener: listener)
    XCTAssertEqual(eventBus.listeners[token]?.status, .Pending)

    do {
      try eventBus.perform(Event<AdditionCommand>.Progress)
      XCTAssertEqual(eventBus.listeners[token]?.status, .Issued)
      XCTAssertEqual(state, .Progress)
    } catch {
      XCTFail("Event bus perform failed with error: \(error)")
    }
  }

  func testPerformWithoutListeners() {
    let token = eventBus.listen(to: AdditionCommand.self, listener: listener)
    XCTAssertEqual(eventBus.listeners[token]?.status, .Pending)

    do {
      try eventBus.perform(Event<TestCommand>.Progress)
      XCTFail("Perform may fail with error")
    } catch {
      XCTAssertEqual(eventBus.listeners[token]?.status, .Pending)
      XCTAssertNil(state)
      XCTAssertNil(errorHandler.lastError)

      if let error = error as? Warning {
        switch error {
        case .NoEventListeners(let event):
          XCTAssertTrue(event is Event<TestCommand>)
        default:
          XCTFail("Invalid error was thrown: \(error)")
        }
      } else {
        XCTFail("Invalid error was thrown: \(error)")
      }
    }
  }

  func testHandleError() {
    eventBus.listen(to: AdditionCommand.self, listener: listener)
    eventBus.handleError(TestError.Test, on: Event<AdditionCommand>.Progress)
    XCTAssertEqual(state, .Error)
    XCTAssertTrue(lastError is TestError)
  }

  func testHandleErrorWithFrameworkError() {
    eventBus.listen(to: AdditionCommand.self, listener: listener)
    eventBus.handleError(Error.InvalidEventType, on: Event<AdditionCommand>.Progress)
    XCTAssertNil(state)
    XCTAssertNil(lastError)
  }
}
