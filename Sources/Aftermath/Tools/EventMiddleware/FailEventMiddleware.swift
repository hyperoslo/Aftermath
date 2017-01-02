public struct FailEventMiddleware: EventMiddleware {

  public typealias Failure = (event: AnyEvent.Type, error: Error)

  let failures: [Failure]

  public init(failures: [Failure]) {
    self.failures = failures
  }

  public func intercept(event: AnyEvent, publish: Publish, next: Publish) throws {
    guard let failure = failures.filter({ type(of: event) == $0.event }).first else {
      try next(event)
      return
    }

    throw failure.error
  }
}
