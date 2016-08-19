public protocol Projection: Identifiable {}

public protocol AnyEvent: Identifiable {}

public enum Event<T: Projection>: AnyEvent {
  case Progress
  case Success(T)
  case Error(ErrorType)
}

public extension Event {

  static var identifier: String {
    return String(self) + T.identifier
  }
}

// MARK: - Event middleware

public typealias Publish = (AnyEvent) throws -> Void
public typealias PublishCombination = (Publish) throws -> Publish

public protocol EventMiddleware {

  func intercept(command: AnyEvent, execute: Publish, next: Publish) throws
  func compose(execute: Publish) throws -> PublishCombination
}

public extension EventMiddleware {

  func compose(execute: Publish) throws -> PublishCombination {
    return try Middleware(intercept: intercept).compose(execute)
  }
}
