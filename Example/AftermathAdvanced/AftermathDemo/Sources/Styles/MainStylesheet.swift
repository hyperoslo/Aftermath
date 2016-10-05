import UIKit
import Fashion
import Hue

enum Styles: String {
  case Content
  case WelcomeButton
  case WelcomeImage
}

extension Styles: StringConvertible {

  var string: String {
    return rawValue
  }
}

struct MainStylesheet: Stylesheet {

  func define() {
    register(Styles.Content) { (view: UIView) in
      view.backgroundColor = UIColor.whiteColor()
    }

    register(Styles.WelcomeButton) { (button: UIButton) in
      button.backgroundColor = Colors.tint
      button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
      button.titleLabel?.font = UIFont.systemFontOfSize(18)
    }

    register(Styles.WelcomeImage) { (imageView: UIImageView) in
      imageView.image = UIImage(named: "hyperLogo")
    }
  }
}
