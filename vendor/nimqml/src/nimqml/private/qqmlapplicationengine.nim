proc setup*(self: QQmlApplicationEngine) =
  ## Setup a QQmlApplicationEngine
  self.vptr = dos_qqmlapplicationengine_create()

proc loadData*(self: QQmlApplicationEngine, data: string) =
  ## Load the given data
  dos_qqmlapplicationengine_load_data(self.vptr, data.cstring)

proc load*(self: QQmlApplicationEngine, filename: string) =
  ## Load the given Qml file
  dos_qqmlapplicationengine_load(self.vptr, filename.cstring)

proc load*(self: QQmlApplicationEngine, url: QUrl) =
  ## Load the given Qml file
  dos_qqmlapplicationengine_load_url(self.vptr, url.vptr)

proc addImportPath*(self: QQmlApplicationEngine, path: string) =
  ## Add an import path
  dos_qqmlapplicationengine_add_import_path(self.vptr, path.cstring)

proc setRootContextProperty*(self: QQmlApplicationEngine, name: string, value: QVariant) =
  ## Set a root context property
  let context = dos_qqmlapplicationengine_context(self.vptr)
  dos_qqmlcontext_setcontextproperty(context, name.cstring, value.vptr)

proc setTranslationPackage*(self: QQmlApplicationEngine, packagePath: string) =
  dos_qapplication_load_translation(self.vptr, packagePath.cstring)

proc delete*(self: QQmlApplicationEngine) =
  ## Delete the given QQmlApplicationEngine
  debugMsg("QQmlApplicationEngine", "delete")
  if self.vptr.isNil:
    return
  dos_qqmlapplicationengine_delete(self.vptr)
  self.vptr.resetToNil

proc newQQmlApplicationEngine*(): QQmlApplicationEngine =
  ## Return a new QQmlApplicationEngine
  new(result, delete)
  result.setup()
