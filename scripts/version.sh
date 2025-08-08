#!/usr/bin/env bash
echo "$(git describe --tags)${USE_NWAKU:+-nwaku-experimental}"
