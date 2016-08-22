import XCTest
@testable import Aftermath

class EventMiddlewareTests: XCTestCase, EventStepAsserting {

  var eventSteps: [EventStep] = []
  var eventBus: EventBus!
  var reaction: Reaction<Calculator>!
  var listener: (Event<Calculator> -> Void)!
  var result = 0
  var error: ErrorType?

  override func setUp() {
    super.setUp()

    eventSteps = []
    eventBus = EventBus()

    reaction = Reaction(
      done: { calculator in
        self.result = calculator.result
      },
      fail: { error in
        self.error = error
      }
    )

    listener = { event in
      self.reaction.invoke(with: event)
      self.addReactionStep(self.reaction)
    }

    result = 0
    error = nil
  }

  override func tearDown() {
    super.tearDown()
    Engine.sharedInstance.commandBus.disposeAll()
    Engine.sharedInstance.eventBus.disposeAll()
    eventBus.disposeAll()
  }

  // MARK: - Tests

  func testNext() {
    var m1 = LogEventMiddleware()
    var m2 = LogEventMiddleware()
    let event = Event.Success(Calculator(result: 11))

    m1.callback = addMiddlewareStep(m1)
    m2.callback = addMiddlewareStep(m2)

    eventBus.middlewares = [m1, m2]
    eventBus.listen(listener)
    eventBus.publish(event)

    XCTAssertEqual(eventSteps.count, 3)
    XCTAssertEqual(result, 11)
    XCTAssertNil(error)

    assertMiddlewareStep(0, expected: (middleware: m1, event: event))
    assertMiddlewareStep(1, expected: (middleware: m2, event: event))
    assertReactionStep(2, expected: reaction)
  }
}
