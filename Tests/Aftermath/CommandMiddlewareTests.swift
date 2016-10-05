import XCTest
@testable import Aftermath

class CommandMiddlewareTests: XCTestCase, CommandStepAsserting {

  var commandSteps: [CommandStep] = []
  var commandBus: CommandBus!
  var eventBus: EventBus!
  var reaction: Reaction<Calculator>!
  var additionListener: ((Event<AdditionCommand>) -> Void)!
  var subtractionListener: ((Event<SubtractionCommand>) -> Void)!
  var result = 0

  override func setUp() {
    super.setUp()

    commandSteps = []
    eventBus = EventBus()
    commandBus = CommandBus(eventDispatcher: eventBus)

    reaction = Reaction(consume: { calculator in
      self.result = calculator.result
    })

    additionListener = { event in
      self.reaction.invoke(with: event)
    }

    subtractionListener = { event in
      self.reaction.invoke(with: event)
    }

    result = 0
  }

  override func tearDown() {
    super.tearDown()
    Engine.sharedInstance.invalidate()
    commandBus.disposeAll()
    eventBus.disposeAll()
  }

  // MARK: - Tests

  func testNext() {
    var m1 = LogCommandMiddleware()
    var m2 = LogCommandMiddleware()
    let command = AdditionCommand(value1: 1, value2: 2)

    m1.callback = addMiddlewareStep(m1)
    m2.callback = addMiddlewareStep(m2)

    _ = commandBus.middlewares = [m1, m2]
    _ = commandBus.use(handler: AdditionCommandHandler(callback: addHandlerStep))
    _ = eventBus.listen(to: AdditionCommand.self, listener: additionListener)
    _ = eventBus.listen(to: SubtractionCommand.self, listener: subtractionListener)
    commandBus.execute(command: command)

    XCTAssertEqual(commandSteps.count, 3)
    XCTAssertEqual(result, 3)

    assertMiddlewareStep(0, expected: (middleware: m1, command: command))
    assertMiddlewareStep(1, expected: (middleware: m2, command: command))
    assertHandlerStep(2, expected: command)
  }

  func testExecuteCommand() {
    var m1 = LogCommandMiddleware()
    var m2 = AdditionCommandMiddleware()
    var m3 = LogCommandMiddleware()
    let subCommand = SubtractionCommand(value1: 2, value2: 1)
    let addCommand = AdditionCommand(value1: 2, value2: 1)

    m1.callback = addMiddlewareStep(m1)
    m2.callback = addMiddlewareStep(m2)
    m3.callback = addMiddlewareStep(m3)

    commandBus.middlewares = [m1, m2, m3]
    _ = commandBus.use(handler: AdditionCommandHandler(callback: addHandlerStep))
    _ = eventBus.listen(to: AdditionCommand.self, listener: additionListener)
    _ = eventBus.listen(to: SubtractionCommand.self, listener: subtractionListener)
    commandBus.execute(command: subCommand)

    XCTAssertEqual(commandSteps.count, 6)
    XCTAssertEqual(result, 3)

    assertMiddlewareStep(0, expected: (middleware: m1, command: subCommand))
    assertMiddlewareStep(1, expected: (middleware: m2, command: subCommand))
    assertMiddlewareStep(2, expected: (middleware: m1, command: addCommand))
    assertMiddlewareStep(3, expected: (middleware: m2, command: addCommand))
    assertMiddlewareStep(4, expected: (middleware: m3, command: addCommand))
    assertHandlerStep(5, expected: addCommand)
  }

  func testAbort() {
    var m1 = LogCommandMiddleware()
    var m2 = AbortCommandMiddleware()
    var m3 = LogCommandMiddleware()
    let command = AdditionCommand(value1: 1, value2: 2)

    m1.callback = addMiddlewareStep(m1)
    m2.callback = addMiddlewareStep(m2)
    m3.callback = addMiddlewareStep(m3)

    commandBus.middlewares = [m1, m2, m3]
    _ = commandBus.use(handler: AdditionCommandHandler(callback: addHandlerStep))
    _ = eventBus.listen(to: AdditionCommand.self, listener: additionListener)
    _ = eventBus.listen(to: SubtractionCommand.self, listener: subtractionListener)
    commandBus.execute(command: command)

    XCTAssertEqual(commandSteps.count, 2)
    XCTAssertEqual(result, 0)

    assertMiddlewareStep(0, expected: (middleware: m1, command: command))
    assertMiddlewareStep(1, expected: (middleware: m2, command: command))
  }
}
