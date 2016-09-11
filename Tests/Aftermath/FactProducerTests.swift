import XCTest
@testable import Aftermath

class FactProducerTests: XCTestCase {

  var producer: Controller!
  let result = "test"

  override func setUp() {
    super.setUp()

    producer = Controller()
  }

  override func tearDown() {
    super.tearDown()
    Engine.sharedInstance.invalidate()
  }

  // MARK: - Tests

  func testPublishFact() {
    var output1: String?
    var output2: String?
    let reactionProducer1 = TestReactionProducer()
    let reactionProducer2 = TestReactionProducer()

    reactionProducer1.next { (fact: TestFact) in
      output1 = fact.result
    }

    reactionProducer2.next { (fact: TestFact) in
      output2 = fact.result
    }

    let fact = TestFact(result: result)

    producer.publish(fact: fact)
    XCTAssertEqual(output1, result)
    XCTAssertEqual(output2, result)
  }
}
