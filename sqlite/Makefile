SHELL := bash
build:
	nim c -d:release -L:sqlite3.o -L:-lm -L:"-lcrypto" --threads --outdir:. main.nim

