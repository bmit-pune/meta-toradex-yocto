#!/bin/sh
#enable the parallel RGB to LVDS controller in single channel mode

echo high  > /sys/class/gpio/gpio216/direction
echo high  > /sys/class/gpio/gpio219/direction
echo high  > /sys/class/gpio/gpio222/direction
echo high  > /sys/class/gpio/gpio223/direction
echo high  > /sys/class/gpio/gpio226/direction
echo high  > /sys/class/gpio/gpio225/direction
echo high  > /sys/class/gpio/gpio221/direction
echo high  > /sys/class/gpio/gpio220/direction
