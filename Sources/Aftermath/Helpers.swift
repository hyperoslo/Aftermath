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

  typealias Publish = (T) throws -> Void
  typealias PublishCombination = (Publish) throws -> Publish

  let intercept: (T, execute: Publish, next: Publish) throws -> Void

  func compose(execute: Publish) throws -> PublishCombination {
    return try respond { next, command in
      return try self.intercept(command, execute: execute, next: next)
    }
  }

  func respond(handle: (Publish, T) throws -> Void) throws -> PublishCombination {
    return { next in
      return { command in
        try handle(next, command)
      }
    }
  }
}
