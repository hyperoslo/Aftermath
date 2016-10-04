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
  typealias DispatchCombination = (@escaping Dispatch) throws -> Dispatch

  let intercept: (T, _ dispatch: Dispatch, _ next: Dispatch) throws -> Void

  func compose(_ execute: @escaping Dispatch) throws -> DispatchCombination {
    return try respond { next, command in
      return try self.intercept(command, execute, next)
    }
  }

  func respond(_ handle: @escaping (Dispatch, T) throws -> Void) throws -> DispatchCombination {
    return { next in
      return { command in
        try handle(next, command)
      }
    }
  }
}
