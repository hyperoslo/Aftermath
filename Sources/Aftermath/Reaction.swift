// MARK: - Reaction

public final class Reaction<T> {

  public typealias Wait = () -> Void
  public typealias Consume = (T) -> Void
  public typealias Rescue = (Error) -> Void

  public var wait: Wait?
  public var consume: Consume?
  public var rescue: Rescue?

  public init(wait: Wait? = nil, consume: Consume? = nil, rescue: Rescue? = nil) {
    self.wait = wait
    self.consume = consume
    self.rescue = rescue
  }

  func invoke<U: Command>(with event: Event<U>) where U.Output == T {
    switch event {
    case .progress:
      wait?()
    case .data(let output):
      consume?(output)
    case .error(let error):
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

  @discardableResult func react<T: Command>(to command: T.Type,
                                with reaction: Reaction<T.Output>) -> DisposalToken {
    let token = Engine.shared.eventBus.listen(to: T.self) { event in
      reaction.invoke(with: event)
    }

    Engine.shared.reactionDisposer.append(token: token, from: self)

    return token
  }

  @discardableResult func next<T: Fact>(_ consume: @escaping (T) -> Void) -> DisposalToken {
    let reaction = Reaction<T>(consume: consume)
    return react(to: FactCommand<T>.self, with: reaction)
  }

  func dispose(token: DisposalToken) {
    Engine.shared.reactionDisposer.dispose(token: token, from: self)
  }

  func disposeAll() {
    Engine.shared.reactionDisposer.disposeAll(from: self)
  }
}
