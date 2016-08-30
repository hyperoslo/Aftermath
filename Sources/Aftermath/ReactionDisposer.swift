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

  func append(token: DisposalToken, from producer: ReactionProducer) {
    let key = producer.dynamicType.identifier

    if tokens[key] == nil {
      tokens[key] = []
    }

    if tokens[key]?.contains(token) == false {
      tokens[key]?.append(token)
    }
  }

  // MARK: - Disposer

  func dispose(token: DisposalToken, from producer: ReactionProducer) {
    let key = producer.dynamicType.identifier

    guard let index = tokens[key]?.indexOf(token) else {
      return
    }

    tokens[key]?.removeAtIndex(index)

    if tokens[key]?.isEmpty == true {
      tokens.removeValueForKey(key)
    }

    eventBus.dispose(token)
  }

  func disposeAll(from producer: ReactionProducer) {
    let key = producer.dynamicType.identifier

    guard let tokens = tokens.removeValueForKey(key) else {
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
