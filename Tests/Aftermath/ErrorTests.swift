import XCTest
@testable import Aftermath

class ErrorTests: XCTestCase {

  // MARK: - Tests

  func testIsFrameworkError() {
    XCTAssertTrue(Failure.invalidCommandType.isFrameworkError)
    XCTAssertTrue(Warning.noCommandHandlers(command: TestCommand()).isFrameworkError)
    XCTAssertFalse(TestError.test.isFrameworkError)
  }
}
