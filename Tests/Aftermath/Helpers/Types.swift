import Foundation
@testable import Aftermath


struct Calculator {
  let result: Int
}

enum State: Int {
  case Progress, Data, Error
}

enum TestError: ErrorType {
  case Test
}

class TestDisposer: MutexDisposer {
  var listeners: [DisposalToken: Listener] = [:]
  var mutex = pthread_mutex_t()
}

class ErrorManager: ErrorHandler {
  var lastError: ErrorType?

  func handleError(error: ErrorType) {
    self.lastError = error
  }
}

// MARK: - Reactions

class Controller: CommandProducer, ReactionProducer {

  var reaction: Reaction<Calculator>!
  var state: State?

  init() {
    reaction = Reaction(
      wait: {
        self.state = .Progress
      },
      consume: { result in
        self.state = .Data
      },
      rescue: { error in
        self.state = .Error
      }
    )
  }
}

class TestReactionProducer: ReactionProducer {}
