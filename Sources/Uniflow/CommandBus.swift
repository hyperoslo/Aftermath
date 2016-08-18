import Foundation

//@noescape

public protocol CommandDispatcher {
  func execute<T: Command>(command: T)
  func handle<T: Command>(type: T.Type, handler: T -> Void) -> String
  func dispose(token: String)
  func disposeAll()
}

typealias DisposalToken = String

final class CommandBus: CommandDispatcher {

  var listeners: [DisposalToken: CommandListener] = [:]
  //var middlewares: [CommandMiddleware] = []
  private var mutex = pthread_mutex_t()

  var token: String {
    return NSUUID().UUIDString
  }

  deinit {
    disposeAll()
  }

  func execute<T: Command>(command: T) {
    pthread_mutex_lock(&mutex)

    let commandListeners = listeners.values.filter({ $0.identifier == T.identifier })

    for listener in commandListeners {
      listener.status = .Pending
      listener.handler(command)
      listener.status = .Handled
    }

    pthread_mutex_unlock(&mutex)
  }

  func handle<T: Command>(type: T.Type, handler: T -> Void) -> DisposalToken {
    pthread_mutex_lock(&mutex)

    let disposalToken = token

    listeners[token] = CommandListener(identifier: T.identifier) { command in
      guard let command = command as? T else {
        return
      }

      handler(command)
    }

    pthread_mutex_unlock(&mutex)

    return disposalToken
  }

  func dispose(token: String) {
    pthread_mutex_lock(&mutex)
    listeners.removeValueForKey(token)
    pthread_mutex_unlock(&mutex)
  }

  func disposeAll() {
    pthread_mutex_lock(&mutex)
    listeners.removeAll()
    pthread_mutex_unlock(&mutex)
  }
}

enum CommandStatus {
  case Pending
  case Handled
}

class CommandListener {

  let identifier: String
  let handler: (Any) -> Void
  var status = CommandStatus.Pending

  init(identifier: String, handler: (Any) -> Void) {
    self.identifier = identifier
    self.handler = handler
  }
}
