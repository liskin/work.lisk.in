---
layout: default
title: 'Technogym Skillbike: smart trainer usage and trying to get useful data out of it'
comments_issue: 11
image: summary.png
large_image: true

---

We recently moved to an apartment building in London that happens to include a
gym as a shared amenity. There's [Technogym][] equipment, including the
[Skillbike][], a [stationary bike][] somewhat capable of speaking the [smart
trainer ANT+/BTLE protocols][smart-trainer]. As it happens, getting it to
actually do something useful isn't straightforward, so here's a summary of my
attempts.

[Technogym]: https://www.technogym.com/
[Skillbike]: https://www.technogym.com/int/skillbike.html
[stationary bike]: https://en.wikipedia.org/wiki/Stationary_bicycle
[smart-trainer]: https://www.dcrainmaker.com/2016/07/everything-you-ever-wanted-to-know-about-ant-fe-c-and-bike-trainers.html

{% include toc.md %}

### Goal

What I'm actually trying to do:

* Get faster on the bike and fitter off the bike.
* Do that effectively—structured training based on [power][power-training] is
  known to have results sooner than just riding the bike a lot (and I can't
  spend all my time doing that).
* Not need to think too much about it. I'm spending my “thinking budget”
  elsewhere, so here ideally something or someone tells me what to do when,
  and I just do it.
* Get data out of it. Primarily to help with the above (getting workout
  suggestions from something/someone), but also because “if it's not on Strava
  it didn't happen.”
* Have fun while doing so.
* As a stretch goal, while cycling indoor I can listen to more podcasts,
  audiobooks and tech talks (or just random youtube videos).

Last but not least, it's a “new toy”, so I also just want to try it and see if
it's any good. Many of my cycling friends already have a smart trainer and use
it with one of the apps made for them.

[power-training]: https://www.dcrainmaker.com/2009/08/power-primer-cycling-with-power-101.html

### Skillbike

<figure markdown="block" class="half-size">
[![Technogym Skillbike](https://user-images.githubusercontent.com/300342/187048238-55125c58-87cd-4a88-a7bf-2f99ddc54758.jpg)](https://user-images.githubusercontent.com/300342/187048205-bec6edcc-10c4-4811-b11b-1a9f3ade3439.jpg)
<figcaption>Technogym Skillbike</figcaption>
</figure>

The Skillbike is a predecessor of Technogym Ride—[recently reviewed by DC
Rainmaker][dcr-ride] (recommended read to get an idea what it is). They both
look very similar from the outside. The display on the Skillbike is much
smaller and runs simpler, less capable software. This, however, makes space
for a phone holder, which is useful to run 3rd party apps like [Zwift][],
control podcasts or watch videos. Unfortunately it seems that Skillbike's
implementation of [smart trainer protocols][protocols] is worse, so not all
3rd party apps work. More about that later.

[dcr-ride]: https://www.dcrainmaker.com/2022/08/technogym-ride-smart-indoor-bike-in-depth-review.html
[Zwift]: https://zwift.com/
[protocols]: https://www.dcrainmaker.com/2018/05/whats-baseline-on-a-smart-trainer-in-2018.html

### Attempts

#### Skillbike itself

The simplest thing I could do would be to just use [what the Skillbike itself
offers][skillbike-workouts]. That isn't much, but at least it's free (gratis)
and I can watch videos on my phone while training. Unfortunately the “not
think” and “get data” goals aren't satisfied here, as it doesn't sync into
Garmin Connect.

I'm not sure if that's because their [mywellness][] cloud doesn't even attempt
to sync into GC and just pulls data out of it (weight, daily movements
summary, …), or whether that's because they generate a malformed TCX. I tried
to [fix that TCX][skillbike-tcx] and upload it manually. That works but
unfortunately doesn't result in Garmin's [Physio TrueUp][] syncing the data
back into my watch, so I can't use any of Garmin's training features.

Pros:
* No subscription fee.
* Larger display than my smartphone, and the smartphone is free to play
  videos.
* Syncs into Strava.

Cons:
* Doesn't sync into Garmin Connect, so my FTP and Power Curve isn't
  automatically updated there.
* Due to the above, workouts aren't synced into my Garmin watch, so I don't
  see [Training Status][] and [Daily Suggested Workouts][]. This goes against
  the goal of not thinking too much.
* [Very limited selection of workouts][skillbike-workouts].

[skillbike-workouts]: https://support.technogym.com/post/training-modes-with-skillbike
[Training Status]: https://support.garmin.com/en-GB/?faq=VxKazDQ2mkAmDoQbJriEBA
[Daily Suggested Workouts]: https://support.garmin.com/en-GB/?faq=oYknGZ910l1pfBNzkDHX6A
[mywellness]: https://www.mywellness.com/
[skillbike-tcx]: https://github.com/liskin/dotfiles/blob/33590ee7997c1d8326693e3d61504baf2824c097/bin/technogym-tcx-to-garmin-tcx

#### Garmin watch

<figure markdown="block" class="half-size">
[![Suggested workout on Garmin Fenix 7S](https://user-images.githubusercontent.com/300342/187266942-50b34e06-0fa0-4241-a478-d330c74add2f.jpg)](https://user-images.githubusercontent.com/300342/187266942-50b34e06-0fa0-4241-a478-d330c74add2f.jpg)
<figcaption>Suggested workout on Garmin Fenix 7S</figcaption>
</figure>

[Skillbike manual][skillbike-manual] says that it can be connected to Garmin
devices via ANT+ and to Zwift via Bluetooth, so I tried that, in that order.
When the Skillbike isn't in “Home mode” (which it isn't, it's in a gym), its
ANT+ identification changes every time the devices dialog is opened, requiring
new pairing with the Garmin and cluttering the list of sensors. What's worse,
with my [Garmin Fenix 7S][] (firmware 8.37) the connection gets lost shortly
after I start pedalling. I wasn't able to figure out what's wrong, and
eventually gave up.

Good news is that [Garmin is interested in resolving this
issue](https://twitter.com/Garmin/status/1561856493837844487), so this may be
revisited, if/when time allows. There are other potential disadvantages of
having the Skillbike be driven by a watch, though.

[skillbike-manual]: https://www.dropbox.com/sh/9lcbnhdark1wp90/AAC71ZGS4zg83ubt7IRCuOQIa
[Garmin Fenix 7S]: https://www.garmin.com/en-GB/p/735548

Pros:
* If it worked, I wouldn't need to think almost at all and just do the [Daily
  Suggested Workouts][] while watching something on the smartphone.
* Data sync would be seamless too.
* No subscription fee.

Cons:
* Doesn't work: disconnects within half a minute.
* [Daily Suggested Workouts][] aren't very fun (compared to Zwift, Rouvy, or
  riding outdoors), it's just a series of long periods of holding constant
  power. Tolerable while watching a video, though.
* It's a watch: small screen, and not in front of eyes. Not ideal if I want to
  see/adjust the workout.

#### Zwift

Next thing to try is [Zwift][]. My current smartphone ([Samsung Galaxy S22][])
doesn't support ANT+ (the previous one, [S10e][], did) so I was worried this
might not work at all. Turns out Zwift connected to the Skillbike over
Bluetooth immediately, and everything just worked perfectly on the first try.
Sync with Garmin and Strava also worked fine, so my Garmin watch started
showing training metrics/features for cycling almost immediately. Good!

When I tried Zwift for the second time, I struggled to connect it with the
Skillbike, but I think this may have been caused by my previous experiments
with ANT+ and Garmin. After connecting/disconnecting the watch once, I haven't
encountered this issue again. Another time I tried to use Zwift, my free trial
kilometers ran out, and while I was able to complete the workout (FTP ramp
test), the resulting FIT file was corrupted and wouldn't sync to Garmin. After
trying some online FIT repair tools suggested by Zwift's support, I was able
to repair the file manually using [FitCSVTool][] from the official [Garmin FIT
SDK][].

These were hopefully one-off issues, but I still kept searching for a better
alternative, because Zwift is primarily a video game made for larger screens,
and I'd like something more training-focused that doesn't waste screen
space—there's just a phone holder on the Skillbike, no place to hold a laptop.
If I carried a fan, a laptop and a laptop stand to our shared gym, I'd look
like a mad man.

[Samsung Galaxy S22]: https://www.gsmarena.com/samsung_galaxy_s22_5g-11253.php
[S10e]: https://www.gsmarena.com/samsung_galaxy_s10e-9537.php
[FitCSVTool]: https://developer.garmin.com/fit/fitcsvtool/
[Garmin FIT SDK]: https://developer.garmin.com/fit/download/

Pros:
* Syncs into both Strava and Garmin. (Except when it produces a malformed FIT
  file and doesn't.)
* Garmin officially supports this, so its [Physio TrueUp][] feature syncs
  workouts back into the watch which shows [Training Status][] and [Daily
  Suggested Workouts][].
* Workouts target cadence in addition to power.
* Lots of workouts to choose from. Training plans, too.
* Less boring than just holding a constant power for a set amount of time.

Cons:
* Subscription fee.
* Made for large screens, barely usable on a 6" smartphone. Most of the screen
  is wasted on the “fun” stuff and only a small part shows the training
  elements (target watts, cadence, workout steps, …).
* Can't watch a video, only podcasts/audiobooks.

[Physio TrueUp]: https://support.garmin.com/en-GB/?faq=EjPECQK58qA0xzJ5X74vm7

#### Rouvy

Next on the list is [Rouvy][], a competitor to Zwift developed in my home
country, Czechia. The main difference between the two is that [Zwift is
_virtual_ reality while Rouvy is _augmented_ reality][dcr-rouvy]. There are
(video recordings of) real-world cycling routes in Rouvy. This slightly less
game-y focus also means the user interface is less distracting, there are no
virtual fans cheering me to “go go go” while I'm listening to a podcast, and
as a bonus the fonts can be enlarged to be readable on a small screen. In
theory, Rouvy should be better (for me) than Zwift in all aspects. In
practice, I ran into several issues that I haven't been able to resolve.

When I tried to set up sync with Garmin and Strava, in both cases it asked for
permissions to pull data out of those in addition to just uploading rides done
in Rouvy. I disabled those permissions, which resulted in Strava not being
connected at all, and Garmin connected in a weird state where Rouvy thought it
can only receive data and not upload (the opposite of the permissions I
allowed), but there's still an option to trigger the upload manually. Despite
this weirdness, rides would sync to Garmin Connect just fine, often
automatically. One would expect GC to then sync them to Strava (just as it
does with rides recorded on the watch), but on one occasion that didn't
happen.

I reported this to them and I'm sure they'll fix this eventually. Meanwhile, I
could sync manually whenever the auto sync fails. Annoying, but tolerable, I
thought, and enthusiastically changed into lycra and went to the gym to try an
FTP test with Rouvy. “Cannot launch workout — unknown error occurred.” Did I
try turning it off and on again? Yes, sure, I did. Time to contact the support
for the second time. Apparently this is affecting more people and should be
fixed sooner than the sync issues.

Well, okay, but my free trial is running out and I'm not entirely convinced I
want to put it my credit card details… :-/

[Rouvy]: https://rouvy.com/
[dcr-rouvy]: https://www.dcrainmaker.com/2018/12/rouvy-augmented-reality-training.html

Pros:
* Garmin officially supports this, so as with Zwift, I get all the benefits of
  having the data synced. That is, provided the data actually syncs…
* Lots of workouts to choose from.
* Way less boring than just holding a constant power for a set amount of time.
* Compared to Zwift, less distracting user interface focused more on training
  than trying to be a video game. Also, fonts can be adjusted a bit (not
  enough) for a small smartphone screen.
* Made by friends from Czechia.

Cons:
* Buggy sync with Garmin/Strava.
* FTP tests didn't work at the time I tried it. (Support says it's a known
  error, should be fixed soon.)
* Subscription fee.
* Made for large screens. Smartphone works better than Zwift, but still an
  afterthought.
* Can't watch a video, only podcasts/audiobooks.

#### TrainerRoad

After having success connecting the Skillbike with both Zwift and Rouvy, I
thought anything that connects via Bluetooth would just work. [TrainerRoad][]
has a reputation of being an excellent option for people who train seriously.
They don't waste time on pretty virtual cycling features and instead focus on
being the best for effective training. Machine learning and all that. Sounds
good, maybe I'd be able to watch a video in split screen and get the most
out of the time spent pedalling.

Long story short, it doesn't work with the Skillbike. It took several tries to
connect with it (both Zwift/Rouvy connected almost immediately) and even then,
it was only connected as a power meter, not as a controllable smart trainer,
so it didn't adjust resistance or set target power in ERG mode.

At this point I've already wasted a lot of time so I didn't bother contacting
support and just asked for a refund. I really do wish this worked, however,
because TrainerRoad would be ideal for my goals. Perhaps I shall revisit this
later.

[TrainerRoad]: https://www.trainerroad.com/

Pros:
* Garmin officially supports this, so as with Zwift, I'd get all the benefits of
  having the data synced.
* Focused on training, not a distracting virtual cycling game.
* Lots of workouts to choose from. Training plans, possibly self-adapting to
  what I actually end up doing.
* Can probably watch a video, listen to podcasts, whatever.
* From what I've heard, able to estimate FTP continuously, not needing a
  periodic FTP test.

Cons:
* Doesn't see Skillbike as a smart trainer, just as a power meter. Unable to
  control resistance (target power).
* Subscription fee. Additionally, free trial isn't free—it's give us your
  credit card details and we'll refund if you're not satisfied.

#### Wahoo SYSTM

There's an alternative to TrainerRoad from Wahoo: formerly called the
Sufferfest, now [Wahoo SYSTM][SYSTM]. On paper, it should be more or less the
same style as TrainerRoad: no-bullshit training focused app. In practice, it's
indeed the same—only treats the Skillbike as a power meter, but cannot control
it.

Unlike TrainerRoad, they responded to my feedback with a note saying that
getting this working likely involves some help from Technogym, and that they'd
be glad if I complained to those as well. And that I can get in touch so we
can work together on resolving this. If/when time allows, I might…

[SYSTM]: https://wahoofitness.com/systm

Pros:
* Same as TrainerRoad, except for the FTP estimation.

Cons:
* Same as TrainerRoad.

#### Wahoo RGT

[Wahoo RGT][RGT], a recent (2022) acquisition of theirs, is a virtual cycling
game like Zwift. I managed to log into the app exactly once, but when I
changed into lycra and made my way down to the gym, it started crashing, and
no amount of force stops and reinstalls would help.

Another half an hour of standing in the gym with a smartphone in my hand,
having others ask me whether I'm waiting for the equipment they're currently
using… I did end up looking like a mad man after all, it seems. Can't be
blamed for not following up with Wahoo's support, can I? :-)

[RGT]: https://www.rgtcycling.com/

Pros:
* No idea…

Cons:
* Crashes immediately after sign-in.
* I'd be surprised if it supported Skillbike as a controllable smart trainer
  when SYSTM doesn't.
* Likely to have similar cons as Zwift: not what I'm looking for with just a
  small smartphone screen.

#### Skillbike itself revisited

I think I've tried everything but still don't have a winner:

* I could strap a magnifying glass to my phone and pay double the [Cycling UK
  Household membership](https://www.cyclinguk.org/membership-types) for
  Zwift. I might also figure out a way to strap a tablet onto the Skillbike
  somehow.
* Or I can pay that amount for a Rouvy family membership and share the
  struggles of manually syncing rides with my wife. She probably wouldn't even
  mind not being able to take an FTP test.
* Or just use the Skillbike itself, but plan and track my workouts without
  the assistance of Garmin or some other app.
* (Or just buy another smart trainer, or go to a gym that has one, or get a
  power meter and ride outside. Valid options but let's stick with the
  Skillbike for this blog post.)

Well actually, there's one thing I haven't tried yet…

In the short time I had outside of standing in the middle of a gym with a
phone in my hand, I did a little experiment: if [Physio TrueUp][] won't sync
the [fixed TCX][skillbike-tcx] to my watch, what if I upload it there using a
USB cable? Didn't work either. Actually, not only were training metrics not
updated, the watch didn't show the activity at all. A-ha! The watch doesn't
understand TCX, what if I gave it [FIT][] instead?

A weekend of hacking later, I had a Python script that loads the not entirely
valid TCX file from Skillbike/mywellness and uses the [Garmin FIT SDK][] (via
[jpype][], a cross-language bridge to allow using the Java library directly
from Python) to generate a FIT file with faked source as Zwift to trick
[Physio TrueUp][] into syncing it to the watch:
[technogym-tcx-to-garmin-fit.py][skillbike-fit].

And guess what? It worked on the first try! (Except for a little mistake in
timestamp conversion. Syncing a ride 20 years in the future wiped the training
metrics from the watch, so I had to ride some more to get them back.)

[FIT]: https://developer.garmin.com/fit/protocol/
[jpype]: https://github.com/jpype-project/jpype
[skillbike-fit]: https://github.com/liskin/dotfiles/blob/6c3ccf3f0ca8813e71f047c5060644bc08467c24/bin/technogym-tcx-to-garmin-fit

Pros:
* Synced into Strava, and now also Garmin.
* Now that I sync this into Garmin as a fake Zwift ride, I get all the data
  and suggestions as if it was a Zwift ride.
* No subscription fee.
* Larger display than my smartphone, and the smartphone is free to play
  videos.

Cons:
* Needs manual conversion and sync. (I'll automate this later and update the
  post.)
* [Very limited selection of workouts][skillbike-workouts]. It's possible to
  create a custom workout and also adjust the power mid-ride, but it's
  annoying having to do this manually before every workout. There is an option
  to repeat a previous workout (by date, not by name), but I haven't tested
  this yet.

### Conclusion

After having spent a weekend hacking the TCX→FIT conversion tool, I'm
obviously a victim of the sunken cost fallacy and will prefer riding the
Skillbike workouts for some time. Objectively speaking, however, learning
about [FIT][] and [jpype][] was worth it anyway, and I will reevaluate some of
the mentioned apps later. Perhaps some of my friends will nudge me into riding
Zwift with them in winter, and I'll revisit the option of strapping a tablet
onto the Skillbike. Rouvy may well fix all the problems by that time, too, and
we can ride there instead.

Until winter, DIY Python script it is, though!

(Also, now that I know how to generate a FIT file, I can try to sync
[Skillrow][] workouts as well. Those are only visible in the [mywellness][]
cloud, however, so it'll be more involved than just downloading a TCX from
Strava.)

[Skillrow]: https://www.technogym.com/int/skillrow.html

### Appendix A: Technogym/mywellness apps and logging into the Skillbike

In order to not disrupt the post with unimportant details, I didn't mention
one other hurdle when connecting the Skillbike with external devices. Despite
its [instruction manual][skillbike-manual] claiming otherwise, it's necessary
to log into the Skillbike using a mywellness account before the devices dialog
can be used.

At first, the Skillbike was offline, and thus useless. Fortunately, the
[manual][skillbike-manual] documents how to access the hidden configuration
screen and I managed to connect it to WiFi.

Then, there are two apps which can be used for the login:
* older, [mywellness app][mywellness-app], rated 2.7<emoji>⭐</emoji>
* newer, [Technogym app][technogym-app], rated 3.8<emoji>⭐</emoji>

I didn't even try the first one. The second one works, although only using the
QR code (a fallback), not using NFC/Bluetooth (which is what the app tells you
to do). A sub-4.0 rating is well deserved.

That being said, there are some cycling training plans in the app, so perhaps
it can be used to load more interesting workouts onto the Skillbike. My wife
successfully managed to let the app launch a treadmill workout (although she
couldn't really choose what workout…), adjusting the speed and incline
throughout, so it's not entirely useless. I'll experiment with this later,
once I no longer feel bad for playing with my phone in the gym. :-)

[mywellness-app]: https://play.google.com/store/apps/details?id=com.technogym.mywellness
[technogym-app]: https://play.google.com/store/apps/details?id=com.technogym.tgapp
