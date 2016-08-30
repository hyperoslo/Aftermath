import UIKit
import Spots
import Aftermath

final class PostsPresenter: SpotsPresenter, ReactionProducer, CommandProducer {

  let spots: [Spotable]

  init() {
    spots = [ListSpot()]
  }

  deinit {
    disposeAll()
  }

  func subscribe(controller: SpotsController) {
    // removal token
    react(
      to: PostsStory.Command.self,
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
    execute(PostsStory.Command())
  }
}

extension PostsPresenter: SpotsRefreshDelegate {

  func spotsDidReload(refreshControl: UIRefreshControl, completion: Completion) {
    execute(PostsStory.Command())
    completion?()
  }
}
