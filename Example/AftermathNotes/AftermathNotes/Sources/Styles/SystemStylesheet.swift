import UIKit
import Fashion

struct SystemStylesheet: Stylesheet {

  func define() {
    UIApplication.sharedApplication().statusBarStyle = .Default

    share { (window: UIWindow) in
      window.backgroundColor = UIColor.whiteColor()
    }

    share { (navigationBar: UINavigationBar) in
      navigationBar.translucent = true
      navigationBar.barTintColor = UIColor.whiteColor()
    }

    share { (tableView: UITableView) in
      tableView.tableFooterView = UIView(frame: CGRect.zero)
    }

    share { (cell: UITableViewCell) in
      let selectionView = UIView()
      selectionView.backgroundColor = UIColor.lightTextColor()
      cell.selectedBackgroundView = selectionView
    }
  }
}
