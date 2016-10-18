class Listener {

  enum Status {
    case pending
    case issued
  }

  let identifier: String
  let callback: (Any) throws -> Void
  var status = Status.pending

  init(identifier: String, callback: @escaping (Any) throws -> Void) {
    self.identifier = identifier
    self.callback = callback
  }
}
