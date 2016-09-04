import UIKit
import Spots
import Brick
import Aftermath

class AftermathController: SpotsController, CommandProducer {

  let initialCommand: AnyCommand?
  var mixins = [ReactionMixin]()

  // MARK: - Initialization

  required init(initialCommand: AnyCommand? = nil, mixins: [ReactionMixin] = []) {
    self.initialCommand = initialCommand
    self.mixins = mixins

    super.init(spots: [])

    for mixin in mixins {
      mixin.injectReaction(to: self)
    }
  }

  convenience init<R: Command where R.Output == [Component]>(componentCommand: R, mixins: [ReactionMixin] = []) {
    self.init(initialCommand: componentCommand, mixins: mixins)
    ComponentReloadMixin(reload: componentCommand).injectReaction(to: self)
  }

  convenience init<R: Command where R.Output == [ViewModel]>(spotCommand: R, mixins: [ReactionMixin] = []) {
    self.init(initialCommand: spotCommand, mixins: mixins)
    SpotReloadMixin(index: 0, reload: spotCommand).injectReaction(to: self)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  required init(spots: [Spotable]) {
    fatalError("init(spots:) has not been implemented")
  }

  deinit {
    disposeReactions()
  }

  // MARK: - View Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()
    spotsRefreshDelegate = self
  }

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)

    if let initialCommand = initialCommand {
      execute(initialCommand)
    }
  }

  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    disposeReactions()
  }

  func executeInitial() {
    if let initialCommand = initialCommand {
      execute(initialCommand)
    }
  }

  func disposeReactions() {
    mixins.forEach {
      $0.disposeAll()
    }
  }
}

extension AftermathController: SpotsRefreshDelegate {

  func spotsDidReload(refreshControl: UIRefreshControl, completion: Completion) {
    executeInitial()
    completion?()
  }
}
