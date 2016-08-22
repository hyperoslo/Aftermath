import XCTest
@testable import Uniflow

class CommandTests: XCTestCase {

  // MARK: - Tests

  func testBuildErrorEvent() {
    let errorEvent = AdditionCommand.buildErrorEvent(TestError.Test)
    XCTAssertTrue(errorEvent is Event<Calculator>)
  }
}
