import times, macros, strutils, locks, algorithm, std/exitprocs, std/locks
# benchmark measure execution time of block of code.
# usage:
#   import os, strutils, times
#   import benchmark
#
#   benchmark("name") do:
#     ...

template benchmark*(benchmarkName: string, code: untyped) =
  block:
    let t0 = epochTime()
    code
    let elapsed = epochTime() - t0
    let elapsedStr = elapsed.formatFloat(format = ffDecimal, precision = 10)
    echo "CPU Time [", benchmarkName, "] ", elapsedStr, "s"


# Thread safe benchmarking tools
# There are two ways to use this module:
# 1. Use the benchmark benchmarkProc macro to benchmark a block of code. It will automatically call registerDuration with the name of the procedure and the start and end time
# 2. Manually call registerDuration with name and the start and end time

# The output file is named procBenchmark.csv and is located in the current working directory. It will be created at app exit.
# The output is sorted by total time in descending order.
# Output format:
# Procedure, Number of runs, Total time in ms, Avg time in ms, Weight
# test*,1,100.00,100.00,50.00%
# test2*,1,100.00,100.00,50.00%

# usage:
# proc test() {.benchmarkProc.} =
#  sleep(1)

# proc test2() {.benchmarkProc.} =
#  sleep(1)

# proc test3() =
#  let cpuTime = cpuTime()
#  defer: registerDuration("custom test3", cpuTime, cpuTime())
#  sleep(1)

type 
  ProcBenchmark* = object
    numRuns*: int
    totalTime*: float
    procName*: cstring
    numRunsOnMainThread*: int
    callOfInterest*: bool

  ProcBenchmarkPtr* = ptr ProcBenchmark

  SharedProcBenchmarkArr* = object
    data: ptr UncheckedArray[ProcBenchmarkPtr]
    len*: int
    maxLen*: int

  BenchmarkResult = tuple[procName: string, numRuns: int, totalTime: float, weight: float, numRunsOnMainThread: int, callOfInterest: bool]

var 
  lock: Lock
  benchmarkResults: ptr SharedProcBenchmarkArr
  threadId: int
  markCallsOfInterest*: bool = false

# Forward declarations
proc registerDuration*(name: string, startTime: float, endTime: float) {.gcsafe.}

proc quitCallback() {.noconv.}
proc initBenchmarking() {.gcsafe.}
proc deinitBenchmarking() 
proc aggregateData(): seq[BenchmarkResult]
proc writeToFile(resultsToWrite: seq[BenchmarkResult])
proc resultCmp(x, y: BenchmarkResult): int
# End of forward declarations

exitprocs.addExitProc(quitCallback)
threadId = getThreadId()

macro benchmarkProc*(procDef: untyped): untyped =
  procDef.expectKind(nnkProcDef)

  let
    procName = procDef[0].toStrLit
  
  let 
    startingBenchmark = quote do:
      let startTime = cpuTime()
      defer: registerDuration(`procName`, startTime, cpuTime())

  procDef.body.insert(0, startingBenchmark)
  return procDef

proc registerDuration*(name: string, startTime: float, endTime: float) {.gcsafe.} =
  if(benchmarkResults == nil):
    initBenchmarking()

  withLock lock:
    var found = false
    for i in 0 ..< benchmarkResults.len:
      if benchmarkResults.data[i].procName == name.cstring:
        benchmarkResults.data[i].numRuns += 1
        benchmarkResults.data[i].totalTime += endTime - startTime
        if getThreadId() == threadId:
          benchmarkResults.data[i].numRunsOnMainThread += 1
        benchmarkResults.data[i].callOfInterest = markCallsOfInterest or benchmarkResults.data[i].callOfInterest
        found = true
      if found:
        break
    
    if not found:
      if benchmarkResults.len == benchmarkResults.maxLen:
        benchmarkResults.maxLen = benchmarkResults.maxLen * 2
        benchmarkResults.data = cast[ptr UncheckedArray[ProcBenchmarkPtr]](reallocShared(benchmarkResults.data, sizeof(ProcBenchmark) * benchmarkResults.maxLen))

      var newProcBenchmark = cast[ProcBenchmarkPtr](allocShared(sizeof(ProcBenchmark)))
      var namePtr = cast[cstring](allocShared(name.len+1))
      copyMem(namePtr, name.cstring, name.len)
      namePtr[name.len] = '\0'

      newProcBenchmark.procName = namePtr
      newProcBenchmark.numRuns = 1
      newProcBenchmark.totalTime = endTime - startTime
      if getThreadId() == threadId:
        newProcBenchmark.numRunsOnMainThread = 1
      else:
        newProcBenchmark.numRunsOnMainThread = 0
      
      newProcBenchmark.callOfInterest = markCallsOfInterest

      benchmarkResults.data[benchmarkResults.len] = newProcBenchmark
      benchmarkResults.len += 1
      
proc quitCallback() {.noconv.} =
  echo "Benchmarking quit callback"
  var 
    results = aggregateData()
  results.writeToFile()
  deinitBenchmarking()

proc initBenchmarking() {.gcsafe.} =
  echo "Benchmarking init"
  initLock(lock)

  withLock lock:
    if benchmarkResults != nil:
      return

    benchmarkResults = cast[ptr SharedProcBenchmarkArr](allocShared(sizeof(SharedProcBenchmarkArr)))
    benchmarkResults.len = 0
    benchmarkResults.maxLen = 1000
    benchmarkResults.data = cast[ptr UncheckedArray[ProcBenchmarkPtr]](allocShared(sizeof(ProcBenchmark) * benchmarkResults.maxLen))

proc deinitBenchmarking() =
  echo "Benchmarking deinit"
  withLock lock:
    if benchmarkResults == nil:
      return

    for i in 0 ..< benchmarkResults.len:
      deallocShared(benchmarkResults.data[i].procName)
    
    deallocShared(benchmarkResults.data)
    deallocShared(benchmarkResults)
    benchmarkResults = nil

proc aggregateData(): seq[BenchmarkResult] =
  result = @[]
  var totalWeight = 0.0

  withLock lock:
    for i in 0 ..< benchmarkResults.len:
      totalWeight += benchmarkResults.data[i].totalTime
      result.add(($(benchmarkResults.data[i].procName), benchmarkResults.data[i].numRuns, benchmarkResults.data[i].totalTime, 0.0, benchmarkResults.data[i].numRunsOnMainThread, benchmarkResults.data[i].callOfInterest))

  result.sort(resultCmp)
  for i in 0 ..< result.len:
    result[i].weight = result[i].totalTime / totalWeight


proc writeToFile(resultsToWrite: seq[BenchmarkResult]) =
  echo "Benchmarking - write to file"
  var file: File
  try:
    file = open("procBenchmark.csv", fmWrite)
  except:
    echo "Could not open file procBenchmark.txt for writing"
    return
  file.writeLine("Procedure, Number of runs, Total time in ms, Avg time in ms, Weight, Number of runs on main thread, Call of interest")
  for entry in resultsToWrite:
    file.writeLine(entry.procName & 
                  "," & $entry.numRuns & 
                  "," & $(entry.totalTime * 1000) & 
                  "," & $((entry.totalTime / entry.numRuns.float) * 1000) & 
                  "," & $(entry.weight * 100) & "%" &
                  "," & $(entry.numRunsOnMainThread) &
                  "," & $(entry.callOfInterest))
  file.close()

proc resultCmp(x, y: BenchmarkResult): int =
  cmp(y.totalTime, x.totalTime)