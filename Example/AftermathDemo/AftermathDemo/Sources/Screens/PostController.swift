import UIKit
import Aftermath

class PostController: UIViewController, CommandProducer, ReactionProducer {

  let id: Int

  lazy var titleLabel: UILabel = {
    let label = UILabel()
    label.textColor = UIColor(hex: "999")
    label.font = UIFont.boldSystemFontOfSize(18)
    label.numberOfLines = 0

    return label
  }()

  lazy var textView: UITextView = {
    let textView = UITextView()
    textView.scrollEnabled = true
    textView.textColor = UIColor(hex: "999")
    textView.font = UIFont.systemFontOfSize(14)

    return textView
  }()

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

    title = "Post"
    setupConstrains()

    // Register reaction listener
    react(to: PostStory.Command.self, with: Reaction(
      consume: { [weak self] post in
        self?.titleLabel.text = post.title
        self?.textView.text = post.body
      },
      rescue: { [weak self] error in
        print(error)
      }))
  }

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)

    // Execute command to load a list of posts.
    execute(command: PostStory.Command(id: id))
  }

  // MARK: - Layout

  func setupConstrains() {
    titleLabel.topAnchor.constraintEqualToAnchor(view.topAnchor, constant: 20).active = true
    titleLabel.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor, constant: 20).active = true
    titleLabel.trailingAnchor.constraintEqualToAnchor(view.trailingAnchor, constant: -20).active = true

    textView.topAnchor.constraintEqualToAnchor(titleLabel.bottomAnchor, constant: 20).active = true
    textView.leadingAnchor.constraintEqualToAnchor(titleLabel.leadingAnchor).active = true
    textView.trailingAnchor.constraintEqualToAnchor(titleLabel.trailingAnchor).active = true
    textView.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor, constant: -20)
  }
}
