import Aftermath
import Malibu

struct NoteListStory {

  // MARK: - Command

  struct Command: Aftermath.Command {
    typealias Output = [Note]
  }

  // MARK: - Request

  struct Request: GETRequestable {
    var message = Message(resource: "posts")
  }

  // MARK: - Command handler

  class Handler: Aftermath.CommandHandler {

    var isFetched = false

    func handle(command: Command) throws -> Event<Command> {
      // Load data from cache storage.
      loadLocalData()

      // Make network request to fetch updated data.
      isFetched = false
      refresh()

      return Event.progress
    }

    func loadLocalData() {
      PayloadStorage.sharedInstance.load(key: Note.identifier) { array in
        guard let array = array, !self.isFetched else {
          return
        }

        do {
          let notes = try array.map({ try Note($0) })
          self.publish(data: notes)
        } catch {
          self.publish(error: error)
        }
      }
    }

    func refresh() {
      let request = Request()

      Malibu.networking("base").GET(request)
        .validate()
        .toJsonArray()
        .then({ array -> [Note] in
          PayloadStorage.sharedInstance.save(array: array, with: Note.identifier)
          return try array.map({
            try Note($0)
          })
        })
        .done({ notes in
          self.isFetched = true
          self.publish(data: notes)
        })
        .fail({ error in
          self.isFetched = false
          self.publish(error: error)
        })
    }
  }
}
