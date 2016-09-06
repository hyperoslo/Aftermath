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
        self.state = .Progress
      },
      consume: { result in
        self.state = .Data
      },
      rescue: { error in
        self.state = .Error
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
    let event = Event<AdditionCommand>.Progress
    reaction.invoke(with: event)

    XCTAssertEqual(state, .Progress)
  }

  func testInvokeWithData() {
    let event = Event<AdditionCommand>.Data(Calculator(result: 11))
    reaction.invoke(with: event)

    XCTAssertEqual(state, .Data)
  }

  func testInvokeWithError() {
    let event = Event<AdditionCommand>.Error(TestError.Test)
    reaction.invoke(with: event)

    XCTAssertEqual(state, .Error)
  }
}
