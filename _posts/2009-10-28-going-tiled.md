---
layout: default
title: Going tiled
comments_issue: 2

---

I had been using [Fluxbox][] for 7 years when I finally decided it's time for
change last Friday. As my friends expected, I left it for [xmonad][]. Seven
years is a long time and for me it meant that I became a Fluxbox developer.
Therefore, I should say some nice goodbye.

[Fluxbox]: http://fluxbox.org/
[xmonad]: https://xmonad.org/

It all started in 2002 when a friend of mine switched me to Linux. I installed
it onto my father's laptop, which only had 32 MB of memory and quickly
realized that GNOME, KDE and Mozilla aren't for me. Someone gave me a tarball
of fluxbox 0.1.12, I installed it, and liked it. Unfortunately, I have no
screen shots or photos from that time.

Later that year, I installed fluxbox 0.1.14 (the last in 0.1 series) onto my
“workstation” and it turned out that I would stick with that old version for
another 4 years.

The look of my workspace evolved a little over the years. I chose a few shots
that demonstrate that :-).

[![][goingtiled1small]][goingtiled1]

[![][goingtiled2small]][goingtiled2]

[![][goingtiled3small]][goingtiled3]

In the meantime, Fluxbox team was working hard on the 0.9 series, hoping to
get it stable enough for 1.0. Every time I tried it, it seemed buggy and slow,
bringing nothing new other than transparency and eye candy. The one or two
little features I liked were easy to implement in 0.1.14, anyway. So I stayed
for 4 years.

Then, Mark Tiefenbruck jumped in and made things move faster in 2006. Later
that year, seeing a lot of activity in its svn repo, I decided it was time for
me to jump in as well. Took me only a few patches and it was stable enough for
me to use. I even added some little features I wanted, and managed to get some
of them included in official Fluxbox repo.

At the end of 2007, Fluxbox switched from svn to git and I was given push
(“commit” in svn terminology) access. That year X.org became capable of
switching between single- and dual-head without restarts and I added proper
handling of this stuff to Fluxbox. After that, I had a window manager I was
fully satisfied with. Those few features that never made it into the official
repo were waiting for some polishing on my side that I was supposed to do
after Mark does something I don't really remember what it was. I'm not sure if
he did it, for some time I thought he didn't, and then I focused on other
things and didn't want to hack the window manager that worked perfectly for
me. Well, my fluxbox binary is now more than a year old and will remain that
way. Sorry for that, Fluxbox is a great window manager, I'd like to thank the
people around it, I learned a lot thanks to Fluxbox and the team.

The last day I used Fluxbox, it looked more or less like this:

[![][goingtiled4small]][goingtiled4]

And one day I switched to xmonad. That day was last Friday. Being a bug-magnet
(as you may have noticed), I've already submitted two patches. But that's
fine, neither was to xmonad core, both were for xmonad-contrib. (I don't want
to blame Fluxbox either. That old 0.1.14 was nearly perfect and latest
versions are probably quite stable as well.)

I really like the configurability of xmonad and the layout modifiers concept.
Also, xmonad-contrib is a huge and very nice collection of useful stuff.
I feel that I'll be submitting more patches (hopefully more than bug fixes) in
the future.

My workspace now looks like this:

[![][goingtiled5small]][goingtiled5]

So, again, thanks and goodbye to Fluxbox, and I'm looking forward to having
some fun with xmonad :-).

[goingtiled1]:      https://store.lisk.in/tmp/perm/goingtiled_1.png
[goingtiled1small]: https://store.lisk.in/tmp/perm/goingtiled_1_small.jpg
[goingtiled2]:      https://store.lisk.in/tmp/perm/goingtiled_2.png
[goingtiled2small]: https://store.lisk.in/tmp/perm/goingtiled_2_small.jpg
[goingtiled3]:      https://store.lisk.in/tmp/perm/goingtiled_3.png
[goingtiled3small]: https://store.lisk.in/tmp/perm/goingtiled_3_small.jpg
[goingtiled4]:      https://store.lisk.in/tmp/perm/goingtiled_4.png
[goingtiled4small]: https://store.lisk.in/tmp/perm/goingtiled_4_small.jpg
[goingtiled5]:      https://store.lisk.in/tmp/perm/goingtiled_5.png
[goingtiled5small]: https://store.lisk.in/tmp/perm/goingtiled_5_small.jpg
