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
  case Data(T.Output)
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
    case .Data(let result):
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

extension Event: CustomStringConvertible, CustomDebugStringConvertible {

  public var description: String {
    var string: String

    switch self {
    case .Progress:
      string = "Event<\(T.self)>.Progress"
    case .Data:
      string = "Event<\(T.self)>.Data with \(T.Output.self)"
    case .Error(let error):
      string = "Event<\(T.self)>.Error with \(error)"
    }

    return string
  }

  public var debugDescription: String {
    return description
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
