import io_interface, view

export io_interface

type 
  Module* [T: DelegateInterface] = ref object of AccessInterface
    delegate: T
    view: View
    moduleLoaded: bool

proc newModule*[T](delegate: T): Module[T] =
  result = Module[T]()
  result.delegate = delegate
  result.view = newView()
  result.moduleLoaded = false

method delete*[T](self: Module[T]) =
  echo "--(CommunitySectionModule)--delete"
  self.view.delete

method load*[T](self: Module[T]) =
  echo "--(CommunitySectionModule)--load"
  self.moduleLoaded = true
  self.delegate.communitySectionDidLoad("SectionName")

method isLoaded*[T](self: Module[T]): bool =
  return self.moduleLoaded