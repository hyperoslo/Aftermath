import UIKit
import Aftermath

class NoteDetailController: UIViewController, CommandProducer, ReactionProducer {

  let id: Int
  var loaded = false

  lazy var saveButton: UIBarButtonItem = UIBarButtonItem(
    barButtonSystemItem: .Save,
    target: self,
    action: #selector(saveButtonDidPress))

  lazy var titleLabel: UILabel = UILabel(styles: NoteStylesheet.Style.DetailTitleLabel)
  lazy var textView: UITextView = UITextView(styles: NoteStylesheet.Style.DetailTextView)

  // MARK: - Initialization

  required init(id: Int) {
    self.id = id
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  deinit {
    // Don't forget to dispose all reaction tokens.
    disposeAll()
  }

  // MARK: - View lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()

    title = "Note"
    view.stylize(MainStylesheet.Style.Content)
    navigationItem.rightBarButtonItem = saveButton

    [titleLabel, textView].forEach {
      self.view.addSubview($0)
    }

    setupConstrains()
    setupReactions()
  }

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)

    // Execute command to load a single note.
    execute(command: NoteDetailStory.Command(id: id))
  }

  // MARK: - Layout

  func setupConstrains() {
    titleLabel.topAnchor.constraintEqualToAnchor(view.topAnchor, constant: 84).active = true
    titleLabel.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor, constant: 20).active = true
    titleLabel.trailingAnchor.constraintEqualToAnchor(view.trailingAnchor, constant: -20).active = true

    textView.topAnchor.constraintEqualToAnchor(titleLabel.bottomAnchor).active = true
    textView.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor, constant: 15).active = true
    textView.trailingAnchor.constraintEqualToAnchor(view.trailingAnchor, constant: -15).active = true
    textView.heightAnchor.constraintEqualToConstant(200).active = true
  }

  // MARK: - Reactions

  func setupReactions() {
    // Register reaction listeners
    let reaction = Reaction<Note>(
      consume: { [weak self] note in
        self?.titleLabel.text = note.title.capitalizedString
        self?.textView.text = note.body.capitalizedString

        if self?.loaded == true {
          self?.showAlert(title: "Yay!", message: "Note is saved.")
        }

        self?.loaded = true
      },
      rescue: { [weak self] error in
        self?.showErrorAlert(error)
      })

    react(to: NoteDetailStory.Command.self, with: reaction)
    react(to: NoteUpdateStory.Command.self, with: reaction)
  }

  // MARK: - Actions

  func saveButtonDidPress() {
    guard let title = titleLabel.text, body = textView.text else {
      return
    }

    execute(command: NoteUpdateStory.Command(id: id, title: title, body: body))
  }
}
