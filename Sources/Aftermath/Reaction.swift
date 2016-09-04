// MARK: - Reaction

public struct Reaction<T> {

  public typealias Progress = () -> Void
  public typealias Done = (T) -> Void
  public typealias Fail = (ErrorType) -> Void
  public typealias Complete = () -> Void

  public var progress: Progress?
  public var done: Done?
  public var fail: Fail?
  public var complete: Complete?

  public init(progress: Progress? = nil, done: Done? = nil, fail: Fail? = nil, complete: Complete? = nil) {
    self.progress = progress
    self.done = done
    self.fail = fail
    self.complete = complete
  }

  func invoke<U: Command where U.Output == T>(with event: Event<U>) {
    switch event {
    case .Progress:
      progress?()
    case .Success(let result):
      done?(result)
      complete?()
    case .Error(let error):
      fail?(error)
      complete?()
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

  func react<T: Command>(to command: T.Type,
             progress: Reaction<T.Output>.Progress? = nil,
             done: Reaction<T.Output>.Done,
             fail: Reaction<T.Output>.Fail? = nil,
             complete: Reaction<T.Output>.Complete? = nil) -> DisposalToken {
    let reaction = Reaction<T.Output>(
      progress: progress,
      done: done,
      fail: fail,
      complete: complete)

    return react(to: T.self, with: reaction)
  }

  func dispose(token: DisposalToken) {
    Engine.sharedInstance.reactionDisposer.dispose(token, from: self)
  }

  func disposeAll() {
    Engine.sharedInstance.reactionDisposer.disposeAll(from: self)
  }
}
