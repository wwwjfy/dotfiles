#!/bin/sh

touch $2
curl -s https://github.com/users/$1/contributions_calendar_data ^/dev/null | python -c 'import json; print(json.loads(raw_input())[-1][1])' > $2.tmp
mv $2.tmp $2
