import Foundation

// MARK: - Disposal

public typealias DisposalToken = String

public protocol Disposer {
  func dispose(token: DisposalToken)
  func disposeAll()
}

// MARK: - Mutex disposer

protocol MutexDisposer: class, Disposer {
  var mutex: pthread_mutex_t { get set }
  var listeners: [DisposalToken: Listener] { get set }
}

extension MutexDisposer {

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
