public protocol ErrorHandler {
  func handleError(_ error: Error)
}

public enum Failure: Error, CustomStringConvertible, CustomDebugStringConvertible {
  case commandDispatcherDeallocated
  case eventDispatcherDeallocated
  case invalidCommandType
  case invalidFactType
  case invalidEventType

  public var description: String {
    let string: String

    switch self {
    case .commandDispatcherDeallocated:
      string = "Command dispatcher has been deallocated."
    case .eventDispatcherDeallocated:
      string = "Event dispatcher has been deallocated."
    case .invalidCommandType:
      string = "Invalid command type."
    case .invalidFactType:
      string = "Invalid fact type."
    case .invalidEventType:
      string = "Invalid event type."
    }

    return string
  }

  public var debugDescription: String {
    return description
  }
}

public enum Warning: Error, CustomStringConvertible, CustomDebugStringConvertible {
  case noCommandHandlers(command: AnyCommand)
  case noEventListeners(event: AnyEvent)
  case duplicatedCommandHandler(command: AnyCommand.Type)

  public var description: String {
    let string: String

    switch self {
    case .noCommandHandlers(let command):
      string = "No command handler registered for command: \(command)."
    case .noEventListeners(let event):
      string = "No event listeners registered for event: \(event)."
    case .duplicatedCommandHandler(let commandType):
      string = "Previously registered handler has been overridden for command: \(commandType)"
    }

    return string
  }

  public var debugDescription: String {
    return description
  }
}

extension Error {

  var isFrameworkError: Bool {
    return (self is Failure) || (self is Warning)
  }
}
