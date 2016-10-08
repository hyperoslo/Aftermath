import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  lazy var window: UIWindow? = {
    let window = UIWindow(frame: UIScreen.mainScreen().bounds)
    return window
  }()

  var configurators: [Configurator] = [
    // Use Fashion to share and reuse UI styles.
    FashionConfigurator(),
    // Use Malibu for networking.
    MalibuConfigurator(),
    // Use Aftermath to establish command-event flow in the app.
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

  // MARK: - Application lifecycle

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
