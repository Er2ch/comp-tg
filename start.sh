#!/bin/sh
cd $(dirname $0)
luajit init.lua || lua5.3 init.lua
