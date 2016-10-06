import UIKit
import Aftermath

class NoteDetailController: UIViewController, CommandProducer, ReactionProducer {
  let id: Int

  var note: Note? {
    didSet {
      guard let note = note else {
        return
      }

      titleLabel.text = note.title.capitalizedString
      textView.text = note.body.capitalizedString
    }
  }

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
    execute(command: DetailCommand<NoteFeature>(id: id))
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
        self?.note = note
      },
      rescue: { [weak self] error in
        self?.showAlert(message: (error as NSError).description)
      })

    react(to: DetailCommand<NoteFeature>.self, with: reaction)
    react(to: UpdateCommand<NoteFeature>.self, with: reaction)
  }

  // MARK: - Actions

  func saveButtonDidPress() {
    guard var note = note, let title = titleLabel.text, body = textView.text else {
      return
    }

    note.title = title
    note.body = body

    execute(command: UpdateCommand<NoteFeature>(model: note))
  }
}
