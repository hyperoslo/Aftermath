import UIKit

class MainController: UITabBarController {

  lazy var noteListController: UINavigationController = {
    let controller = ListController(feature: NoteFeature())
    let navigationController = UINavigationController(rootViewController: controller)
    controller.view.stylize(Styles.Content)
    controller.tabBarItem.title = "Notes"
    controller.tabBarItem.image = UIImage(named: "tabNotes")

    return navigationController
  }()

  lazy var todoListController: UINavigationController = {
    let controller = ListController(feature: TodoFeature())
    let navigationController = UINavigationController(rootViewController: controller)
    controller.view.stylize(Styles.Content)
    controller.tabBarItem.title = "Todos"
    controller.tabBarItem.image = UIImage(named: "tabTodos")

    return navigationController
  }()

  // MARK: - View Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()

    title = "Aftermath"
    view.stylize(Styles.Content)
    configureTabBar()
  }

  // MARK: - Configuration

  func configureTabBar() {
    viewControllers = [
      noteListController,
      todoListController
    ]

    selectedIndex = 0
  }
}
