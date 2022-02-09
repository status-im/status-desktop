import strutils, times

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
