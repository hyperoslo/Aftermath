import UIKit
import Spots
import Aftermath

class PostsController: SpotsController, ReactionProducer, CommandProducer {

  // MARK: - Initialization

  required init() {
    super.init(spots: [ListSpot()])
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  required init(spots: [Spotable]) {
    fatalError("init(spots:) has not been implemented")
  }

  deinit {
    disposeAll()
  }

  // MARK: - View Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()
    spotsRefreshDelegate = self
    subscribe()
  }

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    execute(PostsStory.Command())
  }

  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    disposeAll()
  }

  // MARK: - Reactions

  func subscribe() {
    react(
      to: PostsStory.Command.self,
      progress: { [weak self] in
        self?.refreshControl.beginRefreshing()
      },
      done: { [weak self] items in
        self?.spot?.reloadIfNeeded(items)
      },
      fail: { error in
        // Show error
      },
      complete: {
        self.refreshControl.endRefreshing()
      }
    )
  }
}

extension PostsController: SpotsRefreshDelegate {

  func spotsDidReload(refreshControl: UIRefreshControl, completion: Completion) {
    execute(PostsStory.Command())
    completion?()
  }
}
