import XCTest
@testable import Aftermath

class CommandTests: XCTestCase {

  // MARK: - Tests

  func testBuildErrorEvent() {
    let errorEvent = TestCommand.buildErrorEvent(TestError.Test)
    XCTAssertTrue(errorEvent is Event<TestCommand>)
  }
}
