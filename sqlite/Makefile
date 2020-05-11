SHELL := bash
build:
	nim c -l:lib/sqlite3.a -L:-lm -l:lib/libcrypto.a --threads --outdir:. main.nim

