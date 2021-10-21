import NimQml
import io_interface
import ../io_interface as delegate_interface
import item
import view
import controller
import ../../../../core/global_singleton
import ../../../../../app_service/service/bookmarks/service as bookmark_service

export io_interface

type 
  Module* = ref object of io_interface.AccessInterface
    delegate: delegate_interface.AccessInterface
    view: View
    viewVariant: QVariant
    moduleLoaded: bool
    controller: controller.AccessInterface

proc newModule*(delegate: delegate_interface.AccessInterface, bookmarkService: bookmark_service.ServiceInterface): Module =
  result = Module()
  result.delegate = delegate
  result.view = view.newView(result)
  result.viewVariant = newQVariant(result.view)
  result.moduleLoaded = false
  result.controller = controller.newController(result, bookmarkService)

method delete*(self: Module) =
  self.view.delete
  self.viewVariant.delete
  self.controller.delete

method load*(self: Module) =
  singletonInstance.engine.setRootContextProperty("bookmarkModule", self.viewVariant)
  self.view.load()
  let bookmarks = self.controller.getBookmarks()
  for b in bookmarks:
    self.view.addItem(initItem(b.name, b.url, b.imageUrl))

method isLoaded*(self: Module): bool =
  return self.moduleLoaded

proc checkIfModuleDidLoad(self: Module) =
  self.moduleLoaded = true
  self.delegate.bookmarkDidLoad()

method providerDidLoad*(self: Module) =
  self.checkIfModuleDidLoad()

method viewDidLoad*(self: Module) =
  self.checkIfModuleDidLoad()

method storeBookmark*(self: Module, url: string, name: string) =
  if url == "":
    self.view.addItem(initItem(name, url, "")) # These URLs are not stored but added direclty to the UI
  else:
    self.controller.storeBookmark(url, name)

method onBoomarkStored*(self: Module, url: string, name: string, imageUrl: string) =
  self.view.addItem(initItem(name, url, imageUrl))

method deleteBookmark*(self: Module, url: string) =
  self.controller.deleteBookmark(url)

method onBookmarkDeleted*(self: Module, url: string) =
  self.view.removeBookmarkByUrl(url)

method updateBookmark*(self: Module, oldUrl: string, newUrl: string, newName: string) =
  self.controller.updateBookmark(oldUrl, newUrl, newName)

method onBookmarkUpdated*(self: Module, oldUrl: string, newUrl: string, newName: string, newImageUrl: string) =
  self.view.updateBookmarkByUrl(oldUrl, initItem(newName, newUrl, newImageUrl))
