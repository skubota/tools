#!/bin/sh

echo begin > /tmp/cymru$$
echo verbose >> /tmp/cymru$$

if [ -s $1 ];
then
   cat $1 >> /tmp/cymru$$
else
   while read i
   do
     echo $i >> /tmp/cymru$$
   done
fi
echo end >> /tmp/cymru$$
cat /tmp/cymru$$ | nc whois.cymru.com 43
rm /tmp/cymru$$
