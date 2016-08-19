public class Engine {

  static var commandBus: CommandDispatcher = CommandBus()
  static var eventBus: EventDispatcher = EventBus()
  static var errorHandler: ErrorHandler?

  public static func pipeCommands(through middlewares: [CommandMiddleware]) {

  }

  public static func pipeEvents(through middlewares: [EventMiddleware]) {

  }
}
