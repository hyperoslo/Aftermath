import Foundation

// MARK: - Command dispatcher

public protocol CommandDispatcher: Disposer {

  var middlewares: [CommandMiddleware] { get set }

  func use<T: CommandHandler>(handler: T) -> DisposalToken
  func execute(command: AnyCommand)
}

// MARK: - Command bus

final class CommandBus: CommandDispatcher, MutexDisposer {

  var listeners: [DisposalToken: Listener] = [:]
  var middlewares: [CommandMiddleware] = []
  var mutex = pthread_mutex_t()

  deinit {
    disposeAll()
  }

  // MARK: - Register

  func use<T: CommandHandler>(handler: T) -> DisposalToken {
    pthread_mutex_lock(&mutex)

    let token = T.T.identifier

    if let listener = listeners[token] {
      let warning = Warning.DuplicatedCommandHandler(command: T.T.self, handler: listener)
      Engine.sharedInstance.errorHandler?.handleError(warning)
    }

    listeners[token] = Listener(identifier: token) { command in
      guard let command = command as? T.T else {
        throw Error.InvalidCommandType
      }

      handler.process(command)
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
      Engine.sharedInstance.errorHandler?.handleError(error)
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
}
