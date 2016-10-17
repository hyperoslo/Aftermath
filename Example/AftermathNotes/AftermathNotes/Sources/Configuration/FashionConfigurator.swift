import Fashion

public struct FashionConfigurator: Configurator {

  public func configure() {
    let stylesheets: [Stylesheet] = [
      MainStylesheet(),
      NoteStylesheet()
    ]

    Fashion.register(stylesheets)
  }
}
