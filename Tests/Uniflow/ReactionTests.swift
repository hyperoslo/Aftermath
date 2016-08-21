import XCTest
@testable import Uniflow

class ReactionTests: XCTestCase {

  enum Callback: Int {
    case Progress, Success, Error
  }

  var reaction: Reaction<Calculator>!
  var callback: Callback?

  override func setUp() {
    super.setUp()

    callback = nil
    reaction = Reaction(
      progress: {
        self.callback = .Progress
      },
      done: { result in
        self.callback = .Success
      },
      fail: { error in
        self.callback = .Error
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

    XCTAssertEqual(callback, .Progress)
  }

  func testInvokeWithSuccess() {
    let event = Event<Calculator>.Success(Calculator(result: 11))
    reaction.invoke(with: event)

    XCTAssertEqual(callback, .Success)
  }

  func testInvokeWithError() {

  }
}
