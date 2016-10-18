import XCTest
@testable import Aftermath

// MARK: - Types

enum EventStep {
  case middleware(AnyEvent, EventMiddleware)
  case reaction(Any)
}

protocol EventStepAsserting: class {
  var eventSteps: [EventStep] { get set }
}

// MARK: - Helpers

extension EventStepAsserting {

  func addMiddlewareStep(_ middleware: EventMiddleware) -> (AnyEvent) -> Void {
    return { event in
      self.eventSteps.append(EventStep.middleware(event, middleware))
    }
  }

  func addReactionStep(_ reaction: Any) {
    self.eventSteps.append(EventStep.reaction(reaction))
  }

  func assertMiddlewareStep(_ index: Int, expected: (middleware: EventMiddleware, event: AnyEvent)) {
    guard index >= 0 && index < eventSteps.count else {
      XCTFail("Invalid step index")
      return
    }

    switch eventSteps[index] {
    case .middleware(let event, let middleware):
      XCTAssertTrue(type(of: event) == type(of: expected.event))
      XCTAssertTrue(type(of: middleware) == type(of: expected.middleware))
    default:
      XCTFail("Not a middleware step")
    }
  }

  func assertReactionStep(_ index: Int, expected: Any) {
    guard index > 0 && index < eventSteps.count else {
      XCTFail("Invalid step index")
      return
    }

    switch eventSteps[index] {
    case .reaction(let reaction):
      XCTAssertTrue(type(of: (reaction) as Any) == type(of: expected))
    default:
      XCTFail("Not a reaction step")
    }
  }
}
