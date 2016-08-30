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
      progress: {
        controller.refreshControl.beginRefreshing()
      },
      done: { (projection: UsersStory.Projection) in
        controller.refreshControl.endRefreshing()
        controller.spot?.reloadIfNeeded(projection.items)
      },
      fail: { error in
        // Show error
    })
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
