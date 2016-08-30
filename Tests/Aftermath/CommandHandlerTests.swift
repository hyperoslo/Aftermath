import XCTest
@testable import Aftermath

class CommandHandlerTests: XCTestCase {

  var commandHandler: TestCommandHandler!
  var controller: Controller!

  override func setUp() {
    super.setUp()

    commandHandler = TestCommandHandler()
    controller = Controller()
    Engine.sharedInstance.use(commandHandler)
  }

  override func tearDown() {
    super.tearDown()
    Engine.sharedInstance.commandBus.disposeAll()
    Engine.sharedInstance.eventBus.disposeAll()
  }

  // MARK: - Tests

  func testProgress() {
    XCTAssertTrue(commandHandler.progress.inProgress)
  }

  func testWait() {
    var executed = false

    controller.react(to: TestCommand.self, with:
      Reaction(progress: { executed = true }))

    XCTAssertFalse(executed)
    commandHandler.wait()
    XCTAssertTrue(executed)
  }

  func testFulfill() {
    var result: String?
    let output = "Success"

    controller.react(to: TestCommand.self, with:
      Reaction(done: { output in result = output }))

    XCTAssertNil(result)
    commandHandler.fulfill(output)
    XCTAssertEqual(result, output)
  }

  func testReject() {
    var resultError: ErrorType?

    controller.react(to: TestCommand.self, with:
      Reaction(fail: { error in resultError = error }))

    XCTAssertNil(resultError)
    commandHandler.reject(TestError.Test)
    XCTAssertTrue(resultError is TestError)
  }

  func testPublish() {
    var executed = false

    controller.react(to: TestCommand.self, with:
      Reaction(progress: { executed = true }))

    XCTAssertFalse(executed)
    commandHandler.publish(Event.Progress)
    XCTAssertTrue(executed)
  }
}
