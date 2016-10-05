import UIKit

class WelcomeController: UIViewController {

  lazy var imageView: UIImageView = {
    let imageView = UIImageView(styles: Styles.WelcomeImage)
    imageView.translatesAutoresizingMaskIntoConstraints = false

    return imageView
  }()

  lazy var button: UIButton = { [unowned self] in
    let button = UIButton(type: .System)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.stylize(Styles.WelcomeButton)
    button.setTitle(NSLocalizedString("Enter", comment: "").uppercaseString, forState: .Normal)
    button.addTarget(self, action: #selector(buttonDidPress), forControlEvents: .TouchUpInside)

    return button
    }()

  // MARK: - View Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()

    view.stylize(Styles.Content)
    title = "Aftermath"
    [imageView, button].forEach { view.addSubview($0) }
    configureConstrains()
  }

  // MARK: - Configuration

  func configureConstrains() {
    imageView.topAnchor.constraintEqualToAnchor(view.topAnchor, constant: 150).active = true
    imageView.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor).active = true
    imageView.widthAnchor.constraintEqualToConstant(248).active = true
    imageView.heightAnchor.constraintEqualToConstant(74).active = true

    button.topAnchor.constraintEqualToAnchor(imageView.bottomAnchor, constant: 120).active = true
    button.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor).active = true
    button.widthAnchor.constraintEqualToConstant(200).active = true
    button.heightAnchor.constraintEqualToConstant(50).active = true
  }

  // MARK: - Actions

  func buttonDidPress() {
    let controller = MainController()
    navigationController?.pushViewController(controller, animated: true)
  }
}
