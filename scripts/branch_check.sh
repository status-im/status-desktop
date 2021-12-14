#!/bin/bash

BRANCH_STATUS=$(GIT_HTTP_CONNECT_TIMEOUT=10 git fetch --quiet && git status | head -n 2 | tail -n 1)
MASTER_DATE=$(git log -1 --format=%cd --date=iso-local origin/HEAD)
BRANCH_DATE=$(git log -1 --format=%cd --date=iso-local)

M_DATE=$(date -d "$MASTER_DATE" +%s)
B_DATE=$(date -d "$BRANCH_DATE" +%s)
FOLDER_NAME="$(basename $PWD)"

if [[ "$BRANCH_STATUS" == "Your branch is behind"* ]]
then
  echo "WARNING: $FOLDER_NAME's There are new commits available in this branch!!!"
elif [[ "$BRANCH_STATUS" == *"but the upstream is gone." ]]
then
  echo "WARNING: $FOLDER_NAME's Branch upstream is gone!!!"
elif [ $M_DATE -gt $B_DATE ];
then
  echo "WARNING: $FOLDER_NAME's latest commit in $1 is newer than the current commit!!!"
fi
