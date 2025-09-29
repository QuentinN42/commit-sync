#!/bin/sh
# Create a git repo on github
# Put this script inside
# Update USERNAME
# Run this script
# Push

PRE_COMMIT_MSG='auto: '
USERNAME='QuentinN42'

function modif(){
    cat changes | grep -q "true" && echo "false" > changes || echo "true" > changes
}

todo="$(curl -s "https://gitlab.com/users/${USERNAME}/calendar.json" | jq -rc '. | to_entries | .[] | "\(.key)-\(range(.value)+1)"')"
already_done="$(git log --pretty='format:%s' | grep -E "^${PRE_COMMIT_MSG}" | sed "s/^${PRE_COMMIT_MSG}//")"

export IFS=$'\n'
for x in $todo;
do
    echo "Processing ${x}"
    if [[ ! $already_done =~ $x ]]; then
        modif
        git add changes
        git commit -s -m "${PRE_COMMIT_MSG}${x}" --date="$(date -d "$(echo "${x}" | cut -d- -f-3)")"
    fi
done
