import XCTest
@testable import Aftermath

class EventTests: XCTestCase {

  // MARK: - Tests

  func testBuildErrorEvent() {
    let errorEvent = Event<String>.buildErrorEvent(TestError.Test)
    XCTAssertTrue(errorEvent is Event<String>)
  }

  func testIdentifier() {
    XCTAssertEqual(Event<String>.identifier, String.identifier)
  }
}
