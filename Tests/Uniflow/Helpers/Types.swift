import Foundation
@testable import Uniflow

extension String: Projection {}

struct Calculator: Projection {
  let result: Int
}

enum State: Int {
  case Progress, Success, Error
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
      progress: {
        self.state = .Progress
      },
      done: { result in
        self.state = .Success
      },
      fail: { error in
        self.state = .Error
    })
  }
}
