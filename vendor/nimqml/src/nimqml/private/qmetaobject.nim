proc delete*(metaObject: QMetaObject) =
  ## Delete a QMetaObject
  debugMsg("QMetaObject", "delete")
  if metaObject.vptr.isNil:
    return
  dos_qmetaobject_delete(metaObject.vptr)
  metaObject.vptr.resetToNil

proc newQObjectMetaObject*(): QMetaObject =
  ## Create the QMetaObject of QObject
  debugMsg("QMetaObject", "newQObjectMetaObject")
  new(result, delete)
  result.vptr = dos_qobject_qmetaobject()

proc newQAbstractItemModelMetaObject*(): QMetaObject =
  ## Create the QMetaObject of QAbstractItemModel
  debugMsg("QMetaObject", "newQAbstractItemModelMetaObject")
  new(result, delete)
  result.vptr = dos_qabstractitemmodel_qmetaobject()

proc newQAbstractListModelMetaObject*(): QMetaObject =
  ## Create the QMetaObject of QAbstractListModel
  debugMsg("QMetaObject", "newQAbstractListModelMetaObject")
  new(result, delete)
  result.vptr = dos_qabstractlistmodel_qmetaobject()

proc newQAbstractTableModelMetaObject*(): QMetaObject =
  ## Create the QMetaObject of QAbstractTableModel
  debugMsg("QMetaObject", "newQAbstractItemTableMetaObject")
  new(result, delete)
  result.vptr = dos_qabstracttablemodel_qmetaobject()

proc newQMetaObject*(superClass: QMetaObject, className: string,
                     signals: seq[SignalDefinition],
                     slots: seq[SlotDefinition],
                     properties: seq[PropertyDefinition]): QMetaObject =
  ## Create a new QMetaObject
  debugMsg("QMetaObject", "newQMetaObject")
  new(result, delete)
  result.signals = signals
  result.slots = slots
  result.properties = properties

  var dosParameters: seq[seq[DosParameterDefinition]] = @[]

  var dosSignals: seq[DosSignalDefinition] = @[]
  for i in 0..<signals.len:
    let name = signals[i].name.cstring
    let parametersCount = signals[i].parameters.len.cint
    var parameters: seq[DosParameterDefinition] = @[]
    for p in signals[i].parameters:
      parameters.add(DosParameterDefinition(name: p.name.cstring, metaType: p.metaType.cint))
    dosParameters.add(parameters)
    let dosSignal = DosSignalDefinition(name: name, parametersCount: parametersCount, parameters: if parameters.len > 0: parameters[0].unsafeAddr else: nil)
    dosSignals.add(dosSignal)

  var dosSlots: seq[DosSlotDefinition] = @[]
  for i in 0..<slots.len:
    let name = slots[i].name.cstring
    let returnMetaType = slots[i].returnMetaType.cint
    let parametersCount = slots[i].parameters.len.cint
    var parameters: seq[DosParameterDefinition] = @[]
    for p in slots[i].parameters:
      parameters.add(DosParameterDefinition(name: p.name.cstring, metaType: p.metaType.cint))
    dosParameters.add(parameters)
    let dosSlot = DosSlotDefinition(name: name, returnMetaType: returnMetaType,
                                    parametersCount: parametersCount, parameters: if parameters.len > 0: parameters[0].unsafeAddr else: nil)
    dosSlots.add(dosSlot)

  var dosProperties: seq[DosPropertyDefinition] = @[]
  for i in 0..<properties.len:
    let name = properties[i].name.cstring
    let propertyMetaType = properties[i].propertyMetaType.cint
    let readSlot = properties[i].readSlot.cstring
    let writeSlot = properties[i].writeSlot.cstring
    let notifySignal = properties[i].notifySignal.cstring
    let dosProperty = DosPropertyDefinition(name: name, propertyMetaType: propertyMetaType,
                                            readSlot: readSlot, writeSlot: writeSlot,
                                            notifySignal: notifySignal)
    dosProperties.add(dosProperty)

  let signals = DosSignalDefinitions(count: dosSignals.len.cint, definitions: if dosSignals.len > 0: dosSignals[0].unsafeAddr else: nil)
  let slots = DosSlotDefinitions(count: dosSlots.len.cint, definitions: if dosSlots.len > 0: dosSlots[0].unsafeAddr else: nil)
  let properties = DosPropertyDefinitions(count: dosProperties.len.cint, definitions: if dosProperties.len > 0: dosProperties[0].unsafeAddr else: nil)

  result.vptr = dos_qmetaobject_create(superClass.vptr, className.cstring, signals.unsafeAddr, slots.unsafeAddr, properties.unsafeAddr)
