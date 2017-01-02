protocol AsyncCommand: AnyCommand, CommandProducer {
  func invoke() throws
}

public struct AsyncCommandMiddleware: CommandMiddleware {

  public init() {}

  public func intercept(command: AnyCommand, execute: Execute, next: Execute) throws {
    guard let asyncCommand = command as? AsyncCommand else {
      try next(command)
      return
    }

    try asyncCommand.invoke()
  }
}
