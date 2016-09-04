import UIKit
import Spots
import Brick
import Aftermath

protocol ReactionMixin: ReactionProducer {
  func injectReaction(to controller: SpotsController)
}

struct ComponentReloadMixin<R: Command where R.Output == [Component]>: ReactionMixin {

  let reload: R

  func injectReaction(to controller: SpotsController) {
    react(to: R.self, with: ComponentReloadBuilder(controller: controller).buildReaction())
  }
}

struct SpotReloadMixin<R: Command where R.Output == [ViewModel]>: ReactionMixin {

  let index: Int
  let reload: R

  func injectReaction(to controller: SpotsController) {
    react(to: R.self, with: SpotReloadBuilder(index: index, controller: controller).buildReaction())
  }
}
