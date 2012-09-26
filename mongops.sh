#!/bin/sh
ps axu |grep [m]ongo | grep -v mongops.sh | grep -v grep
