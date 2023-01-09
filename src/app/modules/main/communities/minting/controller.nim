import ./io_interface as minting_module_interface

import ../../../../core/signals/types
import ../../../../core/eventemitter

type
  Controller* = ref object of RootObj
    mintingModule: minting_module_interface.AccessInterface
    events: EventEmitter

proc newMintingController*(
    mintingModule: minting_module_interface.AccessInterface,
    events: EventEmitter
    ): Controller =
  result = Controller()
  result.mintingModule = mintingModule
  result.events = events

proc delete*(self: Controller) =
  discard

proc init*(self: Controller) =
  discard

