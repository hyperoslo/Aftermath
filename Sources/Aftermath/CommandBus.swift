import Foundation

// MARK: - Command dispatcher

public protocol CommandDispatcher: Disposer {

  var eventDispatcher: EventDispatcher { get }
  var errorHandler: ErrorHandler? { get set }
  var middlewares: [CommandMiddleware] { get set }

  init(eventDispatcher: EventDispatcher)
  func use<T: CommandHandler>(_ handler: T) -> DisposalToken
  func contains<T: CommandHandler>(_ handler: T.Type) -> Bool
  func execute(_ command: AnyCommand)
  func execute(_ builder: CommandBuilder)
}

// MARK: - Command bus

final class CommandBus: CommandDispatcher, MutexDisposer {

  let eventDispatcher: EventDispatcher
  var errorHandler: ErrorHandler?
  var listeners: [DisposalToken: Listener] = [:]
  var middlewares: [CommandMiddleware] = []
  var mutex = pthread_mutex_t()

  // MARK: - Initialization

  init(eventDispatcher: EventDispatcher) {
    self.eventDispatcher = eventDispatcher
  }

  deinit {
    disposeAll()
  }

  // MARK: - Register

  func use<T: CommandHandler>(_ handler: T) -> DisposalToken {
    pthread_mutex_lock(&mutex)

    let token = T.CommandType.identifier

    if contains(T.self) {
      let warning = Warning.duplicatedCommandHandler(command: T.CommandType.self)
      errorHandler?.handleError(warning)
    }

    listeners[token] = Listener(identifier: token) { [weak self] command in
      guard let weakSelf = self else {
        throw Failure.commandDispatcherDeallocated
      }

      guard let command = command as? T.CommandType else {
        throw Failure.invalidCommandType
      }

      let event = try handler.handle(command)
      weakSelf.eventDispatcher.publish(event)
    }

    pthread_mutex_unlock(&mutex)

    return token
  }

  func contains<T: CommandHandler>(_ handler: T.Type) -> Bool {
    let token = T.CommandType.identifier
    return listeners[token] != nil
  }

  // MARK: - Dispatch

  func execute(_ builder: CommandBuilder) {
    do {
      let command = try builder.buildCommand()
      execute(command)
    } catch {
      errorHandler?.handleError(error)
    }
  }

  func execute(_ command: AnyCommand) {
    let middlewares = self.middlewares.reversed()

    do {
      let call = try middlewares.reduce({ [unowned self] command in try self.perform(command) }) {
        [weak self] function, middleware in

        guard let weakSelf = self else {
          throw Failure.commandDispatcherDeallocated
        }

        return try middleware.compose(weakSelf.execute)(function)
      }

      try call(command)
    } catch {
      errorHandler?.handleError(error)
      handleError(error, on: command)
    }
  }

  func perform(_ command: AnyCommand) throws {
    pthread_mutex_lock(&mutex)

    guard let listener = listeners[type(of: command).identifier] else {
      pthread_mutex_unlock(&mutex)
      throw Warning.noCommandHandlers(command: command)
    }

    listener.status = .pending
    try listener.callback(command)
    listener.status = .issued

    pthread_mutex_unlock(&mutex)
  }

  // MARK: - Error handling

  func handleError(_ error: Error, on command: AnyCommand) {
    guard !error.isFrameworkError else {
      return
    }

    let errorEvent = type(of: command).buildErrorEvent(error)
    eventDispatcher.publish(errorEvent)
  }
}
