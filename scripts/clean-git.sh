#!/usr/bin/env bash
# Extracted from Makefile to avoid nimbus-build-system blocking use.
git clean -qfdx
git submodule foreach --recursive git reset -q --hard
git submodule foreach --recursive git clean -qfdx
