import NimQml

import io_interface, view, controller
import ../../../app/boot/global_singleton

import onboarding/module as onboarding_module
import login/module as login_module

#import ../../../app_service/service/community/service as community_service

export io_interface

type 
  Module*[T: io_interface.DelegateInterface] = ref object of io_interface.AccessInterface
    delegate: T
    view: View
    viewVariant: QVariant
    controller: controller.AccessInterface
    onboardingModule: onboarding_module.AccessInterface
    loginModule: login_module.AccessInterface

#################################################
# Forward declaration section

# Controller Delegate Interface


# Onboarding Module Delegate Interface
proc onboardingDidLoad*[T](self: Module[T])

# Login Module Delegate Interface
proc loginDidLoad*[T](self: Module[T])

#################################################

proc newModule*[T](delegate: T): 
  Module[T] =
  result = Module[T]()
  result.delegate = delegate
  result.view = view.newView(result)
  result.viewVariant = newQVariant(result.view)
  result.controller = controller.newController[Module[T]](result)

  singletonInstance.engine.setRootContextProperty("startupModule", result.viewVariant)

  # Submodules
  result.onboardingModule = onboarding_module.newModule[Module[T]](result)
  result.loginModule = login_module.newModule[Module[T]](result)
  
method delete*[T](self: Module[T]) =
  self.onboardingModule.delete
  self.loginModule.delete
  self.view.delete
  self.viewVariant.delete
  self.controller.delete

method load*[T](self: Module[T]) =
  self.view.load()

method viewDidLoad*[T](self: Module[T]) =
  discard

proc checkIfModuleDidLoad[T](self: Module[T]) =
  if(not self.onboardingModule.isLoaded()):
    return

  if(not self.loginModule.isLoaded()):
    return

  self.delegate.startupDidLoad()

proc onboardingDidLoad*[T](self: Module[T]) =
  self.checkIfModuleDidLoad()

proc loginDidLoad*[T](self: Module[T]) =
  self.checkIfModuleDidLoad()