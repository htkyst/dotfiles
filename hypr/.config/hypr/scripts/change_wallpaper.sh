#!/bin/bash

DIR=$HOME/wallpaper
IMG=$(find $DIR -type f | shuf -n 1)

awww img "$IMG" --transition-type wipe --transition-duration 1
