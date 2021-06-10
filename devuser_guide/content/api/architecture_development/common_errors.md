---
title : "Common issues"
description: "Common issues"
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

## Common errors and how to solve them

### SIGSEGV: Illegal storage access. (Attempt to read from nil?)

This happens due to using a null pointer, it can be caused by several situations:

**calling status-go with invalid parameters**

Calling status-go with a json that is missing a field somewhere can cause status-go to crash somewhere or throw an exception that is not being caught

**listening for non existing events**

If an event in which a corresponding `emit` does not exist, it can cause this error

```nimrod=
 events.on("event-does-not-exist") do(a: Args):
    appState.addChannel("test")
    appState.addChannel("test2")
```

**parsing json**

when working with json, this error could be triggered for several reasons
* accessing a property that doesn't exist
* get the value type that doesn't match the value in the json
  * `if payload["contentType"].str == 2:` will crash because the value of contentType is `2` not `"2"`
  * something extracting a string with `value.str` instead of `$value` (sometimes `.getStr`)

### Error: attempting to call undeclared routine

this happens due something missing in the QTObject, it's caused for when a proc is not marked as a slot, not being public, not part of a variant, missing the self attribute or not mapped in a qproperty if it is an accesor

*TODO: add practical examples*

### Unsupported conversion of X to metatype

this can happen due to a method being exposed to QT as a slot but using an object (like a model X) that is not a QtObject.
possible solutions:
- make the object a QtObject (usually only recommended if it's in the view only)
- remove the {.slot.} pragma if it's not being called from QML anyway
- change the method to receive params individually and then build the model inside the method

### typeless parameters are obsolete

typically means types are missing for a method parameters

### attempting to call undeclared routine

routine is likely not public or is being declared after the method calling it

### QML Invalid component body specification

This error happens when a `Component` has multiple children, it must only contain one child, to fix it, put the component children inside a `Item {}`

### QML TypeError: Property 'setFunctionName' of object SomeView(0x7fa4bf55b240) is not a function

Likely the function is missing a `{.slot.}` pragma

### QML input text value not being updated

If you are using an `Input` QML prop, to get the current value use `idName.TextField.text` instead of `idName.text`

### QMutex: destroying locked mutex

a common scenario this error can happen is when trying to immediatly access something in status-go when the app starts before the node is ready. it can also happen due to 2 threads attempting to call & change something from status-go at the same time

### Error: type mismatch: got <> but expected one of:

Sometimes this can happen when using generics, it can be solved by either passing the parameters explicitily:

`getSetting[string](self.status.settings, Setting.SigningPhrase)`

or using typedesc param with `:` like:

`self.status.settings.getSetting[:string](Setting.SigningPhrase)`

### undeclared identifier: 'result'

Typically this means the method has no return type and so `result =` isn't necessary

### expression 'method(param)' has no type (or is ambiguous)

This usually means a method that has no return type is being discarded

###  required type for <variable>: <Type> but expression '<variable>' is of type: <Type>

This tpyically means there is an import missing

### type mismatch: got <Type>

```
Error: type mismatch: got <WalletView>
but expected one of:
template `.`(a: Wrapnil; b): untyped
  first type mismatch at position: 1
  required type for a: Wrapnil
  but expression 'self' is of type: WalletView
```

There is likely a typo or the method is not public

## Warnings

### QML anchor warnings

Those look like 
```
Cannot specify top, bottom, verticalCenter, fill or centerIn anchors for items inside Column. Column will not function.
```
or
```
Detected anchors on an item that is managed by a layout. This is undefined behavior; use Layout.alignment instead.
```

Those mean that you used anchors on an element that is manged by a Layout. Those are ColumnLayouts, StackLayouts, etc.

The first child of anything in a "Something"Layout will not have access to anchors (they will throw warnings).

First thing to ask yourself, do you really need a Layout? That's the easiest way to fix it. Unless you really need your block to be a row or a column that needs to go next/under another, use an Item or similar. Usually, you can still do the same effect anyway with anchors on the siblings

If you really need the Layout, then one way to fix is to set the first child of the Layout an `Item` and then every other child inside the `Item`. That way, all the children can use anchors. You can set
```
Layout.fillHeight: true
Layout.fillWidth: true
```
on the `Item` to make it fill the whole parent so that nothing else needs to be changed.