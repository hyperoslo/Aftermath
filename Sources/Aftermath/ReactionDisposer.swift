// MARK: - Reaction Disposer

final class ReactionDisposer {

  let eventBus: EventDispatcher
  var tokens = [String: [DisposalToken]]()

  // MARK: - Initialization

  init(eventBus: EventDispatcher) {
    self.eventBus = eventBus
  }

  deinit {
    disposeAll()
  }

  // MARK: - Tokens

  func append(_ token: DisposalToken, from producer: ReactionProducer) {
    let key = type(of: producer).identifier

    if tokens[key] == nil {
      tokens[key] = []
    }

    if tokens[key]?.contains(token) == false {
      tokens[key]?.append(token)
    }
  }

  // MARK: - Disposer

  func dispose(_ token: DisposalToken, from producer: ReactionProducer) {
    let key = type(of: producer).identifier

    guard let index = tokens[key]?.index(of: token) else {
      return
    }

    tokens[key]?.remove(at: index)

    if tokens[key]?.isEmpty == true {
      tokens.removeValue(forKey: key)
    }

    eventBus.dispose(token)
  }

  func disposeAll(from producer: ReactionProducer) {
    let key = type(of: producer).identifier

    guard let tokens = tokens.removeValue(forKey: key) else {
      return
    }

    for token in tokens {
      eventBus.dispose(token)
    }
  }

  func disposeAll() {
    tokens.removeAll()
  }
}
