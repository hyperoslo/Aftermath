import Aftermath
import Tailor

protocol Entity: SafeMappable, Identifiable {
  var id: Int { get }
}
