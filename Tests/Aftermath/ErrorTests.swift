import XCTest
@testable import Aftermath

class ErrorTests: XCTestCase {

  // MARK: - Tests

  func testIsFrameworkError() {
    XCTAssertTrue(Error.InvalidCommandType.isFrameworkError)
    XCTAssertTrue(Warning.NoCommandHandlers(command: TestCommand()).isFrameworkError)
    XCTAssertFalse(TestError.Test.isFrameworkError)
  }
}
