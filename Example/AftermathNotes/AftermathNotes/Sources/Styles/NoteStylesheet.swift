import UIKit
import Fashion

struct NoteStylesheet: Stylesheet {

  enum Style: String, StyleConvertible {
    case DetailTitleLabel
    case DetailTextView
  }

  func define() {
    // Custom styles

    register(Style.DetailTitleLabel) { (label: UILabel) in
      label.translatesAutoresizingMaskIntoConstraints = false
      label.textColor = UIColor.blackColor()
      label.font = UIFont.boldSystemFontOfSize(16)
      label.numberOfLines = 0
    }

    register(Style.DetailTextView) { (textView: UITextView) in
      textView.translatesAutoresizingMaskIntoConstraints = false
      textView.scrollEnabled = true
      textView.editable = true
      textView.textColor = UIColor.blackColor()
      textView.font = UIFont.systemFontOfSize(14)
    }
  }
}
