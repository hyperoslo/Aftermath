public protocol AnyCommand: Identifiable {}

public protocol Command: AnyCommand {
  associatedtype StateType: State
}

public protocol CommandBuilder {
  associatedtype CommandType: Command

  func buildCommand() throws -> CommandType
}
