#!/bin/bash
ID= #chat_id
TOKEN= #token
LOOP=7
DATE=$(date '+%Y/%m/%d %H:%M')
if [ "$1" == "RECEIVED" ]; then
	FROM=$(sed -n '1p' < "$2" | awk -F ': ' '{printf $2}')
	BODY=$(sed -e '1,/^$/ d' < "$2" | iconv -f UNICODEBIG -t UTF-8)
	CONTENT="新短信%20$DATE%0a来自:%20$FROM%0a$BODY"
	echo -e "$DATE\n$FROM\n$BODY\n" >> /root/sms/sms.log
fi

vurp(){
	CODE=$(curl -o /dev/null -s -w "%{http_code}" https://www.google.com -x socks5://172.16.7.1:3077 --connect-timeout 10)
	if [ $CODE -ge 200 -a $CODE -lt 400]; then
		curl -d "chat_id=$ID&text=$CONTENT" -X POST https://api.telegram.org/bot$TOKEN/sendMessage -x socks5://172.16.7.1:3077
	elif [ $LOOP -gt 0 ]; then
		((LOOP--))
		echo "proxy failure"
		sleep 300	
		vurp
	fi
}

vurp