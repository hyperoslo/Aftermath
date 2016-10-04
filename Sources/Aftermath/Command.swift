// MARK: - Commands

public protocol AnyCommand: Identifiable, ErrorEventBuilder {}

public protocol Command: AnyCommand {
  associatedtype Output
}

public extension Command {

  static func buildErrorEvent(_ error: Error) -> AnyEvent {
    return buildEvent(self, error: error)
  }

  fileprivate static func buildEvent<T: Command>(_ type: T.Type, error: Error) -> AnyEvent {
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

  func execute<T: Action>(action: T) {
    if !Engine.sharedInstance.commandBus.contains(T.self) {
      Engine.sharedInstance.use(action)
    }

    execute(command: action)
  }
}

public extension CommandProducer where Self: ReactionProducer {

  func execute<T: Command>(_ command: T, reaction: Reaction<T.Output>) {
    react(to: T.self, with: reaction)
    execute(command: command)
  }
}

// MARK: - Command handling

public protocol CommandHandler {
  associatedtype CommandType: Command

  func handle(_ command: CommandType) throws -> Event<CommandType>
}

public extension CommandHandler {

  func wait() {
    publish(event: Event.progress)
  }

  func publish(data output: CommandType.Output) {
    publish(event: Event.data(output))
  }

  func publish(error: Error) {
    publish(event: Event.Error(error))
  }

  func publish(event: Event<CommandType>) {
    Engine.sharedInstance.eventBus.publish(event)
  }
}

// MARK: - Action

public protocol Action: Command, CommandHandler {
  associatedtype CommandType = Self
}

// MARK: - Command middleware

public typealias Execute = (AnyCommand) throws -> Void
public typealias ExecuteCombination = (@escaping Execute) throws -> Execute

public protocol CommandMiddleware {

  func intercept(_ command: AnyCommand, execute: Execute, next: Execute) throws
  func compose(_ execute: @escaping Execute) throws -> ExecuteCombination
}

public extension CommandMiddleware {

  func compose(_ execute: @escaping Execute) throws -> ExecuteCombination {
    return try Middleware(intercept: intercept).compose(execute)
  }
}
