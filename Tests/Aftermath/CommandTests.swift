import XCTest
@testable import Aftermath

class CommandTests: XCTestCase {

  // MARK: - Tests

  func testBuildEventFromError() {
    let errorEvent = TestCommand.buildEvent(fromError: TestError.test)
    XCTAssertTrue(errorEvent is Event<TestCommand>)
  }
}
