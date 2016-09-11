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

  func buildCommand() throws -> AnyCommand
}

// MARK: - Command producer

public protocol CommandProducer {}

public extension CommandProducer {

  func execute(command: AnyCommand) {
    Engine.sharedInstance.commandBus.execute(command)
  }

  func execute(builder: CommandBuilder) {
    Engine.sharedInstance.commandBus.execute(builder)
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

public extension CommandHandler {

  func wait() {
    publish(event: Event.Progress)
  }

  func publish(data output: CommandType.Output) {
    publish(event: Event.Data(output))
  }

  func publish(error error: ErrorType) {
    publish(event: Event.Error(error))
  }

  func publish(event event: Event<CommandType>) {
    Engine.sharedInstance.eventBus.publish(event)
  }
}

// MARK: - Action

public protocol Action: Command, CommandHandler {
  associatedtype CommandType = Self
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
