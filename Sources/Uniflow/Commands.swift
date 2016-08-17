public protocol Command: Identifiable {
  associatedtype T: State
}

public protocol CommandBuilder {
  associatedtype T: Command

  func buildCommand() throws -> T
}

