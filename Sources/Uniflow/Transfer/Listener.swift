class Listener {

  enum Status {
    case Pending
    case Issued
  }

  let identifier: String
  let callback: (Any) throws -> Void
  var status = Status.Pending

  init(identifier: String, callback: (Any) throws -> Void) {
    self.identifier = identifier
    self.callback = callback
  }
}
