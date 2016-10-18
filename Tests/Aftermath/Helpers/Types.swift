import Foundation
@testable import Aftermath

struct Calculator {
  let result: Int
}

enum State: Int {
  case progress, data, error
}

enum TestError: Error {
  case test
}

class TestDisposer: MutexDisposer {
  var listeners: [DisposalToken: Listener] = [:]
  var mutex = pthread_mutex_t()
}

class ErrorManager: ErrorHandler {
  var lastError: Error?

  func handle(error: Error) {
    self.lastError = error
  }
}

// MARK: - Reactions

class Controller: CommandProducer, ReactionProducer, FactProducer {

  var reaction: Reaction<Calculator>!
  var state: State?

  init() {
    reaction = Reaction(
      wait: {
        self.state = .progress
      },
      consume: { result in
        self.state = .data
      },
      rescue: { error in
        self.state = .error
      }
    )
  }
}

class TestReactionProducer: ReactionProducer {}
