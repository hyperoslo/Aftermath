public struct ErrorEventMiddleware: EventMiddleware {

  public typealias Handler = (AnyEvent, Error) -> Void

  public var handler: Handler = { event in
    log("Event failed with error -> \(event)")
  }

  public init(handler: Handler? = nil) {
    if let handler = handler {
      self.handler = handler
    }
  }

  public func intercept(event: AnyEvent, publish: Publish, next: Publish) throws {
    do {
      try next(event)
    } catch {
      handler(event, error)
      throw error
    }
  }
}
