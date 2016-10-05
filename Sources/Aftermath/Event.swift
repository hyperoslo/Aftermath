// MARK: - Events

public protocol ErrorEventBuilder {
  static func buildEvent(fromError error: Error) -> AnyEvent
}

public protocol AnyEvent: Identifiable, ErrorEventBuilder {
  var inProgress: Bool { get }
  var result: Any? { get }
  var error: Error? { get }
}

public enum Event<T: Command>: AnyEvent {
  case progress
  case data(T.Output)
  case error(Error)

  // MARK: - Helpers

  public var inProgress: Bool {
    var value = false

    switch self {
    case .progress:
      value = true
    default:
      break
    }

    return value
  }

  public var result: Any? {
    var value: Any?

    switch self {
    case .data(let result):
      value = result
    default:
      break
    }

    return value
  }

  public var error: Error? {
    var value: Error?

    switch self {
    case .error(let error):
      value = error
    default:
      break
    }

    return value
  }

  public static func buildEvent(fromError error: Error) -> AnyEvent {
    return Event.error(error)
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
    case .progress:
      string = "Event<\(T.self)>.Progress"
    case .data:
      string = "Event<\(T.self)>.Data with \(T.Output.self)"
    case .error(let error):
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
public typealias PublishCombination = (@escaping Publish) throws -> Publish

public protocol EventMiddleware {

  func intercept(event: AnyEvent, publish: Publish, next: Publish) throws
  func compose(publish: @escaping Publish) throws -> PublishCombination
}

public extension EventMiddleware {

  func compose(publish: @escaping Publish) throws -> PublishCombination {
    return try Middleware(intercept: intercept).compose(execute: publish)
  }
}
