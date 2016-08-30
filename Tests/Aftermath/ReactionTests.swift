import XCTest
@testable import Aftermath

class ReactionTests: XCTestCase {

  var reaction: Reaction<Calculator>!
  var state: State?
  var completed = false

  override func setUp() {
    super.setUp()

    state = nil
    completed = false

    reaction = Reaction(
      progress: {
        self.state = .Progress
      },
      done: { result in
        self.state = .Success
      },
      fail: { error in
        self.state = .Error
      },
      complete: {
        self.completed = true
      }
    )
  }

  override func tearDown() {
    super.tearDown()
  }

  // MARK: - Tests

  func testInitWithoutParameters() {
    reaction = Reaction()

    XCTAssertNil(reaction.progress)
    XCTAssertNil(reaction.done)
    XCTAssertNil(reaction.fail)
    XCTAssertNil(reaction.complete)
  }

  func testInitWithParameters() {
    XCTAssertNotNil(reaction.progress)
    XCTAssertNotNil(reaction.done)
    XCTAssertNotNil(reaction.fail)
    XCTAssertNotNil(reaction.complete)
  }

  func testInvokeWithProgress() {
    let event = Event<AdditionCommand>.Progress
    reaction.invoke(with: event)

    XCTAssertEqual(state, .Progress)
    XCTAssertFalse(completed)
  }

  func testInvokeWithSuccess() {
    let event = Event<AdditionCommand>.Success(Calculator(result: 11))
    reaction.invoke(with: event)

    XCTAssertEqual(state, .Success)
    XCTAssertTrue(completed)
  }

  func testInvokeWithError() {
    let event = Event<AdditionCommand>.Error(TestError.Test)
    reaction.invoke(with: event)

    XCTAssertEqual(state, .Error)
    XCTAssertTrue(completed)
  }
}
