// MARK: - Reaction

public struct Reaction<T> {

  public typealias Progress = () -> Void
  public typealias Done = (T) -> Void
  public typealias Fail = (ErrorType) -> Void

  public var progress: Progress?
  public var done: Done?
  public var fail: Fail?

  public init(progress: Progress? = nil, done: Done? = nil, fail: Fail? = nil) {
    self.progress = progress
    self.done = done
    self.fail = fail
  }

  func invoke<U: Command where U.Output == T>(with event: Event<U>) {
    switch event {
    case .Progress:
      progress?()
    case .Data(let result):
      done?(result)
    case .Error(let error):
      fail?(error)
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

  func dispose(token: DisposalToken) {
    Engine.sharedInstance.reactionDisposer.dispose(token, from: self)
  }

  func disposeAll() {
    Engine.sharedInstance.reactionDisposer.disposeAll(from: self)
  }
}
