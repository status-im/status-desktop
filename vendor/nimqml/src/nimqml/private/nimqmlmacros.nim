## Contains helper macros for NimQml

import macros
import strutils
import sequtils
import typetraits


type
  FindQObjectTypeResult = tuple
    typeIdent: NimNode
    superTypeIdent: NimNode

  ProcInfo = object
    name: string
    returnType: string
    parametersTypes: seq[string]
    parametersNames: seq[string]

  PropertyInfo = object
    name: string
    typ: string
    read: string
    write: string
    notify: string

  QObjectInfo = object
    name: string
    superType: string
    slots: seq[ProcInfo]
    signals: seq[ProcInfo]
    properties: seq[PropertyInfo]


proc childPos(node: NimNode, child: NimNode): int =
  ## Return the position of the given child or -1
  var i = 0
  for c in node.children:
    if c == child:
      return i
    inc(i)
  return -1


proc removeChild(node: NimNode, child: NimNode): bool =
  ## Remove the child from a node
  let pos = node.childPos(child)
  if pos == -1: return false
  node.del(pos)
  return true


proc toString(info: ProcInfo): string {.compiletime.} =
  ## Convert a ProcInfo to string
  let str = "ProcInfo {\n  Name:\"$1\",\n  Return Type:$2,\n  Param Types:[$3],\n  Param Names:[$4]\n}"
  str % [info.name, info.returnType, info.parametersTypes.join(","), info.parametersNames.join(",")]


proc display(info: ProcInfo) {.compiletime.} =
  ## Display a ProcInfo
  echo info.toString


proc toString(info: PropertyInfo): string {.compiletime.} =
  ## Convert a PropertyInfo to string
  "PropertyInfo {\"$1\", \"$2\", \"$3\", \"$4\", \"$5\"}" % [info.name, info.typ, info.read, info.write, info.notify]


proc display(info: PropertyInfo) {.compiletime.} =
  ## Display a PropertyInfo
  echo info.toString


proc toString(info: QObjectInfo): string {.compiletime.} =
  ## Convert a QObjectInfo to string
  let slots = info.slots.map(proc (x: auto): auto = x.toString)
  let signals = info.signals.map(proc(x: auto): auto = x.toString)
  let properties = info.properties.map(proc(x: auto): auto = x.toString)
  "QObjectInfo {\"$1\", \"$2\", [\"$3\"], [\"$4\"], [\"$5\"]}" % [info.name, info.superType, slots.join(", "), signals.join(", "), properties.join(", ")]


proc display(info: QObjectInfo) {.compiletime.} =
  ## Display a QObjectInfo
  echo info.toString


proc fromQVariantConversion(x: string): string {.compiletime.} =
  ## Return the correct conversion call from a QVariant
  ## to the given nim type
  case x:
  of "int": result = "intVal"
  of "string": result = "stringVal"
  of "bool": result = "boolVal"
  of "float": result = "floatVal"
  of "double": result = "doubleVal"
  of "QObject": result = "qobjectVal"
  of "QVariant": result = ""
  else: error("Unsupported conversion from QVariant to $1" % x)


proc toMetaType(x: string): string {.compiletime.} =
  ## Convert a nim type to QMetaType
  case x
  of "": result = "Void"
  of "void": result = "Void"
  of "int": result = "Int"
  of "bool": result = "Bool"
  of "string": result = "QString"
  of "double": result = "Double"
  of "float": result = "Float"
  of "pointer": result = "VoidStar"
  of "QVariant": result = "QVariant"
  of "QObject": result = "QObjectStar"
  else: error("Unsupported conversion of $1 to metatype" % x)
  result = "QMetaType.$1" % result


proc toMetaType(types: seq[string]): seq[string] {.compiletime.} =
  ## Convert a sequence of nim types to a sequence of QMetaTypes
  result = @[]
  for t in types:
    result.add(t.toMetaType)


proc childrenOfKind(n: NimNode, kind: NimNodeKind): seq[NimNode] {.compiletime.} =
  ## Return the sequence of child nodes of the given kind
  result = @[]
  for c in n:
    if c.kind == kind:
      result.add(c)

proc numChildrenOfKind(n: NimNode, kind: NimNodeKind): int {.compiletime.} =
  ## Return the number of child nodes of the given kind
  childrenOfKind(n, kind).len


proc getPragmas(n: NimNode): seq[string] {.compiletime.} =
  ## Return the pragmas of a node
  result = @[]
  let pragmas = n.childrenOfKind(nnkPragma)
  if pragmas.len != 1:
    return
  let pragma = pragmas[0]
  for c in pragma:
    doAssert(c.kind == nnkIdent)
    result.add($c)


proc extractQObjectTypeDef(head: NimNode): FindQObjectTypeResult {.compiletime.} =
  ## Extract the first type section and extract the first type Name and SuperType
  ## i.e. Given "type Bar = ref object of Foo" you get "Bar" and "Foo"
  let sections = head.childrenOfKind(nnkTypeSection)

  if sections.len == 0:
    error("No type section found")

  if sections.len != 1:
    error("Only one type section is supported")

  let definitions = sections[0].childrenOfKind(nnkTypeDef)

  if definitions.len == 0:
    error("No type definition found")

  if definitions.len != 1:
    error("Only ne type definition is supported")

  let def = definitions[0]

  var name = def[0] # type Object = ... <---
  let pragma = def[1] # type Object {.something.} = ... <---
  let typeKind = def[2] # .. = ref/distinct/object ..

  if name.kind == nnkPostFix:
    if name.len != 2: error("Expected two children in nnkPostFix node")
    if name[0].kind != nnkIdent or $(name[0]) != "*": error("Expected * in nnkPostFix node")
    if name[1].kind != nnkIdent: error("Expected ident as second argument in nnkPostFix node")
    name = name[1]

  if def[2].kind != nnkRefTy: # .. = ref ..
    error("ref type expected")

  if typekind[0].kind != nnkObjectTy: # .. = ref object of ...
    error("ref object expected")

  let objectType = typekind[0]
  if objectType[1].kind != nnkOfInherit:
    error("ref object with super type expected")

  let superType = objectType[1][0]

  result.typeIdent = name
  result.superTypeIdent = superType


proc extractProcInfo(n: NimNode): ProcInfo {.compiletime.} =
  ## Extract the ProcInfo for the given node
  let procName = n[0]
  if procName.kind == nnkIdent: # proc name <-- without *
    result.name = $procName
  elif procName.kind == nnkPostFix: # proc name* <-- with *
    result.name = procName[1].repr # We handle both proc name and proc `name=`
  else: error("Unexpected node kind")

  let paramsSeq = n.childrenOfKind(nnkFormalParams)
  if paramsSeq.len != 1: error("Failed to find parameters")
  let params = paramsSeq[0]
  result.returnType = repr params[0]
  result.parametersNames = @[]
  result.parametersTypes = @[]
  for def in params.childrenOfKind(nnkIdentDefs):
    result.parametersNames.add(repr def[0])
    result.parametersTypes.add(repr def[1])


proc extractPropertyInfo(node: NimNode): tuple[ok: bool, info: PropertyInfo] {.compiletime.} =
  ## Extract the PropertyInfo for a given node
  #[
  Command
      BracketExpr
        Ident !"QtProperty"
        Ident !"string"
      Ident !"name"
      StmtList
        Asgn
          Ident !"read"
          Ident !"getName"
        Asgn
          Ident !"write"
          Ident !"setName"
        Asgn
          Ident !"notify"
          Ident !"nameChanged"
  ]#
  if node.kind != nnkCommand or
     node.len != 3 or
     node[0].kind != nnkBracketExpr or
     node[1].kind != nnkIdent or
     node[2].kind != nnkStmtList:
    return
  let bracketExpr = node[0]
  if bracketExpr.len != 2 or
     bracketExpr[0].kind != nnkIdent or
     bracketExpr[1].kind != nnkIdent or
     $(bracketExpr[0]) != "QtProperty":
    return
  let stmtList = node[2]
  if stmtList.len >= 1:
    if stmtList[0].kind != nnkAsgn or stmtList[0].len != 2 or
       stmtList[0][0].kind != nnkIdent or
        (stmtList[0][1].kind != nnkIdent and stmtList[0][1].kind != nnkAccQuoted):
      error("QtProperty parsing error")
  if stmtList.len >= 2:
    if stmtList[1].kind != nnkAsgn or stmtList[1].len != 2 or
       stmtList[1][0].kind != nnkIdent or
        (stmtList[1][1].kind != nnkIdent and stmtList[1][1].kind != nnkAccQuoted):
      error("QtProperty parsing error")
  if stmtList.len >= 3:
    if stmtList[2].kind != nnkAsgn or stmtList[2].len != 2 or
       stmtList[2][0].kind != nnkIdent or
        (stmtList[2][1].kind != nnkIdent and stmtList[2][1].kind != nnkAccQuoted):
      error("QtProperty parsing error")

  result.info.name = $(node[1])
  result.info.typ = $(bracketExpr[1])

  var
    readFound = false
    writeFound = false
    notifyFound = false

  result.info.read = ""
  result.info.write = ""
  result.info.notify = ""

  for c in stmtList:
    let accessorType = $(c[0])
    let accessorName = c[1].repr
    if accessorType != "read" and accessorType != "write" and accessorType != "notify":
      error("Invalid property accessor. Use read, write or notify")
    if accessorType == "read" and readFound:
      error("Read slot already defined")
    if accessorType == "write" and writeFound:
      error("Write slot already defined")
    if accessorType == "notify" and notifyFound:
      error("Notify signal already defined")
    if accessorType == "read":
      readFound = true
      result.info.read = accessorName
    if accessorType == "write":
      writeFound = true
      result.info.write = accessorName
    if accessorType == "notify":
      notifyFound = true
      result.info.notify = accessorName

  result.ok = true


proc isSlot(n: NimNode): bool {.compiletime.} =
  n.kind in {nnkProcDef, nnkMethodDef} and "slot" in n.getPragmas

proc isSignal(n: NimNode): bool {.compiletime.} =
  n.kind in {nnkProcDef, nnkMethodDef} and "signal" in n.getPragmas

proc isProperty(node: NimNode): bool {.compiletime.} =
  if node.kind != nnkCommand or
     node.len != 3 or
     node[0].kind != nnkBracketExpr or
     node[1].kind != nnkIdent or
     node[2].kind != nnkStmtList:
    return false
  let bracketExpr = node[0]
  if bracketExpr.len != 2 or
     bracketExpr[0].kind != nnkIdent or
     bracketExpr[1].kind != nnkIdent or
     $(bracketExpr[0]) != "QtProperty":
    return false
  return true

proc extractQObjectInfo(node: NimNode): QObjectInfo {.compiletime.} =
  ## Extract the QObjectInfo for the given node
  let (typeNode, superTypeNode) = extractQObjectTypeDef(node)
  result.name = $typeNode
  result.superType = $superTypeNode
  result.slots = @[]
  result.signals = @[]
  result.properties = @[]

  # Extract slots and signals infos
  for c in node.children:
    # Extract slot
    if c.isSlot:
      var info = extractProcInfo(c)
      if info.parametersTypes.len == 0:
        error("Slot $1 must have at least an argument" % info.name)
      if info.parametersTypes[0] != $typeNode:
        error("Slot $1 first arguments must be $2" % [info.name, $typeNode])
      info.parametersTypes.delete(0, 0)
      info.parametersNames.delete(0, 0)
      result.slots.add(info)
    # Extract signal
    if c.isSignal:
      var info = extractProcInfo(c)
      if info.parametersTypes.len == 0:
        error("Signal $1 must have at least an argument" % info.name)
      if info.parametersTypes[0] != $typeNode:
        error("Signal $1 first arguments must be $2" % [info.name, $typeNode])
      info.parametersTypes.delete(0, 0)
      info.parametersNames.delete(0, 0)
      result.signals.add(info)

  # Extract properties infos and remove them
  var toRemove: seq[NimNode] = @[]
  for c in node:
    let (ok, info) = extractPropertyInfo(c)
    if not ok: continue
    toRemove.add(c)
    result.properties.add(info)

  for r in toRemove:
    if not node.removeChild(r):
      error("Failed to remove a child")


proc generateMetaObjectSignalDefinitions(signals: seq[ProcInfo]): seq[string] {.compiletime.} =
  result = @[]
  for signal in signals:
    var parameters: seq[string] = @[]
    for i in 0..<signal.parametersTypes.len:
      parameters.add("ParameterDefinition(name: \"$1\", metaType: $2)" % [signal.parametersNames[i], signal.parametersTypes[i].toMetaType])
    let def = "SignalDefinition(name: \"$1\", parameters: @[$2])" % [signal.name, parameters.join(",")]
    let str = "  signals.add($1)" % def
    result.add(str)


proc generateMetaObjectSlotsDefinitions(slots: seq[ProcInfo]): seq[string] {.compiletime.} =
  result = @[]
  for slot in slots:
    var parameters: seq[string] = @[]
    for i in 0..<slot.parametersTypes.len:
      parameters.add("ParameterDefinition(name: \"$1\", metaType: $2)" % [slot.parametersNames[i], slot.parametersTypes[i].toMetaType])
    let def = "SlotDefinition(name: \"$1\", returnMetaType: $2, parameters: @[$3])" % [slot.name, slot.returnType.toMetaType, parameters.join(",")]
    let str = "  slots.add($1)" % def
    result.add(str)


proc generateMetaObjectPropertiesDefinitions(properties: seq[PropertyInfo]): seq[string] {.compiletime.} =
  result = @[]
  for property in properties:
    let args = [property.name, property.typ.toMetaType, property.read, property.write, property.notify]
    let def = "PropertyDefinition(name: \"$1\", propertyMetaType: $2, readSlot: \"$3\", writeSlot: \"$4\", notifySignal: \"$5\")" % args
    let str = "  properties.add($1)" % def
    result.add(str)


proc generateMetaObjectInitializer(info: QObjectInfo): NimNode {.compiletime.} =
  ## Generate the metaObject initialization procedure
  let signals = generateMetaObjectSignalDefinitions(info.signals)
  let slots = generateMetaObjectSlotsDefinitions(info.slots)
  let properties = generateMetaObjectPropertiesDefinitions(info.properties)

  var lines = @["proc initializeMetaObjectInstance(): QMetaObject ="
    , "  var signals: seq[SignalDefinition] = @[]"
    , "  var slots: seq[SlotDefinition] = @[]"
    , "  var properties: seq[PropertyDefinition] = @[]"]
  lines = lines.concat(signals.concat(slots.concat(properties)))
  let newStmt = "  newQMetaObject($2.staticMetaObject, \"$1\", signals, slots, properties)".format([info.name, info.superType])
  lines = lines.concat(@[newStmt])
  let str = lines.join("\n")
  result = parseStmt(str)


proc generateMetaObjectAccessors(info: QObjectInfo): NimNode {.compiletime.} =
  ## Generate the metaObject instance and accessors
  let str = ["let staticMetaObjectInstance: QMetaObject = initializeMetaObjectInstance()"
    , "proc staticMetaObject*(c: type $1): QMetaObject = staticMetaObjectInstance"
    , "proc staticMetaObject*(self: $1): QMetaObject = staticMetaObjectInstance"
    , "method metaObject*(self: $1): QMetaObject = staticMetaObjectInstance"].join("\n")
  result = parseStmt(str % info.name)


proc generateMetaObject(info: QObjectInfo): NimNode {.compiletime.} =
  ## Generate the metaObject related procs and vars
  result = newStmtList()
  result.add(generateMetaObjectInitializer(info))
  result.add(generateMetaObjectAccessors(info))


proc generateSlotCall(slot: ProcInfo): string {.compiletime.} =
  ## Generate a slot call
  var sequence: seq[string] = @[]

  # Add return type
  if slot.returnType != "" and
     slot.returnType != "void":
    let conversion = fromQVariantConversion(slot.returnType)
    if conversion == "":
      sequence.add("arguments[0].assign(self.$1)" % slot.name)
    else:
      sequence.add("arguments[0].$1 = self.$2" % [conversion, slot.name])
  else:
    sequence.add("self.$1" % slot.name)

  if slot.parametersTypes.len > 0:
    sequence.add("(")
    for i in 0..<slot.parametersTypes.len:
      if i != 0: sequence.add(",")
      sequence.add("arguments[$1]" % $(i+1))
      let conversion = fromQVariantConversion(slot.parametersTypes[i])
      if conversion != "": sequence.add(".")
      sequence.add(conversion)
    sequence.add(")")

  result = sequence.join("")


proc generateOnSlotCalled(info: QObjectInfo): NimNode {.compiletime.} =
  ## Generate the onSlotCalled method
  var str = "method onSlotCalled*(self: $1, name: string, arguments: openarray[QVariant]) = "
  var body: seq[string] = @[]
  body.add("  case name")
  for slot in info.slots:
    body.add("  of \"$1\": $2" % [slot.name, generateSlotCall(slot)])
  body.add("  else: procCall onSlotCalled(self.$1, name, arguments)" % info.superType)
  str = str & "\n" & body.join("\n")
  result = parseStmt(str % info.name)


macro slot*(s: untyped): untyped =
  ## Do nothing. Used only for tagging
  s


macro signal*(s: untyped): untyped =
  ## Generate the signal implementation
  let info = extractProcInfo(s)

  # Remove self from parameter names
  var parametersNames: seq[string] = @[]
  var i = 0
  for name in info.parametersNames:
    if i != 0:
      parametersNames.add("newQVariant($1)" % name)
    inc(i)

  let format = "$1.emit(\"$2\", [$3])"
  let str = format % [info.parametersNames[0], info.name, parametersNames.join(", ")]
  s[s.len - 1] = parseStmt(str)
  s


macro QtObject*(body: untyped): untyped =
  ## Generate the QObject stuff
  let info = extractQObjectInfo(body)
  result = newStmtList()
  result.add(body)
  result.add(generateMetaObject(info))
  result.add(generateOnSlotCalled(info))
