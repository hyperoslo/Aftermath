import Fashion

public struct FashionConfigurator: Configurator {

  public func configure() {
    let stylesheets: [Stylesheet] = [
      MainStylesheet(),
      NoteStylesheet(),
      ProfileStylesheet()
    ]

    Fashion.register(stylesheets)
  }
}
