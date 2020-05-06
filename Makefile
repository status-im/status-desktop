SHELL := bash

build:
	nim c -d:release -L:libstatus.a -L:-lm --outdir:. src/nim_status_client.nim

build-osx:
	nim c -d:release -L:libstatus.a -L:-lm -L:"-framework Foundation -framework Security -framework IOKit -framework CoreServices" --outdir:. src/nim_status_client.nim
