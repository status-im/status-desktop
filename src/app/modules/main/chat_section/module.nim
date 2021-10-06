import io_interface, view

export io_interface

type 
  Module* [T: DelegateInterface] = ref object of AccessInterface
    delegate: T
    view: View

proc newModule*[T](delegate: T): Module[T] =
  result = Module[T]()
  result.delegate = delegate
  result.view = newView()

method delete*[T](self: Module[T]) =
  echo "--(ChatSectionModule)--delete"
  self.view.delete

method load*[T](self: Module[T]) =
  echo "--(ChatSectionModule)--load"
  self.delegate.didLoad()
