import XCTest
@testable import Aftermath

// MARK: - Types

enum CommandStep {
  case middleware(AnyCommand, CommandMiddleware)
  case handler(AnyCommand)
}

protocol CommandStepAsserting: class {
  var commandSteps: [CommandStep] { get set }
}

// MARK: - Helpers

extension CommandStepAsserting {

  func addMiddlewareStep(_ middleware: CommandMiddleware) -> (AnyCommand) -> Void {
    return { command in
      self.commandSteps.append(CommandStep.middleware(command, middleware))
    }
  }

  func addHandlerStep(_ command: AnyCommand) {
    self.commandSteps.append(CommandStep.handler(command))
  }

  func assertMiddlewareStep(_ index: Int, expected: (middleware: CommandMiddleware, command: AnyCommand)) {
    guard index >= 0 && index < commandSteps.count else {
      XCTFail("Invalid step index")
      return
    }

    switch commandSteps[index] {
    case .middleware(let command, let middleware):
      XCTAssertTrue(type(of: command) == type(of: expected.command))
      XCTAssertTrue(type(of: middleware) == type(of: expected.middleware))
    default:
      XCTFail("Not a middleware step")
    }
  }

  func assertHandlerStep(_ index: Int, expected: AnyCommand) {
    guard index > 0 && index < commandSteps.count else {
      XCTFail("Invalid step index")
      return
    }

    switch commandSteps[index] {
    case .handler(let command):
      XCTAssertTrue(type(of: command) == type(of: expected))
    default:
      XCTFail("Not a command handler step")
    }
  }
}
