proc setup*(application: QApplication) =
  ## Setup a new QApplication
  dos_qapplication_create()
  application.deleted = false

proc exec*(application: QApplication) =
  ## Start the Qt event loop
  dos_qapplication_exec()

proc quit*(application: QApplication) =
  ## Quit the Qt event loop
  dos_qapplication_quit()

proc icon*(application: QApplication, filename: string) =
  dos_qapplication_icon(filename.cstring)

proc setClipboardText*(text: string = "") =
  dos_qapplication_clipboard_setText(text.cstring)

proc installEventFilter*(application: QApplication, event: StatusEventObject) =
  dos_qapplication_installEventFilter(event.vptr)

proc delete*(application: QApplication) =
  ## Delete the given QApplication
  if application.deleted:
    return
  debugMsg("QApplication", "delete")
  dos_qapplication_delete()
  application.deleted = true

proc newQApplication*(): QApplication =
  ## Return a new QApplication
  new(result, delete)
  result.setup()
