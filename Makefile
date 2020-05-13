SHELL := bash

build:
	nim c -L:lib/libstatus.a -d:ssl -L:-lm --outdir:./bin src/nim_status_client.nim

build-osx:
	nim c -L:lib/libstatus.dylib -d:ssl -L:-lm -L:"-framework Foundation -framework Security -framework IOKit -framework CoreServices" --outdir:./bin src/nim_status_client.nim
