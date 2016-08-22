import XCTest
@testable import Aftermath

// MARK: - Types

enum CommandStep {
  case Middleware(AnyCommand, CommandMiddleware)
  case Handler(AnyCommand)
}

protocol CommandStepAsserting: class {
  var commandSteps: [CommandStep] { get set }
}

// MARK: - Helpers

extension CommandStepAsserting {

  func addMiddlewareStep(middleware: CommandMiddleware) -> (AnyCommand) -> Void {
    return { command in
      self.commandSteps.append(CommandStep.Middleware(command, middleware))
    }
  }

  func addHandlerStep(command: AnyCommand) {
    self.commandSteps.append(CommandStep.Handler(command))
  }

  func assertMiddlewareStep(index: Int, expected: (middleware: CommandMiddleware, command: AnyCommand)) {
    guard index >= 0 && index < commandSteps.count else {
      XCTFail("Invalid step index")
      return
    }

    switch commandSteps[index] {
    case .Middleware(let command, let middleware):
      XCTAssertTrue(command.dynamicType == expected.command.dynamicType)
      XCTAssertTrue(middleware.dynamicType == expected.middleware.dynamicType)
    default:
      XCTFail("Not a middleware step")
    }
  }

  func assertHandlerStep(index: Int, expected: AnyCommand) {
    guard index > 0 && index < commandSteps.count else {
      XCTFail("Invalid step index")
      return
    }

    switch commandSteps[index] {
    case .Handler(let command):
      XCTAssertTrue(command.dynamicType == expected.dynamicType)
    default:
      XCTFail("Not a command handler step")
    }
  }
}
