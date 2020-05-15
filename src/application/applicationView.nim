import NimQml

# Probably all QT classes will look like this:
QtObject:
  type ApplicationView* = ref object of QObject
    app: QApplication

  # Constructor
  proc newApplicationView*(app: QApplication): ApplicationView =
    new(result)
    result.app = app
    result.setup()

  proc setup(self: ApplicationView) =
    self.QObject.setup

  proc delete*(self: ApplicationView) =
    self.QObject.delete

  proc onExitTriggered(self: ApplicationView) {.slot.} =
    echo "exiting..."
    self.app.quit
