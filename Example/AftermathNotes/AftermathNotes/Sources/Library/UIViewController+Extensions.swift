import UIKit

extension UIViewController {

  func showAlert(message message: String) {
    let alertController = UIAlertController(
      title: "Oops!",
      message: message,
      preferredStyle: .Alert)

    alertController.addAction(UIAlertAction(
      title: "OK",
      style: .Default,
      handler: nil))

    presentViewController(alertController, animated: true, completion: nil)
  }
}
