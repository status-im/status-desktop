import controller_interface

export controller_interface

type 
  Controller*[T: controller_interface.DelegateInterface] = 
    ref object of controller_interface.AccessInterface
    delegate: T

proc newController*[T](delegate: T): Controller[T] =
  result = Controller[T]()
  result.delegate = delegate

method delete*[T](self: Controller[T]) =
  discard

method init*[T](self: Controller[T]) = 
  discard
