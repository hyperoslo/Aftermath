// MARK: - Events

public protocol ErrorEventBuilder {
  static func buildErrorEvent(error: ErrorType) -> AnyEvent
}

public protocol AnyEvent: Identifiable, ErrorEventBuilder {
  var inProgress: Bool { get }
  var result: Any? { get }
  var error: ErrorType? { get }
}

public enum Event<T: Command>: AnyEvent {
  case Progress
  case Success(T.Output)
  case Error(ErrorType)

  // MARK: - Helpers

  public var inProgress: Bool {
    var value = false

    switch self {
    case .Progress:
      value = true
    default:
      break
    }

    return value
  }

  public var result: Any? {
    var value: Any?

    switch self {
    case .Success(let result):
      value = result
    default:
      break
    }

    return value
  }

  public var error: ErrorType? {
    var value: ErrorType?

    switch self {
    case .Error(let error):
      value = error
    default:
      break
    }

    return value
  }

  public static func buildErrorEvent(error: ErrorType) -> AnyEvent {
    return Error(error)
  }
}

public extension Event {

  static var identifier: String {
    return T.identifier
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
