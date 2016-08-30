import XCTest
@testable import Aftermath

class EventTests: XCTestCase {

  // MARK: - Tests

  func testBuildErrorEvent() {
    let errorEvent = Event<TestCommand>.buildErrorEvent(TestError.Test)
    XCTAssertTrue(errorEvent is Event<TestCommand>)
  }

  func testResult() {
    let progressEvent = Event<TestCommand>.Progress
    XCTAssertNil(progressEvent.result)

    let result = "Success"
    let successEvent = Event<TestCommand>.Success("Success")
    XCTAssertEqual(successEvent.result as? String, result)

    let errorEvent = Event<TestCommand>.Error(TestError.Test)
    XCTAssertNil(errorEvent.result)
  }
}
