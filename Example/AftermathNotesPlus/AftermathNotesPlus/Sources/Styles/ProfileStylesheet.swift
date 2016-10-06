import Fashion

struct ProfileStylesheet: Stylesheet {

  enum Style: String, StyleConvertible {
    case NotesCountLabel
    case TodosCountLabel
  }

  func define() {
    // Custom styles

    register(Style.NotesCountLabel) { (label: UILabel) in
      label.translatesAutoresizingMaskIntoConstraints = false
      label.textColor = UIColor.blackColor()
      label.font = UIFont.systemFontOfSize(16)
      label.numberOfLines = 1
    }

    register(Style.TodosCountLabel) { (label: UILabel) in
      label.translatesAutoresizingMaskIntoConstraints = false
      label.textColor = UIColor.blackColor()
      label.font = UIFont.systemFontOfSize(16)
      label.numberOfLines = 1
    }
  }
}
