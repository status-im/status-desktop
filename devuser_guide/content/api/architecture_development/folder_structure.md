---
title : "Folder Structure"
description: "Folder Structure"
lead: ""
date: 2020-10-06T08:48:23+00:00
lastmod: 2020-10-06T08:48:23+00:00
draft: false
images: []
menu:
  api:
    parent: "architecture_development"
toc: true
---

## Stack

* 1. status-go (`src/status/libstatus`)
* 2. nim-status / business logic & persistence (`src/status`)
* 3. initializer wrapper (`src/app/<module>/core.nim`)
  * currently contains signals which should be moved into layer 2.
* 4. views & view logic (`src/app/<module>/view.nim` & `ui/*.qml`)

## Folder structure

`src/` - where most of the source is

`src/app` - Where the Application is

`src/app/<module>` - module e.g 'chat', 'profile'

`src/app/<module>/core.nim` - wrapper for this module

`src/app/<module>/view.nim` - view, exposed data and some view specific logic

`src/app/<module>/views/*` - views

`src/signals` - signals (should be refactored & moved into src/status)

`src/status` - business logic

`src/status/libstatus` - integration with status-go

`nim_status_client.nim` - the main file

`ui/` - QML files

### **`src/status`**

This folder contains the library that abstracts the status app business logic, it's how the app can interact with status-go as well as how they can obtain data, do actions etc..

* this folder can only import / call files from `src/status/libstatus` (exception for libraries ofc)
* only files in `app/` should be able to import from `src/status` (but never `src/status/libstatus`)

### **`src/status/libstatus`**

This folder abstracts the interactions with status-go

* generally this folder should only contain code related to interacting with status-go
* it should not import code from anywhere else (including `src/status`)
* nothing should call libstatus directly
* only the code in `status/` should be able to import / call files in `src/status/libstatus`

### **`src/app`**

This folder contains the code related to each section of the app, generally it should be kept to a minimum amount of logic, *it knows what to do, but not how to do it*

### **`src/app/<module>/`**

* each `<module>` folder inside `app/` should correspond to a section in the app (exception for the `onboarding/` and `login/` currently)
* there should be no new folders here unless we are adding a brand new section to the sidebar
* files inside a `<module>` should not import files from another `<module>`
* while the code here can react to events emited by nim-status (`src/status`) it should not be able to emit events

### **`src/app/<module>/core.nim`**

This file is the controller of this module, the general structure of controller is typically predictable and always the same

* it imports a view
* it imports the nim-status lib
* it contains an `init` method
* it exposes a QVariant

the constructor has typically the following structure

```nimrod=
type NodeController* = ref object of SignalSubscriber
  status*: Status
  view*: NodeView
  variant*: QVariant

proc newController*(status: Status): NodeController =
  result = NodeController()
  result.status = status
  result.view = newNodeView(status)
  result.variant = newQVariant(result.view)

method onSignal(self: NodeController, data: Signal) =
  var msg = cast[WalletSignal](data)
  # Do something with the signal...
```

* with the exception of `src/status/` and its own files within `src/app/<module>` (i.e the views), a controller should **not** import files from anywhere else (including other files inside `app/`)

### **`src/app/<module>/view.nim`**

This file contains the main QtObject for this `<module>` and exposes methods to interact with the views for the controller and QML.

* this file cannot import any other file except:
  * other views within this `<module>`
  * `src/status/` to use their types
* if there are multiple subviews, then they should go into the `views/` folder and initialized in this file.

## Future directions

* signals will be refactored/moved from core.nim files and `signals/` into `src/status/` and instead handle as events
* instead of importing `src/status/libstatus` in `src/status` files, we will do dependency injection, this allow us to more easily do unit tests, as well as transition from status-go to nimstatus
* `src/status` should be reanamed to `src/nim-status`
* `src/status/libstatus` should be renamed to `src/nim-status/status-go`
