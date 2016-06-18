#!/bin/sh

username=$1
password=$2
filename=$3

api='http://api.dbcapi.me/api/captcha'

resp=`curl -s --header 'Expect: ' -F username=$username -F password=$password -F captchafile=@$filename $api`
captchaid=`echo $resp | cut -d '&' -f 2 | cut -d '=' -f 2`

printf $captchaid

text=''
while [ "$text" = '' ] ; do
    sleep 3
    resp=`curl -s $api/$captchaid`
    text=`echo $resp | cut -d '&' -f 3 | cut -d '=' -f 2`
done

printf $text
