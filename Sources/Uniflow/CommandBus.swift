import Foundation

//@noescape

//var token: String {
//  return NSUUID().UUIDString
//}

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

  deinit {
    disposeAll()
  }

  func execute<T: Command>(command: T) {
    pthread_mutex_lock(&mutex)

    guard let listener = listeners[T.identifier] else {
      // TODO: Handle no listeners
      return
    }

    listener.status = .Pending
    listener.handler(command)
    listener.status = .Handled

    pthread_mutex_unlock(&mutex)
  }

  func handle<T: Command>(type: T.Type, handler: T -> Void) -> DisposalToken {
    pthread_mutex_lock(&mutex)

    let token = T.identifier

    // TODO: Warning if already exists
    listeners[token] = CommandListener { command in
      guard let command = command as? T else {
        return
      }

      handler(command)
    }

    pthread_mutex_unlock(&mutex)

    return token
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

  let handler: (Any) -> Void
  var status = CommandStatus.Pending

  init(handler: (Any) -> Void) {
    self.handler = handler
  }
}
