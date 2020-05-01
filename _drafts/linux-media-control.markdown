---
layout: default
title: Linux, media keys and multiple players (mpd, chromium, mpv, vlc, …)
comments_issue: 1

---

This post explains how to get [media keys][] (play, pause, …) on [keyboards][]
and bluetooth headphones work with a bare [X window manager][] (as opposed to
a full [desktop environment][]) and how to make them control multiple media
players including the web browser (YouTube, [bandcamp][], [myNoise][], etc.)
which is something that even majority [operating systems](#windows-10) and
[desktop environments](#gnome-popular-linux-desktop-environment) don't quite
get right out of the box.

[media keys]: https://en.wikipedia.org/wiki/Computer_keyboard#Miscellaneous
[keyboards]: https://en.wikipedia.org/wiki/ThinkPad#/media/File:Lenovo-ThinkPad-Keyboard.JPG
[X window manager]: https://en.wikipedia.org/wiki/X_window_manager
[desktop environment]: https://en.wikipedia.org/wiki/Desktop_environment#Desktop_environments_for_the_X_Window_System
[bandcamp]: https://bandcamp.com/
[myNoise]: https://mynoise.net/
[mpd]: https://www.musicpd.org/

<figure markdown="block">
[![media-keys](https://user-images.githubusercontent.com/300342/81182729-8237d500-8fae-11ea-89eb-81ca7b3598fe.jpg)](https://user-images.githubusercontent.com/300342/81182740-8663f280-8fae-11ea-9b0d-db91eb6febaf.jpg)
<figcaption>ThinkPad 25 media keys</figcaption>
</figure>

{% include toc.md %}

### Goal

My use cases:

* listening to music/myNoise while working (near computer) or reading (away
  from computer)
* listening to podcasts while cooking/cleaning (away from computer, screen
  locked, wet hands)
* discovering new music on YouTube, bandcamp, soundcloud, …
* listening off-line (that why I use [mpd][] and buy music on [bandcamp][])

I'd love to use the same play/pause key/button in all of these scenarios, and
this key/button should control the appropriate application (pause the one
that's playing, play the last paused one, …). It's annoying, bad UX otherwise.

I don't want to think how to pause music when someone needs me in the
meatspace. Walking back from the kitchen to pause a podcast is just plain
silly. Playing YouTube, bandcamp, soundcloud etc. [using mpd is
possible][youtube-dl-mpd] and it's what I used to do back when my play/pause
buttons were hardwired to mpd, but it's a hack and likely against the ToS.

[youtube-dl-mpd]: https://github.com/liskin/dotfiles/blob/15c2cd83ce7297c38830053a9fd2be2f3678f4b0/bin/youtube-dl-mpd

### Solution

There is a standard [D-Bus][dbus] interface for controlling media players on a
modern Linux desktop: [MPRIS][]. It seems to be supported by both
[Chromium][chrome-mpris] and [Firefox][firefox-mpris] these days, and there's
a command line tool [playerctl][] as well, so we just need to write a few
scripts to wire it all together and everything should just work.

[dbus]: https://www.freedesktop.org/wiki/Software/dbus/
[MPRIS]: https://www.freedesktop.org/wiki/Specifications/mpris-spec/
[chrome-mpris]: https://github.com/chromium/chromium/tree/0944c7716afc8b3d8fe2236db79866d4c8a57b6f/components/system_media_controls/linux
[firefox-mpris]: https://github.com/mozilla/gecko-dev/blob/5470b66539234e52e76bc2176d9bec12325fc555/widget/gtk/MPRISServiceHandler.cpp

After some hacking, my setup looks like this (all the icons and some of the
arrows are clickable):

<figure markdown="block">
{% include_relative _svg/linux-media-control.svg %}
<figcaption>diagram of my setup</figcaption>
</figure>

The window manager ([xmonad][]) and screen locker
([xsecurelock][][^xscreensaver]) bind all the keys (and thus also headphone
buttons via [uinput][] and [bluetoothd][bluetoothd-uinput]) and call the
[liskin-media][] script:

[uinput]: https://www.kernel.org/doc/html/v5.4/input/uinput.html
[bluetoothd-uinput]: https://github.com/RadiusNetworks/bluez/blob/e11bfba10cc15cf74f8a657fad018aece4a5bde9/profiles/audio/avctp.c
[xmonad]: https://xmonad.org/
[xsecurelock]: https://github.com/google/xsecurelock
[liskin-media]: https://github.com/liskin/dotfiles/blob/15c2cd83ce7297c38830053a9fd2be2f3678f4b0/bin/liskin-media

[^xscreensaver]:
    I used to use [xscreensaver][], but it doesn't support binding (media)
    keys and [I don't trust it any more][xscreensaver-security].

[xscreensaver]: https://www.jwz.org/xscreensaver/
[xscreensaver-security]: https://news.ycombinator.com/item?id=21224179

<figure markdown="block">
<figcaption markdown="span">[~/.xmonad/xmonad.hs][xmonad.hs-keys]</figcaption>
```haskell
, ((0, xF86XK_AudioPlay ), spawn "liskin-media play")
, ((0, xF86XK_AudioPause), spawn "liskin-media play")
```
</figure>

<figure markdown="block">
<figcaption markdown="span">[~/bin/liskin-xsecurelock][liskin-xsecurelock-keys]</figcaption>
```bash
export XSECURELOCK_KEY_XF86AudioPlay_COMMAND="liskin-media play"
export XSECURELOCK_KEY_XF86AudioPause_COMMAND="liskin-media play"
```
</figure>

[xmonad.hs-keys]: https://github.com/liskin/dotfiles/blob/15c2cd83ce7297c38830053a9fd2be2f3678f4b0/.xmonad/xmonad.hs#L73-L81
[liskin-xsecurelock-keys]: https://github.com/liskin/dotfiles/blob/15c2cd83ce7297c38830053a9fd2be2f3678f4b0/bin/liskin-xsecurelock#L11-L20

A [background service][liskin-media-service] uses [playerctl][] to keep track
of the last active player:

<figure markdown="block">
<figcaption markdown="span">[~/bin/liskin-media][liskin-media-daemon]</figcaption>
{% raw %}
```bash
playerctl --all-players --follow --format '{{playerName}} {{status}}' status \
| while read -r player status; do
    if [[ $status == @(Paused|Playing) ]]; then
        printf "%s\n" "$player" >"${XDG_RUNTIME_DIR}/liskin-media-last"
    fi
done
```
{% endraw %}
</figure>

[playerctl]: https://github.com/altdesktop/playerctl
[liskin-media-service]: https://github.com/liskin/dotfiles/blob/15c2cd83ce7297c38830053a9fd2be2f3678f4b0/.config/systemd/user/liskin-media-mpris-daemon.service
[liskin-media-daemon]: https://github.com/liskin/dotfiles/blob/15c2cd83ce7297c38830053a9fd2be2f3678f4b0/bin/liskin-media#L46-L54

The [liskin-media][] script then selects the appropriate media player (the first
one that's playing; the one that's paused, if there's only one; or the last one
to play/pause) and uses [playerctl][] to send commands to it:

<figure markdown="block">
<figcaption markdown="span">[~/bin/liskin-media][liskin-media-commands]</figcaption>
```bash
function get-mpris-smart {
    get-mpris-playing || get-mpris-one-playing-or-paused || get-mpris-last
}

function action-play { p=$(get-mpris-smart); playerctl -p "$p" play-pause; }
function action-stop { playerctl -a stop; }
function action-next { p=$(get-mpris-playing); playerctl -p "$p" next; }
function action-prev { p=$(get-mpris-playing); playerctl -p "$p" previous; }
```
</figure>

[liskin-media-commands]: https://github.com/liskin/dotfiles/blob/15c2cd83ce7297c38830053a9fd2be2f3678f4b0/bin/liskin-media#L56-L100

_Note that similar logic is also implemented by [mpris2controller][], which I
unfortunately haven't found until I started writing this post._

[mpris2controller]: https://github.com/icasdri/mpris2controller

The final component is the media players themselves.

[Chrome][]/[Chromium][] 81 seem to work out of the box, including metadata
(artist, album, track) in websites that use the [Media Session API][].
Somewhat surprisingly, play/pause works for any HTML `<audio>`/`<video>`, so
websites that don't use Media Session (bandcamp, …) can be controlled too. It
seems this wasn't always the case as there are several webextensions that seem
to solve this now non-existent problem: [Media Session Master][], [Web Media
Controller][], …[^webext]

[^webext]:
    And there are more, presumably from back when there was no [MPRIS][]
    support in the browser whatsoever:

    * <https://github.com/otommod/browser-mpris2>
    * <https://github.com/Aaahh/browser-mpris2-firefox>
    * <https://github.com/KDE/plasma-browser-integration>

[Firefox][] 75 works after enabling `media.hardwaremediakeys.enabled` in
`about:config`, but Media Session support is still experimental (enabling it
breaks YouTube entirely) so metadata isn't available. Also, not all websites
can be controlled: YouTube and bandcamp works, soundcloud and plain HTML5
`<audio>` example don't. Haven't investigated it further as I don't use
Firefox for media playback. (Also, it keeps resetting its volume to a weird
level.)

[myNoise][] can't be controlled by media keys in either browser as it uses
plain [Web Audio API][], so I've made [a userscript][mynoise-chrome] as a
workaround (chromium-only) and will try to help get it fixed upstream.

[mpd][] 0.21.22 itself does not support [MPRIS][], but the frontend I use —
[Cantata][] — does.

Likewise, [mpv][] 0.32.0 needs a plugin, [mpv-mpris][] works well.

[vlc][] 3.0 supports [MPRIS][] out of the box. Reportedly, [so does
Spotify](https://wiki.archlinux.org/index.php/Spotify#MPRIS). (I don't use
either.)

[Firefox]: https://firefox.com/
[Chrome]: https://www.google.com/chrome/
[Chromium]: https://www.chromium.org/Home
[Web Media Controller]: https://github.com/f1u77y/web-media-controller
[Media Session Master]: https://github.com/Snazzah/MediaSessionMaster
[Media Session API]: https://www.w3.org/TR/mediasession/
[Cantata]: https://github.com/CDrummond/cantata
[mpv]: https://github.com/mpv-player/mpv
[mpv-mpris]: https://github.com/hoyon/mpv-mpris
[vlc]: https://www.videolan.org/vlc/index.html
[Web Audio API]: https://developer.mozilla.org/en-US/docs/Web/API/Web_Audio_API
[mynoise-chrome]: https://github.com/liskin/dotfiles/blob/7c89ed287af7f73411ab0dbb36cf948957a17d71/src-webextensions/myNoise-chrome-improvements.user.js

### State of the art

Out of curiosity, I wanted to know if this is a solved problem if one uses a
less weird operating system or desktop environment. Turns out, not really… :-)

#### GNOME (popular Linux desktop environment)

Only one player is controlled, and not the last one that played, just the
first one that started.

> TODO: recheck
>
> TODO: locked?
>
> TODO: bluetooth

#### Windows 10

* Windows Media Player: reacts to media keys
* Edge: doesn't
* Edge Chromium (81.0.416.64): does

Media keys control all players at once. If Media Player and Edge Chromium with
YouTube are running at the same time, both are paused/unpaused.

> TODO: locked?
>
> TODO: bluetooth

#### Mac OS X

> TODO: Safari
>
> TODO: Chrome
>
> TODO: browser & media player
>
> TODO: locked
>
> TODO: bluetooth

#### Android

> TODO: Chrome
>
> TODO: browser & media player
>
> TODO: lockscreen
>
> TODO: bluetooth

---

*[UX]: user experience
*[ToS]: Terms of Service
*[meatspace]: Deriving from cyberpunk novels, meatspace is the world outside of the 'net-- that is to say, the real world, where you do things with your body rather than with your keyboard.
