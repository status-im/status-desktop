#!/usr/bin/env bash

# Use this script to run different sanity checks for the APP_DIR used for AppImage
#
# It will check the
# - glibc, libdtdc++ versions required
# - unreseolved dynamic libraries
# - issues with rpaths and interpreter
#
# You can run this script on build machine after APP_DIR is prepared,
# but also on the client machine, which will run the AppImage (useful for ldd check).
# You need to extract AppImage with `--appimage-extract`

set -e pipefail

echo 'GLIBC highest version:'
find "${APP_DIR}" -type f -exec objdump -T {} \; 2>&1 | grep -v GLIBCXX | grep GLIBC | sed 's/.*GLIBC_\([.0-9]*\).*/\1/g' | sort -uV | tail -1

echo 'GLIBCXX highest version'
find "${APP_DIR}" -type f -exec objdump -T {} \; 2>&1 | grep GLIBCXX | sed 's/.*GLIBCXX_\([.0-9]*\).*/\1/g' | sort -uV | tail -1

echo 'Unresolved libraries:'
find "${APP_DIR}" -type f -exec ldd {} \; 2>&1 | grep -v 'you do not have execution permission'  | grep -v 'not a dynamic executable' | grep -v ' => ' | grep -v 'ld-linux-x86-64.so.2' | grep -q 'linux-vdso.so.1' | wc -l

echo 'Rpaths not starting with $ORIGIN:'
find "${APP_DIR}" -type f -exec patchelf --print-rpath {} \; 2>&1 | grep -v 'not an ELF executable' | grep -v 'missing ELF header' | grep -v '^\$ORIGIN' | wc -l

echo 'Interpreters not default system(/lib64/ld-linux-x86-64.so.2):'
find "${APP_DIR}" -type f -exec patchelf --print-interpreter {} \; 2>&1 | grep -v 'not an ELF executable' | grep -v 'cannot find section' | grep -v 'missing ELF header' | grep -v '/lib64/ld-linux-x86-64.so.2' | wc -l
