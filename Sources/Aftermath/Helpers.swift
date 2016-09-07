// MARK: - Protocols

public protocol Identifiable {

  static var identifier: String { get }
}

public extension Identifiable {

  static var identifier: String {
    return String(reflecting: self)
  }
}

// MARK: - Middleware

struct Middleware<T> {

  typealias Dispatch = (T) throws -> Void
  typealias DispatchCombination = (Dispatch) throws -> Dispatch

  let intercept: (T, dispatch: Dispatch, next: Dispatch) throws -> Void

  func compose(execute: Dispatch) throws -> DispatchCombination {
    return try respond { next, command in
      return try self.intercept(command, dispatch: execute, next: next)
    }
  }

  func respond(handle: (Dispatch, T) throws -> Void) throws -> DispatchCombination {
    return { next in
      return { command in
        try handle(next, command)
      }
    }
  }
}
