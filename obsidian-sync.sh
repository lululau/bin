#!/bin/bash

obsidian_dir=$HOME/Obsidian/Documents/Main

cd "$obsidian_dir" || exit

git pull

git add .

if git commit -am "vault backup: $(date '+%F %T')"; then
  git push
  echo "Backup Obsidian vault and pushed to github."
fi

git pull
echo "Pulled data from github."

if lsof -i :27123 >&- && test -e $obsidian_dir/.obsidian/plugins/obsidian-local-rest-api/data.json; then
  rest_api_key=$(jq .apiKey $obsidian_dir/.obsidian/plugins/obsidian-local-rest-api/data.json -r)


  curl -X 'POST' \
       'http://127.0.0.1:27123/commands/obsidian-livesync%3Alivesync-replicate/' \
       -H 'accept: */*' \
       -H "Authorization: Bearer $rest_api_key" \
       -d ''

  echo "Self-Host live-sync finished."
fi
