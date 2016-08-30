import UIKit
import Spots
import Aftermath

final class UsersPresenter: SpotsPresenter, ReactionProducer, CommandProducer {

  let spots: [Spotable]

  init() {
    spots = [ListSpot()]
  }

  func subscribe(controller: SpotsController) {
    // removal token
    react(
      to: UsersStory.Command.self,
      progress: {
        controller.refreshControl.beginRefreshing()
      },
      done: { items in
        controller.spot?.reloadIfNeeded(items)
      },
      fail: { error in
        // Show error
      },
      complete: {
        controller.refreshControl.endRefreshing()
      }
    )
  }

  func controllerWillAppear(controller: SpotsController) {
    execute(UsersStory.Command())
  }
}

extension UsersPresenter: SpotsRefreshDelegate {

  func spotsDidReload(refreshControl: UIRefreshControl, completion: Completion) {
    execute(UsersStory.Command())
    completion?()
  }
}
