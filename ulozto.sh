#!/bin/sh

# GPLv3
# script to upload file to uloz.to
# nail{@}nodomain{.}sk
#
# usage:
# ./ulozto.sh file username password

cookie=`mktemp`
tmp_sid=`uuidgen|sed 's/-//g'`

if [ $1 ]
then
file=$1
else
exit 1
fi

if [ $2 ]
then
username=$2
else
read -p "uloz.to username: " username
fi

if [ $3 ]
then
password=$3
else
stty -echo 
read -p "Password for user $username: " password;echo
stty echo
fi

curl -s -c $cookie -d username=$username -d password=$password http://www.uloz.to/?do=authForm-submit 1>/dev/null 2>&1
user_id=`curl -s -b $cookie http://www.uloz.to|grep user_id|sed 's/.*&user_id=\([0-9]*\)&host.*/\1/'`
curl -s -b cookie -F upfile_o=@./$1 "http://up.uloz.to/ul/upload.cgi?tmp_sid=$tmp_sid&user_id=$user_id&host=www.uloz.to" 1>/dev/null
sleep 2
for id in `curl -s -b $cookie http://www.uloz.to/m/$username|grep input|grep value=\"$file\"|sed 's/.*name="\([0-9]*\)"\ value="'$file'".*/\1/'`
do
echo http://www.uloz.to/$id/$file
done
rm $cookie
