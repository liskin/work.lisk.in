---
layout: post
title: Multiseat on demand

---

We needed to make three computers out of two yesterday, so multiseat was the
keyword I googled for. Having found a bunch of howtos all starting with “make
these changes to xorg.conf and gdm.conf”, I took the best from all of them and
put together a solution requiring no single restart of X server. What I got
was this:

<img src="http://store.lisk.in/tmp/perm/multiseat.jpg" width="100%">

Well, what's the problem? Why didn't I just take the first howto I found? I
wanted to have a sort of “on demand” multiseat, that I can start and stop
whenever I want, without ever touching my main X server and its configuration,
without losing my open windows — even without having to rearrange them.

What did I need?
  - new enough X.org server and Xephyr server with input hotplug support
    (I used 1.6.5),
  - spare USB keyboard and mouse, spare monitor,
  - clever window manager with per-screen workspaces (that's the feature that
    lets me switch the external monitor to workspace 12 and still be able to
    switch workspaces on my laptop's display) — I used xmonad, of course.

The theory is that the other seat will run in Xephyr, using the keyboard and
mouse I tell it to use. Xephyr can do that, nowadays, we only need to solve
three little problems:
1. main X server uses that keyboard and mouse as well, and we need to disable
   that in runtime,
2. `/dev/input/eventN` is accessible to root only by default,
3. a lot of keys don't work in Xephyr at all :-).

Feel tree to skip the explanation of these:

1. The xinput command can be used to set device properties, and the “Device
   Enabled” property is what we're looking for. Given a device id, this is how
   we disable the device in the main X server:

    $ xinput list-props id | \
    perl -ne 'if (/Device Enabled \((\d+)\):/){ print $1 }' | \
    { read prop; xinput set-int-prop id $prop 8 0; }

2. Being in a hurry, I added Xephyr for my user to `/etc/sudoers`. You may
   want to create udev rules to set correct permissions instead.

3. This seems to be caused by Xephyr not using the evdev ruleset for XKB
   configuration by default. Running `setxkbmap` with `-rules evdev` seems to
   fix this problem (see the script for details). Xephyr still seems to have
   problems with autorepeat, and I guess that tweaking it for each keycode
   with `xset r` might fix it.

Having solved these problems, I wrote a small script that disables the input
devices in your main X server and launches Xephyr that uses them, fixing
keyboard afterwards: <http://store.lisk.in/tmp/perm/multiseatxephyr>

If called without parameters, it prints a short usage instructions. You'll
have to look into i`/proc/bus/input/devices` to get event devices, and at the
xinput list output to find input device ids. It isn't very robust, but in most
cases you'll be interested in the last two input devices.

Xephyr is running, with access control disabled, all you need to do now is to
su to another user, `export DISPLAY=:1` and run `startkde` (or anything else).

If in trouble, consult the documentation. There are a few links at the X.org
wiki: <http://www.x.org/wiki/Development/Documentation/Multiseat>
