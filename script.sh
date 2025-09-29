#!/usr/bin/env bash

set -euo pipefail

if [ -z "${GL_USERNAME}" ]; then
    echo "GL_USERNAME is not set"
    exit 1
fi
if [ -z "${GH_REPOSITORY}" ]; then
    echo "GH_REPOSITORY is not set"
    exit 1
fi
if [ -z "${GH_USERNAME}" ]; then
    echo "GH_USERNAME is not set"
    exit 1
fi
if [ -z "${GH_EMAIL}" ]; then
    echo "GH_EMAIL is not set"
    exit 1
fi
if [ -z "${GH_SSH_KEY}" ]; then
    echo "GH_SSH_KEY is not set"
    exit 1
fi

cd "$(mktemp -d)"
dir_path="$(pwd)"
trap "rm -rf ${dir_path}" EXIT
echo "${GH_SSH_KEY}" > ssh_key
chmod 600 ssh_key
GIT_SSH_COMMAND="ssh -i ${dir_path}/ssh_key" git clone "${GH_REPOSITORY}" "repo"
cd "repo"

git config user.name "${GH_USERNAME}"
git config user.email "${GH_EMAIL}"

PRE_COMMIT_MSG='auto: '

function modif(){
    cat changes | grep -q "true" && echo "false" > changes || echo "true" > changes
}

todo="$(curl -s "https://gitlab.com/users/${GL_USERNAME}/calendar.json" | jq -rc '. | to_entries | .[] | "\(.key)-\(range(.value)+1)"')"
already_done="$(git log --pretty='format:%s' | grep -E "^${PRE_COMMIT_MSG}" | sed "s/^${PRE_COMMIT_MSG}//")"

export IFS=$'\n'
commits=0
for x in $todo;
do
    echo "Processing ${x}"
    if [[ ! $already_done =~ $x ]]; then
        modif
        git add changes
        commit_date="$(date -d "$(echo "${x}" | cut -d- -f-3)" '+%Y-%m-%d %H:%M:%S')"
        GIT_COMMITTER_DATE="${commit_date}" git commit -s -m "${PRE_COMMIT_MSG}${x}" --date "${commit_date}"
        commits=$((commits + 1))
    fi
done

GIT_SSH_COMMAND="ssh -i ${dir_path}/ssh_key" git push origin HEAD

echo
echo "Done ! Added ${commits} commits"
echo
