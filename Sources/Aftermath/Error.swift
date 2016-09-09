public protocol ErrorHandler {
  func handleError(error: ErrorType)
}

public enum Error: ErrorType, CustomStringConvertible, CustomDebugStringConvertible {
  case CommandDispatcherDeallocated
  case EventDispatcherDeallocated
  case InvalidCommandType
  case InvalidEventType

  public var description: String {
    let string: String

    switch self {
    case .CommandDispatcherDeallocated:
      string = "Command dispatcher has been deallocated."
    case .EventDispatcherDeallocated:
      string = "Event dispatcher has been deallocated."
    case .InvalidCommandType:
      string = "Invalid command type."
    case .InvalidEventType:
      string = "Invalid event type."
    }

    return string
  }

  public var debugDescription: String {
    return description
  }
}

public enum Warning: ErrorType, CustomStringConvertible, CustomDebugStringConvertible {
  case NoCommandHandlers(command: AnyCommand)
  case NoEventListeners(event: AnyEvent)
  case DuplicatedCommandHandler(command: AnyCommand.Type)

  public var description: String {
    let string: String

    switch self {
    case .NoCommandHandlers(let command):
      string = "No command handler registered for command: \(command)."
    case .NoEventListeners(let event):
      string = "No event listeners registered for event: \(event)."
    case .DuplicatedCommandHandler(let commandType):
      string = "Previously registered handler has been overridden for command: \(commandType)"
    }

    return string
  }

  public var debugDescription: String {
    return description
  }
}

extension ErrorType {

  var isFrameworkError: Bool {
    return (self is Error) || (self is Warning)
  }
}
