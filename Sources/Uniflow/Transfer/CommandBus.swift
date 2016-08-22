import Foundation

// MARK: - Command dispatcher

public protocol CommandDispatcher: Disposer {

  var eventDispatcher: EventDispatcher { get }
  var errorHandler: ErrorHandler? { get set }
  var middlewares: [CommandMiddleware] { get set }

  init(eventDispatcher: EventDispatcher)
  func use<T: CommandHandler>(handler: T) -> DisposalToken
  func execute(command: AnyCommand)
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

  func use<T: CommandHandler>(handler: T) -> DisposalToken {
    pthread_mutex_lock(&mutex)

    let token = T.CommandType.identifier

    if listeners[token] != nil {
      let warning = Warning.DuplicatedCommandHandler(command: T.CommandType.self)
      errorHandler?.handleError(warning)
    }

    listeners[token] = Listener(identifier: token) { [weak self] command in
      guard let weakSelf = self else {
        throw Error.CommandDispatcherDeallocated
      }

      guard let command = command as? T.CommandType else {
        throw Error.InvalidCommandType
      }

      let event = try handler.handle(command)
      weakSelf.eventDispatcher.publish(event)
    }

    pthread_mutex_unlock(&mutex)

    return token
  }

  // MARK: - Dispatch

  func execute(command: AnyCommand) {
    let middlewares = self.middlewares.reverse()

    do {
      let call = try middlewares.reduce({ [unowned self] command in try self.perform(command) }) {
        [weak self] function, middleware in

        guard let weakSelf = self else {
          throw Error.CommandDispatcherDeallocated
        }

        return try middleware.compose(weakSelf.execute)(function)
      }

      try call(command)
    } catch {
      errorHandler?.handleError(error)
      handleError(error, on: command)
    }
  }

  func perform(command: AnyCommand) throws {
    pthread_mutex_lock(&mutex)

    guard let listener = listeners[command.dynamicType.identifier] else {
      pthread_mutex_unlock(&mutex)
      throw Warning.NoCommandHandlers(command: command)
    }

    listener.status = .Pending
    try listener.callback(command)
    listener.status = .Issued

    pthread_mutex_unlock(&mutex)
  }

  // MARK: - Error handling

  func handleError(error: ErrorType, on command: AnyCommand) {
    guard !error.isFrameworkError else {
      return
    }

    let errorEvent = command.dynamicType.buildErrorEvent(error)
    eventDispatcher.publish(errorEvent)
  }
}
