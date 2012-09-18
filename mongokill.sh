#!/bin/sh
if [ $# -ne 1 ]; then
  echo "usage: mongokill -2 or -9"
  exit 1
fi

echo $1

ps axu |grep [m]ongo | grep -v [m]ongokill | awk '{print $2}' |xargs kill $1 

