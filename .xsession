#!/bin/bash

xrdb -merge .Xresources

if [ -x /usr/bin/xfce4-power-manager ] ; then
   xfce4-power-manager &
fi

if [ -x /usr/bin/nm-applet ] ; then
   nm-applet &
fi

if [ -x /usr/bin/blueman-applet ] ; then
   blueman-applet &
fi

if [ -x /usr/bin/pasystray ] ; then
   pasystray &
fi

exec /usr/local/bin/dwm
