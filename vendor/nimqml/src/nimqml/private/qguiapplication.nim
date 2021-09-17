import os

proc setup*(self: QGuiApplication) =
  ## Setup a new QGuiApplication
  dos_qguiapplication_create()
  self.deleted = false

proc delete*(self: QGuiApplication) =
  ## Delete the given QGuiApplication
  if self.deleted:
    return
  debugMsg("QGuiApplication", "delete")
  dos_qguiapplication_delete()
  self.deleted = true

proc icon*(application: QGuiApplication, filename: string) =
  dos_qguiapplication_icon(filename.cstring)

proc installEventFilter*(application: QGuiApplication, event: StatusEvent) =
  dos_qguiapplication_installEventFilter(event.vptr)

proc newQGuiApplication*(): QGuiApplication =
  ## Return a new QGuiApplication
  new(result, delete)
  result.setup()

proc exec*(self: QGuiApplication) =
  ## Start the Qt event loop
  dos_qguiapplication_exec()

proc quit*(self: QGuiApplication) =
  ## Quit the Qt event loop
  dos_qguiapplication_quit()

proc setClipboardText*(text: string = "") =
  dos_qguiapplication_clipboard_setText(text.cstring)

proc setClipboardImage*(text: string = "") =
  dos_qguiapplication_clipboard_setImage(text.cstring)

proc downloadImage*(imageSource: string = "", filePath = "") =
  dos_qguiapplication_download_image(imageSource.cstring, filePath.cstring)

proc enableHDPI*(uiScaleFilePath: string) =
  dos_qguiapplication_enable_hdpi(uiScaleFilePath)

proc initializeOpenGL*() =
  dos_qguiapplication_initialize_opengl()
  
proc applicationDirPath*(app: QGuiApplication): string =
  let str = dos_qguiapplication_application_dir_path()
  result = $str
  dos_chararray_delete(str)
