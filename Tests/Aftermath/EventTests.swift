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

    let dataEvent = Event<TestCommand>.Data("Data")
    XCTAssertFalse(dataEvent.inProgress)

    let errorEvent = Event<TestCommand>.Error(TestError.Test)
    XCTAssertFalse(errorEvent.inProgress)
  }

  func testResult() {
    let progressEvent = Event<TestCommand>.Progress
    XCTAssertNil(progressEvent.result)

    let result = "Data"
    let dataEvent = Event<TestCommand>.Data(result)
    XCTAssertEqual(dataEvent.result as? String, result)

    let errorEvent = Event<TestCommand>.Error(TestError.Test)
    XCTAssertNil(errorEvent.result)
  }

  func testError() {
    let progressEvent = Event<TestCommand>.Progress
    XCTAssertNil(progressEvent.error)

    let dataEvent = Event<TestCommand>.Data("Data")
    XCTAssertNil(dataEvent.error)

    let errorEvent = Event<TestCommand>.Error(TestError.Test)
    XCTAssertTrue(errorEvent.error is TestError)
  }
}
