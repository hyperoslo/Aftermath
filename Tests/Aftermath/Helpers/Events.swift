@testable import Aftermath

// MARK: - Event middleware

struct LogEventMiddleware: EventMiddleware {

  var callback: ((AnyEvent) -> Void)?

  func intercept(event: AnyEvent, publish: Publish, next: Publish) throws {
    callback?(event)
    try next(event)
  }
}

struct AbortEventMiddleware: EventMiddleware {

  var callback: ((AnyEvent) -> Void)?

  func intercept(event: AnyEvent, publish: Publish, next: Publish) throws {
    callback?(event)
  }
}

struct ErrorEventMiddleware: EventMiddleware {

  var callback: ((AnyEvent) -> Void)?

  func intercept(event: AnyEvent, publish: Publish, next: Publish) throws {
    callback?(event)

    guard let additionEvent = event as? Event<AdditionCommand> else {
      try next(event)
      return
    }

    switch additionEvent {
    case .data:
      try publish(Event<AdditionCommand>.error(TestError.test))
    default:
      try next(event)
    }
  }
}
