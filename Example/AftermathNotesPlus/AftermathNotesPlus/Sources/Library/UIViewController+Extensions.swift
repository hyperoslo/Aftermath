import UIKit

extension UIViewController {

  func showAlert(title title: String, message: String) {
    let alertController = UIAlertController(
      title: title,
      message: message,
      preferredStyle: .Alert)

    alertController.addAction(UIAlertAction(
      title: "OK",
      style: .Default,
      handler: nil))

    presentViewController(alertController, animated: true, completion: nil)
  }

  func showErrorAlert(error: ErrorType) {
    showAlert(title: "Oops!", message: (error as NSError).description)
  }
}
