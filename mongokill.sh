#!/bin/sh
if [ $# -ne 1 ]; then
  echo "usage: mongokill -2 or -9"
  exit 1
fi

ps axu |grep [m]ongo | grep -v mongokill | grep -v grep | awk '{print $2}' |xargs kill $1 

