import UIKit
import Spots
import Brick
import Aftermath

struct ComponentReloadBuilder: ReactionBuilder {

  weak var controller: SpotsController?

  func buildReaction() -> Reaction<[Component]> {
    return Reaction(
      progress: {
        self.controller?.refreshControl.beginRefreshing()
      },
      done: { (components: [Component]) in
        self.controller?.reloadIfNeeded(components)
      },
      fail: { error in
        // Show error
      },
      complete: {
        self.controller?.refreshControl.endRefreshing()
      }
    )
  }
}

struct SpotReloadBuilder: ReactionBuilder {

  let index: Int
  weak var controller: SpotsController?

  func buildReaction() -> Reaction<[ViewModel]> {
    return Reaction(
      progress: {
        self.controller?.refreshControl.beginRefreshing()
      },
      done: { (viewModels: [ViewModel]) in
        self.controller?.spot(self.index, Spotable.self)?.reloadIfNeeded(viewModels)
      },
      fail: { error in
        // Show error
      },
      complete: {
        self.controller?.refreshControl.endRefreshing()
      }
    )
  }
}
