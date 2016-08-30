import Compass
import Sugar

struct CompassConfigurator: Configurator {

  func configure() {
    Compass.scheme = "aftermath"

    Compass.routes = [
      "tabs:{index}"
    ]
  }
}
