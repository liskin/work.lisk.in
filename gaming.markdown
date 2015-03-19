---
layout: default
title: Half-Life server tools and other gaming stuff
permalink: /gaming/

---

  - [dedtools][] — a set of tools for safely running number of dedicated
    servers, contains "init" script for it and some preload hacks which make
    some things possible, also contains needed security fixes

    Here are some more important things that can be used independently:

      - [HLDS NO-WON/NO-STEAM fix][hlds_nowon] — simple preload hack which
        bypasses class B checks for LAN games
      - [HLDS split packet issue fix][hlds_20040707fix] — preload fix for the
        "split packet issue" from 7<sup>th</sup> July 2004 (useful for no
        longer supported HLDS 3.1.1.x)
      - [HLDS custom liblist hack][hlds_custom_liblist] — preload hack which
        gives you ability to specify a liblist.gam path
      - [HLDS chroot hack][hlds_chroot] — preload hack adding HLDS chroot,
        setuid and fork-to-background features, allowing to set up HLDS in a
        chroot jail with _only_ /dev/null – without any libraries or so
        (very useful with some chroot restrictions, see [grsecurity][grsec]
        for example)
      - [MOH:AA chroot hack][mohaa_chroot] — the same for Medal of Honor:
        Allied Assault Linux dedicated server, also with a hack allowing
        mohaa\_lnxded to dump core

  - [hl-multimaster][] — half life master server aggregator, able to join more
    [hlmaster][hlmaster] servers into a big one
  - [hl-lanlist][] — simple tool which catches broadcast infostring requests
    and returns infostring replies from foreign servers, making it able to
    have any non-local servers in the "LAN games" list in half life
  - [sc-remotelan][] — a simple tool which makes starcraft games over internet
    possible without Battle.Net, [win32 build][sc-remotelan-win32]
  - [vacemu][] — Half-life secure server emulator, continuing of Stirlits'
    project.

[dedtools]: http://svn.nomi.cz/svn/tomi/dedtools/head/
[hlds_nowon]: http://svn.nomi.cz/svn/tomi/dedtools/head/hlds/hlds_nowon.c
[hlds_20040707fix]: http://svn.nomi.cz/svn/tomi/dedtools/head/hlds/hlds_20040707fix.c
[hlds_custom_liblist]: http://svn.nomi.cz/svn/tomi/dedtools/head/hlds/hlds_custom_liblist.c
[hlds_chroot]: http://svn.nomi.cz/svn/tomi/dedtools/head/hlds/hlds_chroot.c
[mohaa_chroot]: http://svn.nomi.cz/svn/tomi/dedtools/head/mohaa/mohaa_chroot.c
[grsec]: http://www.grsecurity.net
[hl-multimaster]: http://svn.nomi.cz/svn/tomi/hl-multimaster/head/
[hlmaster]: http://hlmaster.sf.net/
[hl-lanlist]: http://svn.nomi.cz/svn/tomi/hl-lanlist/head/
[sc-remotelan]: http://svn.nomi.cz/svn/tomi/sc-remotelan/head/
[sc-remotelan-win32]: http://tomi.nomi.cz/tmp/sc-remotelan-win32/
[vacemu]: http://nomi.cz/en/projects.shtml?id=vacemu
