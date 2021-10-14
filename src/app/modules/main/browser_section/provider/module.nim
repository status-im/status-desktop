import io_interface, view
import ../io_interface as delegate_interface
export io_interface

type 
  Module* = ref object of io_interface.AccessInterface
    delegate: delegate_interface.AccessInterface
    view: View
    moduleLoaded: bool

proc newModule*(delegate: delegate_interface.AccessInterface): Module =
  result = Module()
  result.delegate = delegate
  result.view = newView(result)
  result.moduleLoaded = false

method delete*(self: Module) =
  self.view.delete

method load*(self: Module) =
  self.moduleLoaded = true
  self.delegate.providerDidLoad()

method isLoaded*(self: Module): bool =
  return self.moduleLoaded
