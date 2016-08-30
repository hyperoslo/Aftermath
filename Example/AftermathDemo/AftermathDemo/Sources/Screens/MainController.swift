import UIKit

class MainController: UITabBarController {

  lazy var postsController: UINavigationController = {
    let controller = AftermathController()
    let navigationController = UINavigationController(rootViewController: controller)
    controller.tabBarItem.title = "Wall"
    controller.tabBarItem.image = UIImage(named: "tabPosts")

    return navigationController
  }()

  lazy var usersController: UINavigationController = {
    let controller = AftermathController()
    let navigationController = UINavigationController(rootViewController: controller)
    controller.tabBarItem.title = "Users"
    controller.tabBarItem.image = UIImage(named: "tabUsers")

    return navigationController
  }()

  // MARK: - View Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()
    configureTabBar()
  }

  // MARK: - Configuration

  func configureTabBar() {
    tabBar.translucent = true
    tabBar.tintColor = UIColor(hex: "F57D2D")

    viewControllers = [
      postsController,
      usersController
    ]

    selectedIndex = 0
  }
}
