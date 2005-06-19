#!/bin/bash
#set -vx

mode=$1
src=$2

ext=htm
dir=/tmp
cmd="pdftohtml -i -stdout"

case "$mode" in
    --edit) # editor
	dest=$(basename "$src")"_"$$.$ext
	fulldest="$dir/$dest"
	touch "$fulldest"
	chmod 600 "$fulldest"
	$cmd "$src"> "$fulldest"
	echo "$fulldest";;
    *)  # pager
	$cmd "$src";;
esac

