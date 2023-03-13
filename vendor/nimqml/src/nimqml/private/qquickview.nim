proc setup*(self: QQuickView) =
  ## Setup a new QQuickView
  self.vptr = dos_qquickview_create()

proc delete*(self: QQuickView) =
  ## Delete the given QQuickView
  if self.vptr.isNil:
    return
  debugMsg("QQuickView", "delete")
  dos_qquickview_delete(self.vptr)
  self.vptr.resetToNil

proc newQQuickView*(): QQuickView =
  ## Return a new QQuickView
  new(result, delete)
  result.setup()

proc source*(self: QQuickView): string =
  ## Return the source Qml file loaded by the view
  let str = dos_qquickview_source(self.vptr)
  result = $str
  dos_chararray_delete(str)

proc `source=`*(self: QQuickView, filename: cstring) =
  ## Sets the source Qml file laoded by the view
  dos_qquickview_set_source(self.vptr, filename)

proc show*(self: QQuickView) =
  ## Sets the view visible
  dos_qquickview_show(self.vptr)
