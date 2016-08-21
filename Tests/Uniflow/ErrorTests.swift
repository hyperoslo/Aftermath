import XCTest
@testable import Uniflow

class EventTests: XCTestCase {

  func testIsFrameworkError() {
    XCTAssertTrue(Error.InvalidCommandType.isFrameworkError)
    XCTAssertTrue(Warning.NoCommandHandlers(command: TestCommand()).isFrameworkError)
    XCTAssertFalse(TestError.Test.isFrameworkError)
  }
}
