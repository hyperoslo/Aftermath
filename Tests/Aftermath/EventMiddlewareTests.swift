import XCTest
@testable import Aftermath

class EventMiddlewareTests: XCTestCase, EventStepAsserting {

  var eventSteps: [EventStep] = []
  var eventBus: EventBus!
  var reaction: Reaction<Calculator>!
  var listener: ((Event<AdditionCommand>) -> Void)!
  var result = 0
  var error: Error?

  override func setUp() {
    super.setUp()

    eventSteps = []
    eventBus = EventBus()

    reaction = Reaction(
      consume: { calculator in
        self.result = calculator.result
      },
      rescue: { error in
        self.error = error
      }
    )

    listener = { event in
      self.reaction.invoke(with: event)
      self.addReactionStep(event)
    }

    result = 0
    error = nil
  }

  override func tearDown() {
    super.tearDown()
    Engine.sharedInstance.invalidate()
    eventBus.disposeAll()
  }

  // MARK: - Tests

  func testNext() {
    var m1 = LogEventMiddleware()
    var m2 = LogEventMiddleware()
    let event = Event<AdditionCommand>.data(Calculator(result: 11))

    m1.callback = addMiddlewareStep(m1)
    m2.callback = addMiddlewareStep(m2)

    eventBus.middlewares = [m1, m2]
    _ = eventBus.listen(to: AdditionCommand.self, listener: listener)
    eventBus.publish(event)

    XCTAssertEqual(eventSteps.count, 3)
    XCTAssertEqual(result, 11)
    XCTAssertNil(error)

    assertMiddlewareStep(0, expected: (middleware: m1, event: event))
    assertMiddlewareStep(1, expected: (middleware: m2, event: event))
    assertReactionStep(2, expected: event)
  }

  func testPublish() {
    var m1 = LogEventMiddleware()
    var m2 = ErrorEventMiddleware()
    var m3 = LogEventMiddleware()
    let dataEvent = Event<AdditionCommand>.data(Calculator(result: 11))
    let errorEvent = Event<AdditionCommand>.Error(TestError.test)

    m1.callback = addMiddlewareStep(m1)
    m2.callback = addMiddlewareStep(m2)
    m3.callback = addMiddlewareStep(m3)

    eventBus.middlewares = [m1, m2, m3]
    _ = eventBus.listen(to: AdditionCommand.self, listener: listener)
    eventBus.publish(dataEvent)

    XCTAssertEqual(eventSteps.count, 6)
    XCTAssertEqual(result, 0)
    XCTAssertTrue(error is TestError)

    assertMiddlewareStep(0, expected: (middleware: m1, event: dataEvent))
    assertMiddlewareStep(1, expected: (middleware: m2, event: dataEvent))
    assertMiddlewareStep(2, expected: (middleware: m1, event: errorEvent))
    assertMiddlewareStep(3, expected: (middleware: m2, event: errorEvent))
    assertMiddlewareStep(4, expected: (middleware: m3, event: errorEvent))
    assertReactionStep(5, expected: errorEvent)
  }

  func testAbort() {
    var m1 = LogEventMiddleware()
    var m2 = AbortEventMiddleware()
    var m3 = LogEventMiddleware()
    let event = Event<AdditionCommand>.data(Calculator(result: 11))

    m1.callback = addMiddlewareStep(m1)
    m2.callback = addMiddlewareStep(m2)
    m3.callback = addMiddlewareStep(m3)

    eventBus.middlewares = [m1, m2, m3]
    _ = eventBus.listen(to: AdditionCommand.self, listener: listener)
    eventBus.publish(event)

    XCTAssertEqual(eventSteps.count, 2)
    XCTAssertEqual(result, 0)
    XCTAssertNil(error)

    assertMiddlewareStep(0, expected: (middleware: m1, event: event))
    assertMiddlewareStep(1, expected: (middleware: m2, event: event))
  }
}
