#!/usr/bin/env bash

GIT_ROOT=$(cd "${BASH_SOURCE%/*}" && git rev-parse --show-toplevel)

set -ef

# urlencode <string>
urlencode() {
    old_lc_collate=$LC_COLLATE
    LC_COLLATE=C
    local length="${#1}"
    for (( i = 0; i < length; i++ )); do
        local c="${1:$i:1}"
        case $c in
            [a-zA-Z0-9.~_-]) printf '%s' "$c";;
            *)               printf '%%%02X' "'$c";;
        esac
    done
    LC_COLLATE=$old_lc_collate
}

SCRIPT_FILE="$(basename "$0")"

STATUS_GO_REPO="${STATUS_GO_REPO:=status-go}"
STATUS_GO_OWNER="${STATUS_GO_OWNER:=status-im}"
REPO_URL="https://github.com/${STATUS_GO_OWNER}/${STATUS_GO_REPO}"
STATUS_GO_VERSION=$1

HELP_MESSAGE=$(cat <<-END
This is a tool to help creating PRs with specific status-go versions
If the given name matches both a branch and a tag the tag is used.
Usage:
    ${SCRIPT_FILE} {version}
Examples:
    # Using branch name
    ${SCRIPT_FILE} feature-abc-xyz
    # Using tag name
    ${SCRIPT_FILE} v2.1.1
    # Using commit SHA1
    ${SCRIPT_FILE} 1a2b3c4d
    # Using PR number
    ${SCRIPT_FILE} PR-2134
END
)

if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    echo "${HELP_MESSAGE}"
    exit 1
fi

if [ $# -eq 0 ]; then
    echo "Need to provide a status-go version!"
    echo
    echo "${HELP_MESSAGE}"
    exit 1
fi

# If prefixed with # we assume argument is a PR number
if [[ "${STATUS_GO_VERSION}" = PR-* ]]; then
    STATUS_GO_VERSION="refs/pull/${STATUS_GO_VERSION#"PR-"}/head"
fi

# ls-remote finds only tags, branches, and pull requests, but can't find commits
STATUS_GO_MATCHING_REFS=$(git ls-remote ${REPO_URL} ${STATUS_GO_VERSION})

# It's possible that there's both a branch and a tag matching the given version
STATUS_GO_TAG_SHA1=$(echo "${STATUS_GO_MATCHING_REFS}" | grep 'refs/tags' | cut -f1)
STATUS_GO_BRANCH_SHA1=$(echo "${STATUS_GO_MATCHING_REFS}" | grep 'refs/heads' | cut -f1)

REQUIRES_MSG=https://github.com/status-im/status-go/

# Prefer tag over branch if both are found
if [[ -n "${STATUS_GO_TAG_SHA1}" ]]; then
    STATUS_GO_COMMIT_SHA1="${STATUS_GO_TAG_SHA1}"
    REQUIRES_MSG=${REQUIRES_MSG}/tree/${STATUS_GO_VERSION}
elif [[ -n "${STATUS_GO_BRANCH_SHA1}" ]]; then
    STATUS_GO_COMMIT_SHA1="${STATUS_GO_BRANCH_SHA1}"
    REQUIRES_MSG=${REQUIRES_MSG}/tree/${STATUS_GO_VERSION}
elif [[ "${#STATUS_GO_VERSION}" -gt 4 ]]; then
    STATUS_GO_COMMIT_SHA1="${STATUS_GO_VERSION}"
    REQUIRES_MSG=${REQUIRES_MSG}/commit/${STATUS_GO_VERSION}
else
    echo "ERROR: Input not a tag or branch, but too short to be a SHA1!" >&2
    exit 1
fi

echo "SHA-1 for ${STATUS_GO_VERSION} is ${STATUS_GO_COMMIT_SHA1}.
Owner is ${STATUS_GO_OWNER}"


TIMESTAMP=$(date +%s)
BRANCH_NAME=bump/status-go/${STATUS_GO_VERSION}/${TIMESTAMP}

git checkout master
git pull
git checkout -b ${BRANCH_NAME}
cd vendor/status-go
git checkout ${STATUS_GO_COMMIT_SHA1}
cd ../..
git add ./vendor/status-go
git commit -m "chore: bump status-go

### Requires
- ${REQUIRES_MSG}


"
git push --set-upstream origin ${BRANCH_NAME}
git push
git checkout master
git branch -D ${BRANCH_NAME}

cat << EOF
DONE!!!!!!!!!!!!!

Create a pull request at https://github.com/status-im/status-desktop/pull/new/${BRANCH_NAME}


EOF
