import XCTest
@testable import Aftermath

class EventTests: XCTestCase {

  // MARK: - Tests

  func testBuildErrorEvent() {
    let errorEvent = Event<TestCommand>.buildErrorEvent(TestError.Test)
    XCTAssertTrue(errorEvent is Event<TestCommand>)
  }

  func testInProgress() {
    let progressEvent = Event<TestCommand>.Progress
    XCTAssertTrue(progressEvent.inProgress)

    let successEvent = Event<TestCommand>.Success("Success")
    XCTAssertFalse(successEvent.inProgress)

    let errorEvent = Event<TestCommand>.Error(TestError.Test)
    XCTAssertFalse(errorEvent.inProgress)
  }

  func testResult() {
    let progressEvent = Event<TestCommand>.Progress
    XCTAssertNil(progressEvent.result)

    let result = "Success"
    let successEvent = Event<TestCommand>.Success(result)
    XCTAssertEqual(successEvent.result as? String, result)

    let errorEvent = Event<TestCommand>.Error(TestError.Test)
    XCTAssertNil(errorEvent.result)
  }

  func testError() {
    let progressEvent = Event<TestCommand>.Progress
    XCTAssertNil(progressEvent.error)

    let successEvent = Event<TestCommand>.Success("Success")
    XCTAssertNil(successEvent.error)

    let errorEvent = Event<TestCommand>.Error(TestError.Test)
    XCTAssertTrue(errorEvent.error is TestError)
  }
}
