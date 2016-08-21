public protocol Projection: Identifiable {}

public protocol ErrorEventBuilder {
  static func buildErrorEvent(error: ErrorType) -> AnyEvent
}

public protocol AnyEvent: Identifiable, ErrorEventBuilder {}

public enum Event<T: Projection>: AnyEvent {
  case Progress
  case Success(T)
  case Error(ErrorType)

  public static func buildErrorEvent(error: ErrorType) -> AnyEvent {
    return Error(error)
  }
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

  func intercept(event: AnyEvent, publish: Publish, next: Publish) throws
  func compose(publish: Publish) throws -> PublishCombination
}

public extension EventMiddleware {

  func compose(publish: Publish) throws -> PublishCombination {
    return try Middleware(intercept: intercept).compose(publish)
  }
}
