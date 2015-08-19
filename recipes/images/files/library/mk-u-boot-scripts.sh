#!/bin/sh
for f in *.scr
do
	mkimage -T script -C none -n 'Flash Apalis/Colibri module' -d $f `basename $f .scr`.img
done	
