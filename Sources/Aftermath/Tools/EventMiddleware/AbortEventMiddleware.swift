public struct AbortEventMiddleware: EventMiddleware {

  let events: [AnyEvent.Type]

  public init(events: [AnyEvent.Type]) {
    self.events = events
  }

  public func intercept(event: AnyEvent, publish: Publish, next: Publish) throws {
    guard events.filter({ type(of: event) == $0 }).isEmpty else {
      log("Event has been aborted -> \(event)")
      return
    }

    try next(event)
  }
}
