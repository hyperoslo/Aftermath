import XCTest
@testable import Aftermath

class ReactionTests: XCTestCase {

  var reaction: Reaction<Calculator>!
  var state: State?

  override func setUp() {
    super.setUp()

    state = nil

    reaction = Reaction(
      wait: {
        self.state = .progress
      },
      consume: { result in
        self.state = .data
      },
      rescue: { error in
        self.state = .error
      }
    )
  }

  override func tearDown() {
    super.tearDown()
  }

  // MARK: - Tests

  func testInitWithoutParameters() {
    reaction = Reaction()

    XCTAssertNil(reaction.wait)
    XCTAssertNil(reaction.consume)
    XCTAssertNil(reaction.rescue)
  }

  func testInitWithParameters() {
    XCTAssertNotNil(reaction.wait)
    XCTAssertNotNil(reaction.consume)
    XCTAssertNotNil(reaction.rescue)
  }

  func testInvokeWithProgress() {
    let event = Event<AdditionCommand>.progress
    reaction.invoke(with: event)

    XCTAssertEqual(state, .progress)
  }

  func testInvokeWithData() {
    let event = Event<AdditionCommand>.data(Calculator(result: 11))
    reaction.invoke(with: event)

    XCTAssertEqual(state, .data)
  }

  func testInvokeWithError() {
    let event = Event<AdditionCommand>.Error(TestError.test)
    reaction.invoke(with: event)

    XCTAssertEqual(state, .error)
  }
}
