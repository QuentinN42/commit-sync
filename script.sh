#!/usr/bin/env bash

if [ -z "${GITLAB_USERNAME}" ]; then
    echo "USERNAME is not set"
    exit 1
fi
if [ -z "${REPOSITORY}" ]; then
    echo "REPOSITORY is not set"
    exit 1
fi
if [ -z "${GITHUB_USERNAME}" ]; then
    echo "GITHUB_USERNAME is not set"
    exit 1
fi
if [ -z "${GITHUB_EMAIL}" ]; then
    echo "GITHUB_EMAIL is not set"
    exit 1
fi

cd "$(mktemp -d)"
dir_path="$(pwd)"
trap "rm -rf ${dir_path}" EXIT
git clone "${REPOSITORY}" "repo"
cd "repo"

git config user.name "${GITHUB_USERNAME}"
git config user.email "${GITHUB_EMAIL}"

PRE_COMMIT_MSG='auto: '

function modif(){
    cat changes | grep -q "true" && echo "false" > changes || echo "true" > changes
}

todo="$(curl -s "https://gitlab.com/users/${GITLAB_USERNAME}/calendar.json" | jq -rc '. | to_entries | .[] | "\(.key)-\(range(.value)+1)"')"
already_done="$(git log --pretty='format:%s' | grep -E "^${PRE_COMMIT_MSG}" | sed "s/^${PRE_COMMIT_MSG}//")"

export IFS=$'\n'
for x in $todo;
do
    echo "Processing ${x}"
    if [[ ! $already_done =~ $x ]]; then
        modif
        git add changes
        commit_date="$(date -d "$(echo "${x}" | cut -d- -f-3)" '+%Y-%m-%d %H:%M:%S')"
        GIT_COMMITTER_DATE="${commit_date}" git commit -s -m "${PRE_COMMIT_MSG}${x}" --date "${commit_date}"
    fi
done
