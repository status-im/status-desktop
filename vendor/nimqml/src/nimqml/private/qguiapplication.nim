proc setup*(self: QGuiApplication) =
  ## Setup a new QApplication
  dos_qguiapplication_create()
  self.deleted = false

proc delete*(self: QGuiApplication) =
  ## Delete the given QApplication
  if self.deleted:
    return
  debugMsg("QApplication", "delete")
  dos_qguiapplication_delete()
  self.deleted = true

proc newQGuiApplication*(): QGuiApplication =
  ## Return a new QApplication
  new(result, delete)
  result.setup()

proc exec*(self: QGuiApplication) =
  ## Start the Qt event loop
  dos_qguiapplication_exec()

proc quit*(self: QGuiApplication) =
  ## Quit the Qt event loop
  dos_qguiapplication_quit()
