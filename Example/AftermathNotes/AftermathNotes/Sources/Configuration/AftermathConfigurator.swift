import Aftermath

public struct AftermathConfigurator: Configurator {

  public func configure() {
    Engine.sharedInstance.use(NoteListStory.Handler())
    Engine.sharedInstance.use(NoteDetailStory.Handler())
    Engine.sharedInstance.use(NoteUpdateStory.Handler())
  }
}
