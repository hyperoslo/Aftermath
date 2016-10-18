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
      label.textColor = UIColor.black
      label.font = UIFont.boldSystemFont(ofSize: 16)
      label.numberOfLines = 0
    }

    register(Style.DetailTextView) { (textView: UITextView) in
      textView.translatesAutoresizingMaskIntoConstraints = false
      textView.isScrollEnabled = true
      textView.isEditable = true
      textView.textColor = UIColor.black
      textView.font = UIFont.systemFont(ofSize: 14)
    }
  }
}
