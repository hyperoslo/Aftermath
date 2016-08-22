import XCTest
@testable import Uniflow

class MutextDisposerTests: XCTestCase {

  var disposer: MutexDisposer!
  let token = "token"

  override func setUp() {
    super.setUp()
    disposer = TestDisposer()
  }

  // MARK: - Tests

  func testDispose() {
    XCTAssertEqual(disposer.listeners.count, 0)
    disposer.listeners[token] = Listener(identifier: "id", callback: { _ in })
    XCTAssertEqual(disposer.listeners.count, 1)
    disposer.dispose(token)
    XCTAssertEqual(disposer.listeners.count, 0)
  }

  func testDisposeAll() {
    XCTAssertEqual(disposer.listeners.count, 0)
    disposer.listeners[token] = Listener(identifier: "id", callback: { _ in })
    XCTAssertEqual(disposer.listeners.count, 1)
    disposer.disposeAll()
    XCTAssertEqual(disposer.listeners.count, 0)
  }
}
