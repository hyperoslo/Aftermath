import Aftermath
import Malibu

struct NoteListStory {

  struct Command: Aftermath.Command {
    typealias Output = [Note]
  }

  struct Request: GETRequestable {
    var message = Message(resource: "posts")
  }

  struct Handler: Aftermath.CommandHandler {

    func handle(command: Command) throws -> Event<Command> {
      let request = Request()

      Malibu.networking("base").GET(request)
        .validate()
        .toJSONArray()
        .then({ array -> [Note] in try array.map({ try Note($0) }) })
        .done({ notes in
          self.publish(data: notes)
        })
        .fail({ error in
          self.publish(error: error)
        })

      return Event.Progress
    }
  }
}
