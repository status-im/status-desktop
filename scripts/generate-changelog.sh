#!/usr/bin/env bash
set -euo pipefail

BRANCH_NAME="${BRANCH_NAME:-$(git rev-parse --abbrev-ref HEAD)}"

if [[ -n "${CHANGE_ID:-}" ]]; then
  # PR build
  SHORT_COMMIT="${GIT_COMMIT:0:7}"
  echo "PR #${CHANGE_ID} - ${SHORT_COMMIT}"
  echo "Build: #${BUILD_NUMBER}"
  echo ""
  echo "View PR: https://github.com/status-im/status-app/pull/${CHANGE_ID}"
elif [[ "${BRANCH_NAME}" == release* ]]; then
  # Release branch build
  echo "Release ${VERSION}"
  echo "Build: #${BUILD_NUMBER}"
else
  # Regular branch build
  SHORT_COMMIT="${GIT_COMMIT:0:7}"
  echo "Branch: ${BRANCH_NAME}"
  echo "Commit: ${SHORT_COMMIT}"
  echo "Build: #${BUILD_NUMBER}"
fi
