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
    case .Success(let result):
      done?(result)
    case .Error(let error):
      fail?(error)
    }
  }
}

// MARK: - Reaction producer

public protocol ReactionProducer {}

public extension ReactionProducer {

  func react<T: Command>(to command: T.Type, with reaction: Reaction<T.Output>) {
    Engine.sharedInstance.eventBus.listen(to: T.self) { event in
      reaction.invoke(with: event)
    }
  }

  func react<T: Command>(to command: T.Type,
             progress: Reaction<T.Output>.Progress? = nil,
             done: Reaction<T.Output>.Done,
             fail: Reaction<T.Output>.Fail? = nil) {
    react(to: T.self, with: Reaction<T.Output>(progress: progress, done: done, fail: fail))
  }
}
