import # status-desktop libs
  ../qt

type
  MarathonTaskArg* = ref object of QObjectTaskArg
    `method`*: string
