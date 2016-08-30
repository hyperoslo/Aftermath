import UIKit
import Spots
import Aftermath

final class PostsPresenter: SpotsPresenter, ReactionProducer, CommandProducer {

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
      done: { (projection: PostsStory.Projection) in
        controller.refreshControl.endRefreshing()
        controller.spot?.reloadIfNeeded(projection.items)
      },
      fail: { error in
        // Show error
    })
  }

  func controllerWillAppear(controller: SpotsController) {
    execute(PostsStory.Command())
  }
}

extension PostsPresenter: SpotsRefreshDelegate {

  func spotsDidReload(refreshControl: UIRefreshControl, completion: Completion) {
    execute(PostsStory.Command())
    completion?()
  }
}
