import UIKit

extension UIViewController {

  func showAlert(title: String, message: String) {
    let alertController = UIAlertController(
      title: title,
      message: message,
      preferredStyle: .alert)

    alertController.addAction(UIAlertAction(
      title: "OK",
      style: .default,
      handler: nil))

    present(alertController, animated: true, completion: nil)
  }

  func showAlert(error: Error) {
    showAlert(title: "Oops!", message: (error as NSError).description)
  }
}
