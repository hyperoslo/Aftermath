public protocol Command: Identifiable {
  associatedtype T: State
}

public protocol CommandBuilder {
  associatedtype T: Command

  func buildAction() throws -> T
}

