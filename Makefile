SHELL := bash

build:
	nim c -d:release -L:libstatus.a -L:-lm --outdir:. src/nim_status_client.nim
