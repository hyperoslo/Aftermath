// MARK: - Reaction

public final class Reaction<T> {

  public typealias Wait = () -> Void
  public typealias Consume = T -> Void
  public typealias Rescue = ErrorType -> Void

  public var wait: Wait?
  public var consume: Consume?
  public var rescue: Rescue?

  public init(wait: Wait? = nil, consume: Consume? = nil, rescue: Rescue? = nil) {
    self.wait = wait
    self.consume = consume
    self.rescue = rescue
  }

  func invoke<U: Command where U.Output == T>(with event: Event<U>) {
    switch event {
    case .Progress:
      wait?()
    case .Data(let output):
      consume?(output)
    case .Error(let error):
      rescue?(error)
    }
  }
}

// MARK: - Command builder

public protocol ReactionBuilder {
  associatedtype Output

  func buildReaction() throws -> Reaction<Output>
}

// MARK: - Reaction producer

public protocol ReactionProducer: Identifiable, Disposer {}

public extension ReactionProducer {

  func react<T: Command>(to command: T.Type, with reaction: Reaction<T.Output>) -> DisposalToken {
    let token = Engine.sharedInstance.eventBus.listen(to: T.self) { event in
      reaction.invoke(with: event)
    }

    Engine.sharedInstance.reactionDisposer.append(token, from: self)

    return token
  }

  func next<T: Fact>(consume: T -> Void) -> DisposalToken {
    let reaction = Reaction<T>(consume: consume)
    return react(to: FactCommand<T>.self, with: reaction)
  }

  func dispose(token: DisposalToken) {
    Engine.sharedInstance.reactionDisposer.dispose(token, from: self)
  }

  func disposeAll() {
    Engine.sharedInstance.reactionDisposer.disposeAll(from: self)
  }
}
