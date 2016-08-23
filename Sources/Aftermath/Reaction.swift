// MARK: - Reaction

public struct Reaction<T: Projection> {

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

  func invoke(with event: Event<T>) {
    switch event {
    case .Progress:
      progress?()
    case .Success(let projection):
      done?(projection)
    case .Error(let error):
      fail?(error)
    }
  }
}

// MARK: - Reaction producer

public protocol ReactionProducer {}

public extension ReactionProducer {

  func react<T: Projection>(reaction: Reaction<T>) {
    Engine.sharedInstance.eventBus.listen { event in
      reaction.invoke(with: event)
    }
  }

  func react<T: Projection>(progress progress: Reaction<T>.Progress? = nil,
             done: Reaction<T>.Done,
             fail: Reaction<T>.Fail? = nil) {
    react(Reaction<T>(progress: progress, done: done, fail: fail))
  }
}
