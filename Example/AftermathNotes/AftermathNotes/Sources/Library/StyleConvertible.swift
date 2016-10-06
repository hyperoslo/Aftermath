import Fashion
import Aftermath

protocol StyleConvertible: StringConvertible, Identifiable {
  var rawValue: String { get }
}

extension StyleConvertible {

  var string: String {
    return "\(self.dynamicType.identifier).\(rawValue)"
  }
}
