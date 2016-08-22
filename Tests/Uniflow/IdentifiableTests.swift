import XCTest
@testable import Uniflow

class IdentifiableTests: XCTestCase {

  // MARK: - Tests

  func testIdentifier() {
    XCTAssertEqual(String.identifier, String(String))
    XCTAssertEqual(TestCommand.identifier, String(TestCommand))
  }
}
