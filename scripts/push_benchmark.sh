#!/usr/bin/env bash

export YLW='\033[1;33m'
export RED='\033[0;31m'
export GRN='\033[0;32m'
export BLU='\033[0;34m'
export BLD='\033[1m'
export RST='\033[0m'

# Clear line
export CLR='\033[2K'

set -o nounset
set -o errexit
set -o pipefail

REPO_URL="git@github.com:status-im/status-app-benchmarks.git"

GIT_ROOT=$(cd "${BASH_SOURCE%/*}" && git rev-parse --show-toplevel)

echo -e "${GRN}Pushing benchmark results${RST}"

cd "${GIT_ROOT}"
# Get the commit SHA from the status-app repo BEFORE cloning benchmarks-repo
commit_sha=$(git rev-parse --short HEAD)

git clone "${REPO_URL}" benchmarks-repo
cd benchmarks-repo

date_time=$(date -u '+%Y-%m-%dT%H:%M:%S')

echo -e "${GRN}Creating virtual environment${RST}"
python3 -m venv .venv
source .venv/Scripts/activate
PYTHON_CMD=".venv/Scripts/python.exe"

echo -e "${GRN}Installing dependencies${RST}"
${PYTHON_CMD} -m  pip install --upgrade pip
${PYTHON_CMD} -m  pip install -r requirements.txt

echo -e "${GRN}Updating data in repo${RST}"
${PYTHON_CMD} scripts/parse-results.py --data-dir ./data ../test/e2e/allure-report/data/ --commit-hash "${commit_sha}" --date "${date_time}" 

echo -e "${GRN}Generating new visualizations from data${RST}"
${PYTHON_CMD} scripts/visualize-data.py --data-dir ./data/ --output-dir ./docs/

echo -e "${GRN}Committing changes${RST}"
git add .
git commit -m "Add benchmark results for commit ${commit_sha}"

echo -e "${GRN}Pushing changes${RST}"
git push "${REPO_URL}"

echo -e "${GRN}Push finished${RST}"
