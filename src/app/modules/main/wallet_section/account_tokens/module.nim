import ./io_interface, ./view

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
  self.view.delete

method load*[T](self: Module[T]) =
  self.moduleLoaded = true

method isLoaded*[T](self: Module[T]): bool =
  return self.moduleLoaded
