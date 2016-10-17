import UIKit
import Fashion

struct MainStylesheet: Stylesheet {

  enum Style: String, StyleConvertible {
    case content
  }

  func define() {
    UIApplication.shared.statusBarStyle = .default

    // Shared styles

    share { (window: UIWindow) in
      window.backgroundColor = UIColor.white
    }

    share { (navigationBar: UINavigationBar) in
      navigationBar.isTranslucent = true
      navigationBar.barTintColor = UIColor.white
    }

    share { (tabBar: UITabBar) in
      tabBar.isTranslucent = true
    }

    share { (tableView: UITableView) in
      tableView.tableFooterView = UIView(frame: CGRect.zero)
    }

    share { (cell: UITableViewCell) in
      let selectionView = UIView()
      selectionView.backgroundColor = UIColor.lightText
      cell.selectedBackgroundView = selectionView
    }

    // Custom styles

    register(Style.content) { (view: UIView) in
      view.backgroundColor = UIColor.white
    }
  }
}
