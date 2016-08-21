import XCTest
@testable import Uniflow

class ReactionTests: XCTestCase {

  var reaction: Reaction<Calculator>!

  override func setUp() {
    super.setUp()
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
    reaction = Reaction(
      progress: {},
      done: { result in },
      fail: { error in })

    XCTAssertNotNil(reaction.progress)
    XCTAssertNotNil(reaction.done)
    XCTAssertNotNil(reaction.fail)
  }
}
