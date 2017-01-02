public struct LogEventMiddleware: EventMiddleware {

  public typealias Handler = (AnyEvent) -> Void

  public var handler: Handler = { event in
    log("Event published -> \(event)")
  }

  public init(handler: Handler? = nil) {
    if let handler = handler {
      self.handler = handler
    }
  }

  public func intercept(event: AnyEvent, publish: Publish, next: Publish) throws {
    handler(event)
    try next(event)
  }
}
