import XCTest
@testable import Aftermath

// MARK: - Types

enum EventStep {
  case Middleware(AnyEvent, EventMiddleware)
  case Reaction(Any)
}

protocol EventStepAsserting: class {
  var eventSteps: [EventStep] { get set }
}

// MARK: - Helpers

extension EventStepAsserting {

  func addMiddlewareStep(middleware: EventMiddleware) -> (AnyEvent) -> Void {
    return { event in
      self.eventSteps.append(EventStep.Middleware(event, middleware))
    }
  }

  func addReactionStep(reaction: Any) {
    self.eventSteps.append(EventStep.Reaction(reaction))
  }

  func assertMiddlewareStep(index: Int, expected: (middleware: EventMiddleware, event: AnyEvent)) {
    guard index >= 0 && index < eventSteps.count else {
      XCTFail("Invalid step index")
      return
    }

    switch eventSteps[index] {
    case .Middleware(let event, let middleware):
      XCTAssertTrue(event.dynamicType == expected.event.dynamicType)
      XCTAssertTrue(middleware.dynamicType == expected.middleware.dynamicType)
    default:
      XCTFail("Not a middleware step")
    }
  }

  func assertReactionStep(index: Int, expected: Any) {
    guard index > 0 && index < eventSteps.count else {
      XCTFail("Invalid step index")
      return
    }

    switch eventSteps[index] {
    case .Reaction(let reaction):
      XCTAssertTrue(reaction.dynamicType == expected.dynamicType)
    default:
      XCTFail("Not a reaction step")
    }
  }
}
