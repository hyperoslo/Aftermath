@testable import Aftermath

// MARK: - Event middleware

struct LogEventMiddleware: EventMiddleware {

  var callback: ((AnyEvent) -> Void)?

  func intercept(_ event: AnyEvent, publish: Publish, next: Publish) throws {
    callback?(event)
    try next(event)
  }
}

struct AbortEventMiddleware: EventMiddleware {

  var callback: ((AnyEvent) -> Void)?

  func intercept(_ command: AnyEvent, publish: Publish, next: Publish) throws {
    callback?(command)
  }
}

struct ErrorEventMiddleware: EventMiddleware {

  var callback: ((AnyEvent) -> Void)?

  func intercept(_ event: AnyEvent, publish: Publish, next: Publish) throws {
    callback?(event)

    guard let additionEvent = event as? Event<AdditionCommand> else {
      try next(event)
      return
    }

    switch additionEvent {
    case .data:
      try publish(Event<AdditionCommand>.Error(TestError.test))
    default:
      try next(event)
    }
  }
}
