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

proc installSelfSignedCertificate*(certificate: string) =
  dos_add_self_signed_certificate(certificate.cstring)

proc installEventFilter*(application: QApplication, event: StatusEvent) =
  dos_qapplication_installEventFilter(event.vptr)

proc setClipboardImage*(text: string = "") =
  dos_qapplication_clipboard_setImage(text.cstring)

proc downloadImage*(imageSource: string = "", filePath = "") =
  dos_qapplication_download_image(imageSource.cstring, filePath.cstring)

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
