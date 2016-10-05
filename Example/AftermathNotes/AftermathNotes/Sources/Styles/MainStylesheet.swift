import UIKit
import Fashion

enum Styles: String {
  case Content
  case NoteDetailTitleLabel
  case NoteDetailTextView
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

    register(Styles.NoteDetailTitleLabel) { (label: UILabel) in
      label.translatesAutoresizingMaskIntoConstraints = false
      label.textColor = UIColor.blackColor()
      label.font = UIFont.boldSystemFontOfSize(16)
      label.numberOfLines = 0
    }

    register(Styles.NoteDetailTextView) { (textView: UITextView) in
      textView.translatesAutoresizingMaskIntoConstraints = false
      textView.scrollEnabled = true
      textView.editable = true
      textView.textColor = UIColor.blackColor()
      textView.font = UIFont.systemFontOfSize(14)
    }
  }
}
