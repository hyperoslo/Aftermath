import XCTest
@testable import Uniflow

class EventTests: XCTestCase {

  var event: Event<String>!

  override func setUp() {
    super.setUp()
  }

  override func tearDown() {
    super.tearDown()
  }

  // MARK: - Tests

  func testBuildErrorEvent() {
    let errorEvent = Event<String>.buildErrorEvent(TestError.Test)
    XCTAssertTrue(errorEvent is Event<String>)
  }

  func testIdentifier() {
    XCTAssertEqual(Event<String>.identifier, String.identifier)
  }
}
