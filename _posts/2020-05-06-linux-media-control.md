---
layout: default
title: Linux, media keys and multiple players (mpd, chromium, mpv, vlc, …)
comments_issue: 1
image: https://user-images.githubusercontent.com/300342/81182729-8237d500-8fae-11ea-89eb-81ca7b3598fe.jpg
large_image: true

---

This post explains how to get [media keys][] (play, pause, …) on [keyboards][]
and Bluetooth headphones work with a bare [X window manager][] (as opposed to
a full [desktop environment][]) and how to make them control multiple media
players including the web browser (YouTube, [bandcamp][], [myNoise][], etc.)
which is something that even majority [operating systems][h4-win10] and
[desktop environments][h4-gnome] don't quite get right out of the box.

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

<figure markdown="block" class="transparent-bg-light">
{% include {{ page.slug }}/setup-diagram.svg %}
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

<i>
Note that similar logic is also implemented by [mpris2controller][], which I
unfortunately haven't found until I started writing this post.
</i>

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

[Firefox][] 76 works after enabling `media.​hardware​media​keys.​enabled` in
`about:config`. This only enables play/pause/stop, however. To be able to skip
to next/prev and to get metadata (artist, album, track), [Media Session API][]
needs to be enabled separately via `dom.​media.​media​session.​enabled` (note that
I couldn't get this to work in Firefox 75, so this is hot new experimental
stuff and may be unstable). Also, not all websites can be controlled
(play/pause): YouTube and bandcamp works, soundcloud and plain HTML5 `<audio>`
example don't. Firefox's emerging support for media controls is [documented
here][firefox-media-control]; there are some interesting details about
ignoring silence, short clips, and giving up control if paused for more than a
minute (a feature that I find undesirable and unfortunately present in Chrome
on non-Linux platforms, as noted further).

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
[firefox-media-control]: https://docs.google.com/document/d/1c4FivJpvAjjw9Uw-jn7X1UjGOoWkANXOulNyqDWs83w/edit

<figure markdown="block" class="video">
<div class="iframe iframe-16x9">
<iframe src="https://www.youtube-nocookie.com/embed/VYQOnKIvGgA" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>
</div>
<figcaption markdown="span">demonstration of my setup</figcaption>
</figure>

### State of the art

Out of curiosity, I wanted to know if this is a solved problem if one uses a
less weird operating system or desktop environment. Turns out, not really… :-)

#### [GNOME][] (popular Linux desktop environment)

[h4-gnome]: #gnome-popular-linux-desktop-environment

Media keys (and presumably also headphone buttons, not tested) appear to work
out of the box, including when the desktop is locked. Unfortunately it only
works reliably (predictably) when there's just one media player application.
When there's more than one (e.g. YouTube in Chromium and music in
[Rhythmbox][]), only the one that started first (application launch, not
necessarily start of playing) is controlled, regardless of whether this one
player is stopped/playing/paused, or whether it has any playable media at all.

In practice, this means that a browser that had once visited YouTube blocks
other apps from being controlled by media keys. This is further complicated by
the fact that [gnome-settings-daemon][] has two different APIs for media keys:
[MPRIS][] and [GSD media keys API][] and prefers MPRIS players. Therefore,
Chromium are Rhythmbox are preferred to [Totem][] (GNOME's movie player) even
when launched later, which means that a user needs to understand all these
complicated bits to have any hope of knowing what player will act upon a
play/pause button press. Oh and Totem does support MPRIS in fact, it's a
plugin that may be manually enabled in its preferences.

It is _a bit_ of a mess.

<i>
(I tested this on a [Fedora][] 32 live DVD with [GNOME][] 3.36. Recordings of
some of those experiments: <https://youtu.be/1fN6NMDBFNI>,
<https://youtu.be/FCStseDBwC4>)
</i>

[GNOME]: https://www.gnome.org/gnome-3/
[Rhythmbox]: https://wiki.gnome.org/Apps/Rhythmbox
[Totem]: https://wiki.gnome.org/Apps/Videos
[GSD media keys API]: https://gitlab.gnome.org/GNOME/gnome-settings-daemon/-/blob/28ce4225535329dee6a9aff8c44bd1671ce9d2de/plugins/media-keys/README.media-keys-API
[gnome-settings-daemon]: https://gitlab.gnome.org/GNOME/gnome-settings-daemon/-/tree/28ce4225535329dee6a9aff8c44bd1671ce9d2de/plugins/media-keys
[Fedora]: https://getfedora.org/

#### [KDE Plasma 5][]

[h4-kde]: #kde-plasma-5

KDE is the only environment out of those tested that works really well.
(Almost.)

Media keys work out of the box in all media players I tried ([Dragon][],
[vlc][], [mpv][] + [mpv-mpris][], [Totem][] + MPRIS plugin) including lock-screen. When there are
multiple players, the last one is controlled, and when it's closed, it
automatically switches to another one. Additionally, there's an applet in the
bottom panel that lets users override this automatic behaviour and force a
selected player to be controlled.

When [Firefox][] is first launched, KDE prompts the user to install the
[Plasma Browser Integration][] extension which adds [MPRIS][] and even [Media
Session API][] support to Firefox, presumably because this extension predates
this support in Firefox itself. The [implementation][plasma-mediasession-shim]
is different to the one in recent Firefox versions, so it's not entirely
surprising that soundcloud works as well (as opposed to vanilla Firefox). And
it also follows that it doesn't work when a media file is opened directly; the
extension only works in HTML pages.

Unfortunately, [Chromium][] doesn't work so well. It's visible in the list of
media players in the panel applet, it shows what's currently playing, but the
control buttons are grey and media keys don't do anything either. This is also
the case if there are more players active: whenever Chromium is the active
player, media keys do nothing. This is a [bug in Chromium's MPRIS
implementation][chromium-cancontrol] that should be easy to fix. In the
meantime, one can install the [Plasma Browser Integration][] extension as a
workaround (for HTML audio/video).

<i>
(I tested this on a [Fedora 32 KDE][] live DVD with KDE Plasma 5.18.3.
Recordings of some of those experiments: <https://youtu.be/-vpHDXg5jW8>,
<https://youtu.be/IybSl2WiNYE>)
</i>

[Dragon]: https://github.com/KDE/dragon
[Fedora 32 KDE]: https://spins.fedoraproject.org/kde/
[KDE Plasma 5]: https://en.wikipedia.org/wiki/KDE_Plasma_5
[Plasma Browser Integration]: https://github.com/KDE/plasma-browser-integration/
[plasma-mediasession-shim]: https://github.com/KDE/plasma-browser-integration/blob/64a63f2b4b96545dd1d4bcb5583dfbec9122722f/extension/content-script.js#L635-L898
[plasma-chromium-blacklist]: https://old.reddit.com/r/kde/comments/eih9jb/if_you_use_chromium_with_kde_plasma_integration/fcqduij/
[chromium-cancontrol]: https://bugs.chromium.org/p/chromium/issues/detail?id=1052609

#### [Windows 10][]

[h4-win10]: #windows-10

Similarly to GNOME, media keys appear to work fine at first glance, but when
multiple/specific apps are involved, minor problems appear.

Windows 10 have their equivalent of [MPRIS][] called [System Media Transport
Controls][SMTC] and this is supported by [Chromium][chrome-mpris], and
therefore by both [Chrome][] and the [new Chromium-based Edge][Edge-chromium].
It's not supported by the (deprecated) [Windows Media Player][WMP], but that's
probably fine as the modern replacement [Movies/Films & TV][MoviesTV] supports
it very well.

As opposed to GNOME, an application not supporting the [SMTC API][SMTC] does
not mean it doesn't react to media keys. Windows Media Player [does, quite
well actually](https://youtu.be/9DN2tcZGsHU) (even on lock screen), but it
doesn't grab the keys so when there's another app, media keys [control both of
them](https://youtu.be/aPSkMTZcy8w). On the other hand, [vlc][] only [handles
the keys when focused](https://youtu.be/FQAFurnLUVU). Finally and not
surprisingly, [old Edge][Edge-old] and [Internet Explorer][IE] don't [handle
them at all](https://youtu.be/uKRqZ3p76Gw).

Handling of multiple apps that all support SMTC is
[good](https://youtu.be/1-m0kECqt38), but there's a bug that would make this
completely unusable for my podcast use case: it's not possible to continue
playing from the lock screen if it'd been paused for more than a few seconds.
This bug does not affect [Movies/Films & TV][MoviesTV], though.

Were it not for this issue, I'd say it's perfectly usable, as deprecated
players/browsers can easily be avoided and I wouldn't mind not being able to
use vlc for background playback.

[SMTC]: https://docs.microsoft.com/en-us/windows/uwp/audio-video-camera/integrate-with-systemmediatransportcontrols
[IE]: https://en.wikipedia.org/wiki/Internet_Explorer
[Edge-old]: https://en.wikipedia.org/wiki/Microsoft_Edge#Spartan_(2014%E2%80%932019)
[Edge-chromium]: https://blogs.windows.com/windowsexperience/2020/01/15/new-year-new-browser-the-new-microsoft-edge-is-out-of-preview-and-now-available-for-download/
[MoviesTV]: https://en.wikipedia.org/wiki/Microsoft_Movies_%26_TV
[WMP]: https://en.wikipedia.org/wiki/Windows_Media_Player
[Windows 10]: https://en.wikipedia.org/wiki/Windows_10

<i>
(I tested this on a clean [Windows 10][] Pro version 1909 with no
vendor-specific bloatware. Recordings of the experiments are linked from the
preceding paragraphs, and for completeness also listed here:
<https://youtu.be/9DN2tcZGsHU>, <https://youtu.be/1-m0kECqt38>,
<https://youtu.be/aPSkMTZcy8w>, <https://youtu.be/FQAFurnLUVU>,
<https://youtu.be/uKRqZ3p76Gw>.)
</i>

#### [macOS Catalina][]

I expected this to work almost flawlessly as Apple is known for their focus on
UX, but it seems worse than Windows 10, unfortunately. Worse than Windows 10
with the _optional_ upgrade to the [new Chromium-based Edge][Edge-chromium],
that is.

My experience as a user of macOS is very limited, and as a developer
non-existent, but it seems that the macOS equivalent of MPRIS is
[MPRemoteCommandCenter][] in the Media Player framework.

Media keys work in every app I tried (but I haven't tried any that don't come
pre-installed, like [vlc][]), and they work on lock screen as well, regardless
of how long it's been paused/locked. Unfortunately, they only start controlling
the app after I've interacted with the play/pause button at least once, so
when I open a video and press the play/pause key on the keyboard, instead of
pausing, the Music app opens.

When multiple players are open, the last one that I interacted with is
controlled, as it should be. When one of them is closed, however, the control
isn't transferred to the other one, unless the application is terminated
entirely or I manually interact with the other one. Strangely, it works well
when a music-playing tab in Safari is closed.

<i>
(I tested this on a clean [macOS Catalina][] 10.15.4 with no additional
software installed. Recordings of some of those experiments:
<https://youtu.be/VN7-eZsIpOE>, <https://youtu.be/oIo21HRPfhM>)
</i>

[macOS Catalina]: https://en.wikipedia.org/wiki/MacOS_Catalina
[MPRemoteCommandCenter]: https://developer.apple.com/documentation/mediaplayer/mpremotecommandcenter

#### Android 10 (Samsung One UI 2.1)

Had I not been a longtime Android user, I would expect this to work flawlessly
as smartphones are the primary means of media consumption for many (most?)
people. Turns out there are issues, too. There always are.

Android's API for media control: “A [MediaSession][android-mediasession]
should be created when an app wants to publish media playback information or
handle media keys.”

My Android device does not have a dedicated play/pause button, but my
Bluetooth headphones do, so that's what I tested (wired headphones will likely
behave the same). Obviously, most apps (including [vlc][]) react to play/pause
just fine. Additionally, pressing play in one app pauses any other that is
currently playing, which is something that desktop systems don't do and that
isn't implemented (yet) in my setup either. Also, an incoming/outgoing call
pauses any playing media. So far so good.

Interaction between multiple players is a bit weird, though. Like in macOS,
after closing one of them, [control is not transferred to the other
one](https://youtu.be/2vQAbaMpXfM). Unlike in macOS, quitting the application
(force close) doesn't help either. Like in macOS, closing a browser tab does
transfer control to a music player.

What's worse, when a media playing in the browser ([Chrome][mobile-chrome]) is
paused and the device is locked, it [disappears after a while and can't be
continued](https://youtu.be/UOXvDx6Dvas), similarly to Windows 10. As noted in
[the notes about Firefox media controls][firefox-media-control], this might be
intentional, but I don't like this: it forces me to install an app for
anything that I might need to pause for longer than a few seconds, and there
isn't always (a good) one.

<i>
(I tested this on a not at all clean, but fully updated [Samsung Galaxy
S10e][]. This is not vanilla Android 10, but Samsung's [One UI][] 2.1, so it's
possible other devices will behave better (or worse). Recordings of the
experiments are linked from the preceding paragraphs, and for completeness
also listed here: <https://youtu.be/2vQAbaMpXfM>,
<https://youtu.be/UOXvDx6Dvas>.)
</i>

<i>
(Completely unrelated, but perhaps worth noting: to ensure high-quality
playback, Android sends audio at 100% volume to Bluetooth headphones[^btvol]
and lets them adjust volume themselves. Without this, 16-bit audio at 25%
volume effectively becomes 14-bit. [pulseaudio][] doesn't do this, but
[liskin-media does][liskin-media-volume].)
</i>

[^btvol]:
    Not all of them, however. I tried [Marshall Monitor Bluetooth][] and [Sony
    MDR-XB950BT][] and it's only done for the former.

[Samsung Galaxy S10e]: https://www.gsmarena.com/samsung_galaxy_s10e-9537.php
[One UI]: https://en.wikipedia.org/wiki/One_UI
[pulseaudio]: https://www.freedesktop.org/wiki/Software/PulseAudio/
[liskin-media-volume]: https://github.com/liskin/dotfiles/blob/15c2cd83ce7297c38830053a9fd2be2f3678f4b0/bin/liskin-media#L8-L41
[Marshall Monitor Bluetooth]: https://www.marshallheadphones.com/us/en/monitor-bluetooth.html
[Sony MDR-XB950BT]: https://www.sony.com/electronics/headband-headphones/mdr-xb950bt
[mobile-chrome]: https://play.google.com/store/apps/details?id=com.android.chrome
[android-mediasession]: https://developer.android.com/reference/android/media/session/MediaSession

#### Summary

None of the mainstream environments except [KDE][h4-kde] supports media
keys/buttons well enough to cover my use cases. It seems, therefore, that
niche X window managers aren't at a very big disadvantage — their target
demographic is used to tweaking things to their liking, after all.

---

*[UX]: user experience
*[ToS]: Terms of Service
*[meatspace]: Deriving from cyberpunk novels, meatspace is the world outside of the 'net-- that is to say, the real world, where you do things with your body rather than with your keyboard.
