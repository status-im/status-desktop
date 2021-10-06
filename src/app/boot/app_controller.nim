import ../modules/main/module as main_module

type 
  AppController* = ref object of DelegateInterface 
    mainModule: main_module.AccessInterface

proc newAppController*(): AppController =
  result = AppController()
  result.mainModule = main_module.newModule(result)

proc delete*(self: AppController) =
  echo "--(AppController)--delete"
  self.mainModule.delete

method didLoad*(self: AppController) =
  echo "--(AppController)--didLoad"

proc load*(self: AppController) =
  echo "--(AppController)--load"
  self.mainModule.load()