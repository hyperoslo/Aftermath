import XCTest
@testable import Aftermath

class EventTests: XCTestCase {

  // MARK: - Tests

  func testBuildEventFromError() {
    let errorEvent = Event<TestCommand>.buildEvent(fromError: TestError.test)
    XCTAssertTrue(errorEvent is Event<TestCommand>)
  }

  func testInProgress() {
    let progressEvent = Event<TestCommand>.progress
    XCTAssertTrue(progressEvent.inProgress)

    let dataEvent = Event<TestCommand>.data("Data")
    XCTAssertFalse(dataEvent.inProgress)

    let errorEvent = Event<TestCommand>.error(TestError.test)
    XCTAssertFalse(errorEvent.inProgress)
  }

  func testResult() {
    let progressEvent = Event<TestCommand>.progress
    XCTAssertNil(progressEvent.result)

    let result = "Data"
    let dataEvent = Event<TestCommand>.data(result)
    XCTAssertEqual(dataEvent.result as? String, result)

    let errorEvent = Event<TestCommand>.error(TestError.test)
    XCTAssertNil(errorEvent.result)
  }

  func testError() {
    let progressEvent = Event<TestCommand>.progress
    XCTAssertNil(progressEvent.error)

    let dataEvent = Event<TestCommand>.data("Data")
    XCTAssertNil(dataEvent.error)

    let errorEvent = Event<TestCommand>.error(TestError.test)
    XCTAssertTrue(errorEvent.error is TestError)
  }
}
