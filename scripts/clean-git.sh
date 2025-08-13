#!/usr/bin/env bash
# Extracted from Makefile to avoid nimbus-build-system blocking use.
git clean -qfdx
# nuke vendor, they're regenerated anyways
rm -rf vendor
rm -rf mobile/vendors
