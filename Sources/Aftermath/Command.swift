// MARK: - Commands

public protocol AnyCommand: Identifiable, ErrorEventBuilder {}

public protocol Command: AnyCommand {
  associatedtype Output
}

public extension Command {

  static func buildErrorEvent(error: ErrorType) -> AnyEvent {
    return buildEvent(self, error: error)
  }

  private static func buildEvent<T: Command>(type: T.Type, error: ErrorType) -> AnyEvent {
    return Event<T>.Error(error)
  }
}

// MARK: - Command builder

public protocol CommandBuilder {
  associatedtype CommandType: Command

  func buildCommand() throws -> CommandType
}

// MARK: - Command producer

public protocol CommandProducer {}

public extension CommandProducer {

  func execute<T: Command>(command: T) {
    Engine.sharedInstance.commandBus.execute(command)
  }
}

public extension CommandProducer where Self: ReactionProducer {

  func execute<T: Command>(command: T, reaction: Reaction<T.Output>) {
    react(to: T.self, with: reaction)
    execute(command)
  }
}

// MARK: - Command handling

public protocol CommandHandler {
  associatedtype CommandType: Command

  func handle(command: CommandType) throws -> Event<CommandType>
}

extension CommandHandler {

  var progress: Event<CommandType> {
    return Event.Progress
  }

  public func publish(event: Event<CommandType>) {
    Engine.sharedInstance.eventBus.publish(event)
  }

  public func wait() {
    publish(progress)
  }

  public func fulfill(output: CommandType.Output) {
    publish(Event.Success(output))
  }

  public func reject(error: ErrorType) {
    publish(Event.Error(error))
  }
}

// MARK: - Command middleware

public typealias Execute = (AnyCommand) throws -> Void
public typealias ExecuteCombination = (Execute) throws -> Execute

public protocol CommandMiddleware {

  func intercept(command: AnyCommand, execute: Execute, next: Execute) throws
  func compose(execute: Execute) throws -> ExecuteCombination
}

public extension CommandMiddleware {

  func compose(execute: Execute) throws -> ExecuteCombination {
    return try Middleware(intercept: intercept).compose(execute)
  }
}
