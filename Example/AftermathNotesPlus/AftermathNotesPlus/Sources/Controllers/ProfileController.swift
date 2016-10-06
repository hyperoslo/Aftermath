import UIKit
import Aftermath

class ProfileController: UIViewController, CommandProducer, ReactionProducer {

  lazy var notesCountLabel: UILabel = UILabel(styles: ProfileStylesheet.Style.NotesCountLabel)
  lazy var todosCountLabel: UILabel = UILabel(styles: ProfileStylesheet.Style.TodosCountLabel)

  var profile: Profile {
    didSet {
      updateText()
    }
  }

  // MARK: - Initialization

  required init() {
    profile = Profile(name: "Aftermath", notesCount: 0, todosCount: 0)
    super.init(nibName: nil, bundle: nil)
    setupReactions()
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

    view.stylize(MainStylesheet.Style.Content)
    updateText()

    [notesCountLabel, todosCountLabel].forEach {
      self.view.addSubview($0)
    }

    setupConstrains()
  }

  // MARK: - Layout

  func setupConstrains() {
    notesCountLabel.topAnchor.constraintEqualToAnchor(view.topAnchor, constant: 84).active = true
    notesCountLabel.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor, constant: 20).active = true
    notesCountLabel.trailingAnchor.constraintEqualToAnchor(view.trailingAnchor, constant: -20).active = true

    todosCountLabel.topAnchor.constraintEqualToAnchor(notesCountLabel.bottomAnchor, constant: 20).active = true
    todosCountLabel.leadingAnchor.constraintEqualToAnchor(notesCountLabel.leadingAnchor).active = true
    todosCountLabel.trailingAnchor.constraintEqualToAnchor(notesCountLabel.trailingAnchor).active = true
  }

  // MARK: - Reactions

  func setupReactions() {
    // React to note events
    react(to: ListCommand<NoteFeature>.self, with: Reaction(
      consume: { [weak self] models in
        self?.profile.notesCount = models.count
      }))

    react(to: DeleteCommand<NoteFeature>.self, with: Reaction(
      consume: { [weak self] id in
        self?.profile.notesCount -= 1
      }))

    // React to todo events
    react(to: ListCommand<TodoFeature>.self, with: Reaction(
      consume: { [weak self] models in
        self?.profile.todosCount = models.count
      }))

    react(to: DeleteCommand<TodoFeature>.self, with: Reaction(
      consume: { [weak self] id in
        self?.profile.todosCount -= 1
      }))
  }

  // MARK: - UI

  func updateText() {
    notesCountLabel.text = "Total notes: \(profile.notesCount)"
    todosCountLabel.text = "Total todos: \(profile.todosCount)"
  }
}
