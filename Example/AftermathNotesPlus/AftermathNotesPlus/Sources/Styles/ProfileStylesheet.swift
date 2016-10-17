import Fashion

struct ProfileStylesheet: Stylesheet {

  enum Style: String, StyleConvertible {
    case notesCountLabel
    case todosCountLabel
  }

  func define() {
    // Custom styles

    register(Style.notesCountLabel) { (label: UILabel) in
      label.translatesAutoresizingMaskIntoConstraints = false
      label.textColor = UIColor.black
      label.font = UIFont.systemFont(ofSize: 16)
      label.numberOfLines = 1
    }

    register(Style.todosCountLabel) { (label: UILabel) in
      label.translatesAutoresizingMaskIntoConstraints = false
      label.textColor = UIColor.black
      label.font = UIFont.systemFont(ofSize: 16)
      label.numberOfLines = 1
    }
  }
}
