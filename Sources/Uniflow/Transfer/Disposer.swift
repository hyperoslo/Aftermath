import Foundation

//@noescape


public typealias DisposalToken = String

public protocol Disposer {
  func dispose(token: DisposalToken)
  func disposeAll()
}
