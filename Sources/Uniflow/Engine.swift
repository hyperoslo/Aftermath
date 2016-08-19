public class Engine {

  static var commandBus: CommandDispatcher = CommandBus()
  static var eventBus: EventDispatcher = EventBus()
  static var errorHandler: ErrorHandler?

  // MARK: - Middleware

  public static func pipeCommands(through middlewares: [CommandMiddleware]) {
    commandBus.middlewares = middlewares
  }

  public static func pipeEvents(through middlewares: [EventMiddleware]) {
    eventBus.middlewares = middlewares
  }
}
