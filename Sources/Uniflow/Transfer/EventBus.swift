import Foundation

// MARK: - Event dispatcher

public protocol EventDispatcher: Disposer {

  var middlewares: [EventMiddleware] { get set }

  func publish(event: AnyEvent)
  func listen<T: Projection>(to type: T.Type, listener: Event<T> -> Void) -> String
}

// MARK: - Event bus

final class EventBus: EventDispatcher, MutexDisposer {

  var listeners: [DisposalToken: Listener] = [:]
  var middlewares: [EventMiddleware] = []
  var mutex = pthread_mutex_t()

  var newToken: String {
    return NSUUID().UUIDString
  }

  deinit {
    disposeAll()
  }

  // MARK: - Register

  func listen<T: Projection>(to type: T.Type, listener: Event<T> -> Void) -> DisposalToken {
    pthread_mutex_lock(&mutex)

    let token = newToken

    listeners[token] = Listener(identifier: T.identifier) { event in
      guard let event = event as? Event<T> else {
        return
      }

      listener(event)
    }

    pthread_mutex_unlock(&mutex)

    return token
  }

  // MARK: - Dispatch

  func publish(command: AnyEvent) {
    let middlewares = self.middlewares.reverse()

    do {
      let call = try middlewares.reduce({ [unowned self] event in try self.perform(event) }) {
        [weak self] function, middleware in

        guard let weakSelf = self else {
          throw Error.EventDispatcherDeallocated
        }

        return try middleware.compose(weakSelf.publish)(function)
      }

      try call(command)
    } catch {
      Engine.sharedInstance.errorHandler?.handleError(error)
    }
  }

  func perform(event: AnyEvent) throws {
    pthread_mutex_lock(&mutex)

    let subscribers = listeners.values.filter({ $0.identifier == event.dynamicType.identifier })

    if subscribers.isEmpty {
      pthread_mutex_unlock(&mutex)
      throw Warning.NoEventListeners(event: event)
    }

    for subscriber in subscribers {
      subscriber.status = .Pending
      try subscriber.callback(event)
      subscriber.status = .Issued
    }

    pthread_mutex_unlock(&mutex)
  }
}
