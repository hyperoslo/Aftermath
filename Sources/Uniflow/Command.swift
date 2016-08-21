// MARK: - Commands

public protocol AnyCommand: Identifiable, ErrorEventBuilder {}

public protocol Command: AnyCommand {
  associatedtype ProjectionType: Projection
}

public extension Command {

  static func buildErrorEvent(error: ErrorType) -> AnyEvent {
    return Event<ProjectionType>.Error(error)
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

  func execute<T: Command>(command: T, reaction: Reaction<T.ProjectionType>) {
    react(reaction)
  }
}

// MARK: - Command handling

public protocol CommandHandler {
  associatedtype CommandType: Command

  func handle(command: CommandType) throws -> Event<CommandType.ProjectionType>
}

extension CommandHandler {

  public func publish(event: Event<CommandType.ProjectionType>) {
    Engine.sharedInstance.eventBus.publish(event)
  }

  func process(command: CommandType) {
    let event: Event<CommandType.ProjectionType>

    do {
      event = try handle(command)
    } catch {
      event = Event.Error(error)
    }

    publish(event)
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
