#!/usr/bin/env fish

touch $argv[2]
curl -s https://github.com/users/$argv[1]/contributions_calendar_data ^/dev/null | python -c 'import json; print(json.loads(raw_input())[-1][1])' > $argv[2].tmp
mv $argv[2].tmp $argv[2]
