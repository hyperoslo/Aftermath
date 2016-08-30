import XCTest
@testable import Aftermath

class EventTests: XCTestCase {

  // MARK: - Tests

  func testBuildErrorEvent() {
    let errorEvent = Event<TestCommand>.buildErrorEvent(TestError.Test)
    XCTAssertTrue(errorEvent is Event<TestCommand>)
  }
}
