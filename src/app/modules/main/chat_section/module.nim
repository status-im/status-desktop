import io_interface, view

export io_interface

type 
  Module* [T: DelegateInterface] = ref object of AccessInterface
  #Module* [T: DelegateInterface] = ref object
    delegate: T
    view: View

proc newModule*[T](delegate: T): Module[T] =
#proc newModule*[T](): Module[T] =
  result = Module[T]()
  result.delegate = delegate
  result.view = newView()

# method setDelegate*(self: Module, delegate: DelegateInterface) =
#   self.delegate = delegate

method delete*(self: Module) =
  echo "--(ChatSection)--delete"
  self.view.delete

method load*(self: Module) =
  echo "--(ChatSection)--load"
  self.delegate.didLoad()