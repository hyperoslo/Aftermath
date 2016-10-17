import Aftermath

public struct AftermathConfigurator: Configurator {

  // Don't forget to register your command handlers.
  // You can also use https://github.com/hyperoslo/AftermathTools to monitor warnings and errors.
  public func configure() {
    // Note command handlers
    Engine.sharedInstance.use(ListCommandHandler(feature: NoteFeature()))
    Engine.sharedInstance.use(DetailCommandHandler(feature: NoteFeature()))
    Engine.sharedInstance.use(UpdateCommandHandler(feature: NoteFeature()))
    Engine.sharedInstance.use(DeleteCommandHandler(feature: NoteFeature()))

    // Todo command handlers
    Engine.sharedInstance.use(ListCommandHandler(feature: TodoFeature()))
    Engine.sharedInstance.use(UpdateCommandHandler(feature: TodoFeature()))
    Engine.sharedInstance.use(DeleteCommandHandler(feature: TodoFeature()))
  }
}
