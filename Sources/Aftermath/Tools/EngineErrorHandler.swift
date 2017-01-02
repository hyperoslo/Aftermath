public struct EngineErrorHandler: ErrorHandler {

  public init() {}

  public func handle(error: Error) {
    if let error = error as? Failure {
      log("Engine error -> \(error)", type: .error)
    } else if let warning = error as? Warning {
      log("Engine warning -> \(warning)", type: .warning)
    } else {
      log("Unknown error -> \(error)", type: .unknown)
    }
  }
}
