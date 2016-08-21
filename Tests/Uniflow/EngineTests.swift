import XCTest
@testable import Uniflow

class EngineTests: XCTestCase {

  var engine: Engine!

  override func setUp() {
    super.setUp()
    engine = Engine()
  }

  override func tearDown() {
    super.tearDown()
  }

  func testPipeCommands() {
    XCTAssertTrue(engine.commandBus.middlewares.isEmpty)

    //engine.pipeCommands(through: [])
  }

  func testPipeEvents() {
    XCTAssertTrue(engine.eventBus.middlewares.isEmpty)
  }
}
