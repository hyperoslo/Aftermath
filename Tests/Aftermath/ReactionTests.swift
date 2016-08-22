import XCTest
@testable import Aftermath

class ReactionTests: XCTestCase {

  var reaction: Reaction<Calculator>!
  var state: State?

  override func setUp() {
    super.setUp()

    state = nil
    reaction = Reaction(
      progress: {
        self.state = .Progress
      },
      done: { result in
        self.state = .Success
      },
      fail: { error in
        self.state = .Error
      })
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
  }

  func testInitWithParameters() {
    XCTAssertNotNil(reaction.progress)
    XCTAssertNotNil(reaction.done)
    XCTAssertNotNil(reaction.fail)
  }

  func testInvokeWithProgress() {
    let event = Event<Calculator>.Progress
    reaction.invoke(with: event)

    XCTAssertEqual(state, .Progress)
  }

  func testInvokeWithSuccess() {
    let event = Event<Calculator>.Success(Calculator(result: 11))
    reaction.invoke(with: event)

    XCTAssertEqual(state, .Success)
  }

  func testInvokeWithError() {
    let event = Event<Calculator>.Error(TestError.Test)
    reaction.invoke(with: event)

    XCTAssertEqual(state, .Error)
  }
}
