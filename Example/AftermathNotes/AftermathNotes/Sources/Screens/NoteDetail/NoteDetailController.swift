import UIKit
import Aftermath

class NoteDetailController: UIViewController, CommandProducer, ReactionProducer {

  let id: Int
  var loaded = false

  lazy var saveButton: UIBarButtonItem = UIBarButtonItem(
    barButtonSystemItem: .save,
    target: self,
    action: #selector(saveButtonDidPress))

  lazy var titleLabel: UILabel = UILabel(styles: NoteStylesheet.Style.detailTitleLabel)
  lazy var textView: UITextView = UITextView(styles: NoteStylesheet.Style.detailTextView)

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
    view.stylize(MainStylesheet.Style.content)
    navigationItem.rightBarButtonItem = saveButton

    [titleLabel, textView].forEach {
      self.view.addSubview($0)
    }

    setupConstrains()
    setupReactions()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    // Execute command to load a single note.
    execute(command: NoteDetailStory.Command(id: id))
  }

  // MARK: - Layout

  func setupConstrains() {
    titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 84).isActive = true
    titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
    titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true

    textView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor).isActive = true
    textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15).isActive = true
    textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15).isActive = true
    textView.heightAnchor.constraint(equalToConstant: 200).isActive = true
  }

  // MARK: - Reactions

  func setupReactions() {
    // Register reaction listeners
    let reaction = Reaction<Note>(
      consume: { [weak self] note in
        self?.titleLabel.text = note.title.capitalized
        self?.textView.text = note.body

        if self?.loaded == true {
          self?.showAlert(title: "Yay!", message: "Note is saved.")
        }

        self?.loaded = true
      },
      rescue: { [weak self] error in
        self?.showAlert(error: error)
      })

    react(to: NoteDetailStory.Command.self, with: reaction)
    react(to: NoteUpdateStory.Command.self, with: reaction)
  }

  // MARK: - Actions

  func saveButtonDidPress() {
    guard let title = titleLabel.text, let body = textView.text else {
      return
    }

    execute(command: NoteUpdateStory.Command(id: id, title: title, body: body))
  }
}
