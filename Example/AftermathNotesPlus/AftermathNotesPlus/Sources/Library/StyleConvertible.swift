import Fashion
import Aftermath

protocol StyleConvertible: StringConvertible, Identifiable {
  var rawValue: String { get }
}

extension StyleConvertible {

  var string: String {
    return "\(type(of: self).identifier).\(rawValue)"
  }
}
