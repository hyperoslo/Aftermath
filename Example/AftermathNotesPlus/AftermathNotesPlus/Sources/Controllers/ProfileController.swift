import UIKit
import Aftermath

class ProfileController: UIViewController, CommandProducer, ReactionProducer {

  lazy var notesCountLabel: UILabel = UILabel(styles: ProfileStylesheet.Style.notesCountLabel)
  lazy var todosCountLabel: UILabel = UILabel(styles: ProfileStylesheet.Style.todosCountLabel)

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

    view.stylize(MainStylesheet.Style.content)
    updateText()

    [notesCountLabel, todosCountLabel].forEach {
      self.view.addSubview($0)
    }

    setupConstrains()
  }

  // MARK: - Layout

  func setupConstrains() {
    notesCountLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 84).isActive = true
    notesCountLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
    notesCountLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true

    todosCountLabel.topAnchor.constraint(equalTo: notesCountLabel.bottomAnchor, constant: 20).isActive = true
    todosCountLabel.leadingAnchor.constraint(equalTo: notesCountLabel.leadingAnchor).isActive = true
    todosCountLabel.trailingAnchor.constraint(equalTo: notesCountLabel.trailingAnchor).isActive = true
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
