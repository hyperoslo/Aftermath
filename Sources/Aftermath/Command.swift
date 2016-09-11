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

  func execute(command command: AnyCommand) {
    Engine.sharedInstance.commandBus.execute(command)
  }

  func execute(builder builder: CommandBuilder) {
    Engine.sharedInstance.commandBus.execute(builder)
  }

  func execute<T: Action>(action action: T) {
    if !Engine.sharedInstance.commandBus.contains(T.self) {
      Engine.sharedInstance.commandBus.use(action)
    }

    execute(command: action)
  }

  func publish<T: Fact>(fact fact: T) {
    execute(action: fact)
  }
}

public extension CommandProducer where Self: ReactionProducer {

  func execute<T: Command>(command: T, reaction: Reaction<T.Output>) {
    react(to: T.self, with: reaction)
    execute(command: command)
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

// MARK: - Fact

public protocol Fact: Action {
  associatedtype CommandType = Self
  associatedtype Output = Self
}

public extension Fact {

  func handle(command: CommandType) throws -> Event<CommandType> {
    return Event.Data(self as! CommandType.Output)
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
