import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  lazy var window: UIWindow? = {
    let window = UIWindow(frame: UIScreen.mainScreen().bounds)
    return window
  }()

  var configurators: [Configurator] = [
    FashionConfigurator(),
    MalibuConfigurator(),
    AftermathConfigurator()
  ]

  lazy var navigationController: UINavigationController = { [unowned self] in
    let controller = UINavigationController(rootViewController: self.mainController)
    return controller
    }()

  lazy var mainController: NoteListController = {
    let controller = NoteListController()
    return controller
  }()

  func application(application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    window?.rootViewController = navigationController

    configurators.forEach {
      $0.configure()
    }

    window?.makeKeyAndVisible()

    return true
  }
}
