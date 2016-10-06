import Fashion

public struct FashionConfigurator: Configurator {

  public func configure() {
    let stylesheets: [Stylesheet] = [
      SystemStylesheet(),
      MainStylesheet()
    ]

    Fashion.register(stylesheets)
  }
}
