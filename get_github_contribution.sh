#!/bin/sh

touch $2
curl --connect-timeout 5 -s https://github.com/users/$1/contributions_calendar_data ^/dev/null | python -c 'import json; print(json.loads(raw_input())[-1][1])' > $2.tmp
if [ $? -eq 0 ]; then
    mv $2.tmp $2
else
    rm $2.tmp
fi
