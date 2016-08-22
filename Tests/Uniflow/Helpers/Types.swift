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
