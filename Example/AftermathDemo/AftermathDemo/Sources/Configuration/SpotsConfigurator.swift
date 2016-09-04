import Spots

public struct SpotsConfigurator: Configurator {

  public func configure() {
    SpotsController.configure = {
      $0.backgroundColor = UIColor.clearColor()
    }

    ListSpot.configure = { tableView in
      let inset: CGFloat = 15

      tableView.backgroundColor = UIColor.whiteColor()
      tableView.layoutMargins = UIEdgeInsetsZero
      tableView.tableFooterView = UIView(frame: CGRect.zero)
      tableView.separatorInset = UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
      tableView.separatorStyle = .SingleLine
    }

    ListSpot.register(defaultView: TableCell.self)
  }
}
