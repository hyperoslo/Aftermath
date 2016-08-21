// MARK: - Commands

public protocol AnyCommand: Identifiable {}

public protocol Command: AnyCommand {
  associatedtype ProjectionType: Projection
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
  associatedtype T: Command

  func handle(command: T) throws -> Event<T.ProjectionType>
}

extension CommandHandler {

  public func publish(event: Event<T.ProjectionType>) {
    Engine.sharedInstance.eventBus.publish(event)
  }

  func process(command: T) {
    let event: Event<T.ProjectionType>

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
