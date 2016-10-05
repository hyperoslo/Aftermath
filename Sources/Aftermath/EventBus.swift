import Foundation

// MARK: - Event dispatcher

public protocol EventDispatcher: Disposer {

  var errorHandler: ErrorHandler? { get set }
  var middlewares: [EventMiddleware] { get set }

  func publish(event: AnyEvent)
  func listen<T: Command>(to command: T.Type, listener: @escaping (Event<T>) -> Void) -> DisposalToken
}

// MARK: - Event bus

final class EventBus: EventDispatcher, MutexDisposer {

  var errorHandler: ErrorHandler?
  var listeners: [DisposalToken: Listener] = [:]
  var middlewares: [EventMiddleware] = []
  var mutex = pthread_mutex_t()

  var newToken: String {
    return UUID().uuidString
  }

  deinit {
    disposeAll()
  }

  // MARK: - Register

  func listen<T: Command>(to command: T.Type, listener: @escaping (Event<T>) -> Void) -> DisposalToken {
    pthread_mutex_lock(&mutex)

    let token = newToken

    listeners[token] = Listener(identifier: T.identifier) { event in
      guard let event = event as? Event<T> else {
        throw Failure.invalidEventType
      }

      listener(event)
    }

    pthread_mutex_unlock(&mutex)

    return token
  }

  // MARK: - Dispatch

  func publish(event: AnyEvent) {
    let middlewares = self.middlewares.reversed()

    do {
      let call = try middlewares.reduce({ [unowned self] event in
        try self.perform(event: event)
      }) {
        [weak self] function, middleware in

        guard let weakSelf = self else {
          throw Failure.eventDispatcherDeallocated
        }

        return try middleware.compose(publish: weakSelf.publish)(function)
      }

      try call(event)
    } catch {
      errorHandler?.handle(error: error)
      handleError(error, on: event)
    }
  }

  func perform(event: AnyEvent) throws {
    pthread_mutex_lock(&mutex)

    let subscribers = listeners.values.filter({ $0.identifier == type(of: event).identifier })

    if subscribers.isEmpty {
      pthread_mutex_unlock(&mutex)
      throw Warning.noEventListeners(event: event)
    }

    for subscriber in subscribers {
      subscriber.status = .pending
      try subscriber.callback(event)
      subscriber.status = .issued
    }

    pthread_mutex_unlock(&mutex)
  }

  // MARK: - Error handling

  func handleError(_ error: Error, on event: AnyEvent) {
    guard !error.isFrameworkError else {
      return
    }

    do {
      try perform(event: type(of: event).buildEvent(fromError: error))
    } catch {}
  }
}
