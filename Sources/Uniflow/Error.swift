public protocol ErrorHandler {
  func handleError(error: ErrorType)
}

public enum Error: ErrorType {
  case CommandDispatcherDeallocated
  case EventDispatcherDeallocated
  case InvalidCommandType
  case InvalidEventType
}

public enum Warning: ErrorType {
  case NoCommandHandlers(command: AnyCommand)
  case NoEventListeners(event: AnyEvent)
  case DuplicatedCommandHandler(command: AnyCommand.Type)
}

extension ErrorType {

  var isFrameworkError: Bool {
    return (self is Error) || (self is Warning)
  }
}
