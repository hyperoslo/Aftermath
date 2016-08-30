import UIKit
import Spots

protocol SpotsPresenter{

  var spots: [Spotable] { get }
  func subscribe(controller: SpotsController)
  func controllerWillAppear(controller: SpotsController)
}

class AftermathController: SpotsController {

  let presenter: SpotsPresenter

  init(presenter: SpotsPresenter) {
    self.presenter = presenter
    super.init(spots: presenter.spots)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  required init(spots: [Spotable]) {
    fatalError("init(spots:) has not been implemented")
  }

  // MARK: - View Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()

    spotsDelegate = presenter as? SpotsDelegate
    spotsRefreshDelegate = presenter as? SpotsRefreshDelegate
    spotsScrollDelegate = presenter as? SpotsScrollDelegate
    presenter.subscribe(self)
  }

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    presenter.controllerWillAppear(self)
  }
}
