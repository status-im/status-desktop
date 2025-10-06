import nimqml, chronicles
import std/[sequtils, times]

import app/core/tasks/threadpool
import app/global/global_singleton

# Memory Pressure Manager
# -----------------------
# Lightweight manager to orchestrate memory trimming and restoration for
# registered subsystems. Designed to be exposed to QML so a Timer can
# drive polling or manual triggers during development/testing.

logScope:
  topics = "memory-pressure"
type DroppableKind* = enum
    ## Categorize droppables to control trim/restore ordering.
    dkView,     ## View/UI/QML-heavy resources
    dkService   ## Backend/services/data caches

type Droppable* = object
    name: string
    kind: DroppableKind
    release: proc()
    restore: proc()

QtObject:
  type MemoryPressureManager* = ref object of QObject
    engine: QQmlApplicationEngine
    droppables: seq[Droppable]
    isTrimmed: bool
    lastTrimAtMs: int
    threadpool: ThreadPool

  proc setup(self: MemoryPressureManager)
  proc delete*(self: MemoryPressureManager)

  proc newMemoryPressureManager*(engine: QQmlApplicationEngine, threadpool: ThreadPool): MemoryPressureManager =
    ## Construct and return a new MemoryPressureManager bound to the QQml engine.
    new(result, delete)
    result.engine = engine
    result.setup
    result.threadpool = threadpool

  proc setup(self: MemoryPressureManager) =
    self.QObject.setup()
    self.droppables = @[]
    self.isTrimmed = false
    self.lastTrimAtMs = 0

  proc delete*(self: MemoryPressureManager) =
    self.QObject.delete()

  # Qt-exposed properties (helpful while debugging from QML)
  proc isTrimmedChanged*(self: MemoryPressureManager) {.signal.}
  proc getIsTrimmed*(self: MemoryPressureManager): bool {.slot.} = self.isTrimmed
  QtProperty[bool] trimmed:
    read = getIsTrimmed
    notify = isTrimmedChanged

  proc lastTrimAtMsChanged*(self: MemoryPressureManager) {.signal.}
  proc getLastTrimAtMs*(self: MemoryPressureManager): int {.slot.} = self.lastTrimAtMs
  QtProperty[int] lastTrimMs:
    read = getLastTrimAtMs
    notify = lastTrimAtMsChanged

  proc registerDroppable*(self: MemoryPressureManager,
                          name: string,
                          kind: DroppableKind,
                          release: proc(),
                          restore: proc()) =
    ## Register a droppable resource with paired release/restore callbacks.
    debug "register droppable", name, kind = $kind
    self.droppables.add Droppable(name: name, kind: kind, release: release, restore: restore)

  proc unregisterDroppable*(self: MemoryPressureManager, name: string) {.slot.} =
    ## Optional helper to remove a previously registered droppable by name.
    let before = self.droppables.len
    self.droppables = self.droppables.filterIt(it.name != name)
    if self.droppables.len != before:
      debug "unregister droppable", name

  proc trimEngineCaches(self: MemoryPressureManager) =
    ## Ask the QML engine to collect garbage; repeat a couple times to be safe.
    try:
      if not self.engine.isNil:
        self.engine.collectGarbage()
        self.engine.collectGarbage()
        self.engine.unload()  # Aggressively unload QML/JS resources
        self.engine.collectGarbage()
        self.engine.collectGarbage()
        singletonInstance.releaseEngine()
    except CatchableError:
      warn "engine.collectGarbage failed", err = getCurrentExceptionMsg()

  proc triggerBackgroundTrim*(self: MemoryPressureManager) {.slot.} =
    ## Perform a background trim: release droppables and run GC passes.
    if self.isTrimmed:
      debug "already trimmed; skipping"
      return
    self.isTrimmed = true  # prevent re-entrancy during trim
    info "background trim: releasing droppables", count = self.droppables.len

    self.threadpool.teardown()
    # GC passes (QML/JS + Nim GC if available)
    self.trimEngineCaches()
    when declared(GC_fullCollect):
      try:
        GC_fullCollect()
      except CatchableError:
        warn "GC_fullCollect threw"

    # Prefer dropping Views first to maximize immediate relief.
    for d in self.droppables.filterIt(it.kind == dkView):
      debug "release (view)", name = d.name
      try: d.release() except CatchableError: warn "release failed", name = d.name, err = getCurrentExceptionMsg()
    for d in self.droppables.filterIt(it.kind == dkService):
      debug "release (service)", name = d.name
      try: d.release() except CatchableError: warn "release failed", name = d.name, err = getCurrentExceptionMsg()

    self.isTrimmed = true
    self.lastTrimAtMs = int(epochTime() * 1000.0)
    self.isTrimmedChanged()
    self.lastTrimAtMsChanged()
    info "background trim complete"

  proc triggerForegroundRestore*(self: MemoryPressureManager) {.slot.} =
    ## Restore previously released droppables (usually on app resume/foreground).
    if not self.isTrimmed:
      debug "not trimmed; nothing to restore"
      return
    info "foreground restore: rebuilding droppables", count = self.droppables.len

    # Restore services first so views can bind to ready backends, then views.
    for d in self.droppables.filterIt(it.kind == dkService):
      debug "restore (service)", name = d.name
      try: d.restore() except CatchableError: warn "restore failed", name = d.name, err = getCurrentExceptionMsg()
    for d in self.droppables.filterIt(it.kind == dkView):
      debug "restore (view)", name = d.name
      try: d.restore() except CatchableError: warn "restore failed", name = d.name, err = getCurrentExceptionMsg()

    self.isTrimmed = false
    self.isTrimmedChanged()
    info "foreground restore complete"

  proc droppablesCount*(self: MemoryPressureManager): int {.slot.} = self.droppables.len

  # Optional utility to be driven by a QML Timer if an external heuristic is added later.
  proc pollAndMaybeTrim*(self: MemoryPressureManager): bool {.slot.} =
    ## Returns true if a trim was executed. Hook your own heuristics here.
    ## For now, act as a no-op placeholder so QML can drive it safely.
    result = false
