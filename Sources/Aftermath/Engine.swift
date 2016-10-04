public class Engine {

  public static let sharedInstance = Engine()

  lazy var commandBus: CommandDispatcher = CommandBus(eventDispatcher: self.eventBus)
  var eventBus: EventDispatcher = EventBus()
  lazy var reactionDisposer: ReactionDisposer = ReactionDisposer(eventBus: self.eventBus)

  public var errorHandler: ErrorHandler? {
    didSet {
      commandBus.errorHandler = errorHandler
      eventBus.errorHandler = errorHandler
    }
  }

  deinit {
    invalidate()
  }

  // MARK: - Middleware

  public func pipeCommands(through middlewares: [CommandMiddleware]) {
    commandBus.middlewares = middlewares
  }

  public func pipeEvents(through middlewares: [EventMiddleware]) {
    eventBus.middlewares = middlewares
  }

  // MARK: - Command handling

  @discardableResult public func use<T: CommandHandler>(_ handler: T) -> DisposalToken {
    return commandBus.use(handler)
  }

  public func invalidate() {
    commandBus.disposeAll()
    eventBus.disposeAll()
    reactionDisposer.disposeAll()
  }
}
