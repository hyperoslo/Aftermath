import Aftermath
import Tailor

protocol RESTFeature {
  associatedtype Model: Entity
  var resource: String { get }
}
