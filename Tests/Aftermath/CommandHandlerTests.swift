import XCTest
@testable import Aftermath

class CommandHandlerTests: XCTestCase {

  var commandHandler: TestCommandHandler!
  var controller: Controller!

  override func setUp() {
    super.setUp()

    commandHandler = TestCommandHandler()
    controller = Controller()
    Engine.shared.use(handler: commandHandler)
  }

  override func tearDown() {
    super.tearDown()
    Engine.shared.invalidate()
  }

  // MARK: - Tests

  func testWait() {
    var executed = false

    controller.react(to: TestCommand.self, with:
      Reaction(wait: { executed = true }))

    XCTAssertFalse(executed)
    commandHandler.wait()
    XCTAssertTrue(executed)
  }

  func testPublishData() {
    var result: String?
    let output = "Data"

    controller.react(to: TestCommand.self, with:
      Reaction(consume: { output in result = output }))

    XCTAssertNil(result)
    commandHandler.publish(data: output)
    XCTAssertEqual(result, output)
  }

  func testPublishError() {
    var resultError: Error?

    controller.react(to: TestCommand.self, with:
      Reaction(rescue: { error in resultError = error }))

    XCTAssertNil(resultError)
    commandHandler.publish(error: TestError.test)
    XCTAssertTrue(resultError is TestError)
  }

  func testPublishEvent() {
    var executed = false

    controller.react(to: TestCommand.self, with:
      Reaction(wait: {
        executed = true
      }
    ))

    XCTAssertFalse(executed)
    commandHandler.publish(event: Event.progress)
    XCTAssertTrue(executed)
  }
}
