import NimQml, Tables
import eventemitter

import ./io_interface, ./view, ./controller
import ../../../../core/global_singleton
import status/types/[installation]

import ../../../../../app_service/service/devicesync/service as devicesync_service

export io_interface

type 
  Module* [T: io_interface.DelegateInterface] = ref object of io_interface.AccessInterface
    delegate: T
    controller: controller.AccessInterface
    view: View
    viewVariant: QVariant
    moduleLoaded: bool

proc newModule*[T](delegate: T,
  events: EventEmitter,
  deviceSyncService: devicesync_service.ServiceInterface
  ): Module[T] =
  result = Module[T]()
  result.delegate = delegate
  result.view = newView(result)
  result.viewVariant = newQVariant(result.view)
  result.controller = controller.newController[Module[T]](result, events, deviceSyncService)
  result.moduleLoaded = false

method delete*[T](self: Module[T]) =
  self.view.delete

method load*[T](self: Module[T]) =
  singletonInstance.engine.setRootContextProperty("deviceSyncModule", self.viewVariant)

  self.controller.init()

  self.view.addDevices(self.controller.getAllDevices())
  self.view.setDeviceSetup(self.controller.isDeviceSetup())

  self.moduleLoaded = true

method isLoaded*[T](self: Module[T]): bool =
  return self.moduleLoaded

method syncAllDevices*[T](self: Module[T]) =
  self.controller.syncAllDevices()

method addDevices*[T](self: Module[T], installations: seq[Installation]) =
  self.view.addDevices(installations)

method advertiseDevice*[T](self: Module[T]) =
  self.controller.advertiseDevice()

method enableInstallation*[T](self: Module[T], installationId: string, enable: bool) =
  self.controller.enableInstallation(installationId, enable)
