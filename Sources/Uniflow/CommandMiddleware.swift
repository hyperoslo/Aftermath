public typealias Execute = (Command) throws -> Void

public typealias MiddlewareCombination = (Execute) throws -> Execute

public protocol AnyCommandMiddleware {
  func execute(context: Any) throws -> MiddlewareCombination
}

public protocol CommandMiddleware: AnyCommandMiddleware {
  associatedtype T: Command

  func intercept(command: AnyCommand, execute: Execute, next: Execute) throws
  func compose(execute: Execute) throws -> MiddlewareCombination
}

public extension CommandMiddleware {

  func compose(execute: Execute) throws -> MiddlewareCombination {
    return try respond { next, command in
      return try self.intercept(command, execute: execute, next: next)
    }
  }

  func respond(handle: (Execute, AnyCommand) throws -> Void) throws -> MiddlewareCombination {
    return { next in
      return { command in
        try handle(next, command)
      }
    }
  }
}
