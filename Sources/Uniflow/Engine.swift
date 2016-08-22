public class Engine {

  public static let sharedInstance = Engine()

  var commandBus: CommandDispatcher = CommandBus()
  var eventBus: EventDispatcher = EventBus()

  public var errorHandler: ErrorHandler?

  // MARK: - Middleware

  public func pipeCommands(through middlewares: [CommandMiddleware]) {
    commandBus.middlewares = middlewares
  }

  public func pipeEvents(through middlewares: [EventMiddleware]) {
    eventBus.middlewares = middlewares
  }

  // MARK: - Command handling

  public func use<T: CommandHandler>(handler: T) -> DisposalToken {
    return commandBus.use(handler)
  }
}
