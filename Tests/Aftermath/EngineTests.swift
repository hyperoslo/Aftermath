import XCTest
@testable import Aftermath

class EngineTests: XCTestCase {

  var engine: Engine!

  override func setUp() {
    super.setUp()
    engine = Engine()
  }

  // MARK: - Tests

  func testInit() {
    XCTAssertNil(engine.errorHandler)
  }

  func testPipeCommands() {
    XCTAssertTrue(engine.commandBus.middlewares.isEmpty)

    engine.pipeCommands(through: [
      LogCommandMiddleware(),
      AdditionCommandMiddleware(),
      AbortCommandMiddleware()]
    )

    XCTAssertEqual(engine.commandBus.middlewares.count, 3)
  }

  func testPipeEvents() {
    XCTAssertTrue(engine.eventBus.middlewares.isEmpty)

    engine.pipeEvents(through: [
      LogEventMiddleware(),
      ErrorEventMiddleware(),
      AbortEventMiddleware()]
    )

    XCTAssertEqual(engine.eventBus.middlewares.count, 3)
  }

  func testUse() {

  }
}
