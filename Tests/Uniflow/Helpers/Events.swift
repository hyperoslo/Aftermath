@testable import Uniflow

// MARK: - Event middleware

struct LogEventMiddleware: EventMiddleware {

  var callback: (AnyEvent -> Void)?

  func intercept(event: AnyEvent, publish: Publish, next: Publish) throws {
    callback?(event)
    try next(event)
  }
}

struct AbortEventMiddleware: EventMiddleware {

  var callback: (AnyEvent -> Void)?

  func intercept(command: AnyEvent, publish: Publish, next: Publish) throws {
    callback?(command)
  }
}

struct ErrorEventMiddleware: EventMiddleware {

  var callback: (AnyEvent -> Void)?

  func intercept(event: AnyEvent, publish: Publish, next: Publish) throws {
    callback?(event)

    guard let calcEvent = event as? Event<Calculator> else {
      try next(event)
      return
    }

    switch calcEvent {
    case .Success:
      try publish(Event<Calculator>.Error(TestError.Test))
    default:
      try next(event)
    }
  }
}
