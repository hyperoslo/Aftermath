import Aftermath

public struct AftermathConfigurator: Configurator {

  public func configure() {
    Engine.sharedInstance.use(PostsStory.Handler())
    Engine.sharedInstance.use(UsersStory.Handler())
  }
}
