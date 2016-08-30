import UIKit
import Spots
import Aftermath

class UsersController: SpotsController, ReactionProducer, CommandProducer {

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
    execute(UsersStory.Command())
  }

  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    disposeAll()
  }

  // MARK: - Reactions

  func subscribe() {
    react(
      to: UsersStory.Command.self,
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

extension UsersController: SpotsRefreshDelegate {

  func spotsDidReload(refreshControl: UIRefreshControl, completion: Completion) {
    execute(UsersStory.Command())
    completion?()
  }
}
