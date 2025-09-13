#!/usr/bin/env bash
set -e
git fetch origin --tags --force --no-recurse-submodules
git describe --tags

