public struct SilenceEventMiddleware: EventMiddleware {

  var error: Error?

  public init(error: Error? = nil) {
    self.error = error
  }

  public func intercept(event: AnyEvent, publish: Publish, next: Publish) throws {
    log("Silence mode: event has been blocked -> \(event)")

    if let error = error {
      throw error
    }
  }
}
