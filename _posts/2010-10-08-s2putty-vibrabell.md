---
layout: default
title: Vibration bell for PuTTY for Symbian
comments_issue: 4

---

[PuTTY][putty] is probably the most used application on my phone. I use it to
connect to my server where I read/write e-mails in [mutt][] and communicate
with the outer world using [irssi][] and [bitlbee][]. I suppose most PuTTY
users start it only whenever they need to fix something at their servers, not
as a primary communication tool. They didn't miss a function to alert the user
whenever something happens in a terminal.

I did, however. I wanted to start PuTTY, attach a [screen][] session and put
the phone in my pocket, knowing that it would vibrate whenever something
interesting happens. I always hated that whenever I had sent a message to
someone, I had to look at the screen regularly to check whether he replied or
not. So that's my motivation.

The solution was obvious, I implemented the `do_bell` function in PuTTY for
Symbian and made it vibrate for a few hundred milliseconds. The source code is
here: <http://github.com/liskin/s2putty>. A prebuilt package for s60v5 is in
[downloads][]. Let me know if you need a binary for some other version of
Symbian.

[putty]: http://s2putty.sourceforge.net/
[mutt]: http://www.mutt.org/
[irssi]: http://www.irssi.org/
[bitlbee]: http://www.bitlbee.org/
[screen]: http://www.gnu.org/software/screen/
[downloads]: http://github.com/liskin/s2putty/downloads
