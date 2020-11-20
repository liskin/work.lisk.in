---
layout: default
title: 'Even faster bash startup'
comments_issue: 8
image: summary.png
large_image: true

---

I sped up bash startup from 165 ms to 40 ms. It's actually noticeable.
Why and how did I do it?

{% include toc.md %}

### Motivation

Whenever I need to quickly look something up (or use a calculator), I open a
new terminal (using a keyboard shortcut) and start typing into it. Slow bash
startup disrupts this workflow as I would often type before the shell prompt:

![messed up prompt]({{ "/img" | relative_url }}/{{ page.slug }}/mistype.png)

[Daniel Parker][] recently wrote an excellent blog post [Faster Bash
Startup][] detailing his journey from 1.7 seconds to 210 ms. I start at 165 ms
and need to go significantly lower than Daniel, therefore different techniques
will be needed.

[Daniel Parker]: https://twitter.com/danpker
[Faster Bash Startup]: https://danpker.com/posts/2020/faster-bash-startup/

### Investigation

[hyperfine]: https://github.com/sharkdp/hyperfine

[hyperfine][] is a brilliant command-line tool for benchmarking commands that
I discovered recently (thanks to Daniel!), so let's see where we are now:

```
[tomi@notes ~]$ hyperfine 'bash -i'
Benchmark #1: bash -i
  Time (mean ± σ):     165.8 ms ±   0.7 ms    [User: 156.3 ms, System: 12.8 ms]
  Range (min … max):   164.9 ms … 167.1 ms    17 runs
```

Now we need to find out what's taking so long. [How to profile a bash shell
script slow startup?][bash-profiling] Most Stack Overflow answers suggest some
variant of `set -x`, which will help us find any single command that takes
unusually long.

[bash-profiling]: https://stackoverflow.com/questions/5014823/how-to-profile-a-bash-shell-script-slow-startup/20855353

#### man

In my case, that command was `man -w`, specifically [this piece of my
`.bashrc.d/​10_env.sh`](https://github.com/liskin/dotfiles/blob/7d14190467fe22bf5d4f85a7b202118d2341e3ed/.bashrc.d/10_env.sh#L8-L10):

```bash
export MANPATH=$HOME/.local/share/man:
# FIXME: workaround for /usr/share/bash-completion/completions/man
MANPATH=$(man -w)
```

Turns out none of this is needed any more, `man` and `manpath` now add
`~/.local/​share/​man` automatically so I can just drop it and save more than
100 ms[^man-seccomp].

[^man-seccomp]:
    At the time of publishing this post, `man -w` no longer takes 100+ ms
    thanks to [several performance improvements in
    libseccomp](https://github.com/seccomp/libseccomp/blob/2366f6380198c7af23d145a153ccaa9ba37f9db1/CHANGELOG#L13-L14)

#### death by a thousand cuts

But that's it. No other single command stands out, it's just a lot of small
things that add up. Daniel says “it has to take _some_ time,” and he's mostly
right, but I still have one trick up my sleeve.

My `.bashrc` is split into several smaller parts in `~/.bashrc.d`, so I can
profile these and see if anything stands out. My
[`.bashrc`](https://github.com/liskin/dotfiles/blob/68964611b4b578b646cf5f13a47a4ee77e93e740/.bashrc)
thus becomes:

```bash
for i in ~/.bashrc.d/*.sh; do
	if [[ $__bashrc_bench ]]; then
		TIMEFORMAT="$i: %R"
		time . "$i"
		unset TIMEFORMAT
	else
		. "$i"
	fi
done; unset i
```

Let's see what happens…

```
[tomi@notes ~]$ __bashrc_bench=1 bash -i
/home/tomi/.bashrc.d/10_env.sh: 0,118
/home/tomi/.bashrc.d/20_history.sh: 0,000
/home/tomi/.bashrc.d/20_prompt.sh: 0,002
/home/tomi/.bashrc.d/30_completion_git.sh: 0,000
/home/tomi/.bashrc.d/31_completion.sh: 0,011
/home/tomi/.bashrc.d/50_aliases.sh: 0,002
/home/tomi/.bashrc.d/50_aliases_sudo.sh: 0,000
/home/tomi/.bashrc.d/50_functions.sh: 0,001
/home/tomi/.bashrc.d/50_git_dotfiles.sh: 0,008
/home/tomi/.bashrc.d/50_mc.sh: 0,000
/home/tomi/.bashrc.d/90_fzf.sh: 0,011
```

118 ms in `10_env.sh` was caused by `man -w` and we know what to do with that.

#### completions

11 ms in `31_​completion.sh` which loads [bash-completion][]. That's
certainly better than Daniel's 235 ms, probably because up-to-date
bash-completion only loads a few necessary completions and defers everything
else to being loaded on demand. I couldn't live without the completions, so
11 ms is a fair price.

[bash-completion]: https://github.com/scop/bash-completion

8 ms for `50_​git_​dotfiles.sh`, which defines a few aliases and
sets up git completions for my `git-dotfiles` alias, seems too much, though.
Good news is that we don't need to drop this. We can use bash-completion's
on-demand loading. Whenever completions for command `cmd` are needed for the
first time, bash-completion looks for
`~/.local/​share/​bash-completion/​completions/​cmd` or
`/usr/​share/​bash-completion/​completions/​cmd`.

Therefore,
[`~/.local/​share/​bash-completion/​completions/​git-dotfiles`](https://github.com/liskin/dotfiles/blob/68964611b4b578b646cf5f13a47a4ee77e93e740/.local/share/bash-completion/completions/git-dotfiles)
becomes:

```
. /usr/share/bash-completion/completions/git
complete -F _git git-dotfiles
```

#### fzf

`90_fzf.sh` loads key bindings and completions code so that [fzf][] is used
when searching through history, completing `**` in filenames, etc. Well worth
the 11 ms it needs to load[^fzf].

[fzf]: https://github.com/junegunn/fzf

[^fzf]:
    At the time of publishing this post, the latest fzf release
    ([0.24.3](https://github.com/junegunn/fzf/releases/tag/0.24.3)) loads
    twice as long (20+ ms). I fixed this in
    [#2246](https://github.com/junegunn/fzf/pull/2246) and
    [#2250](https://github.com/junegunn/fzf/pull/2250), but it might take a
    short while to be released and find its way to distributions.

#### are we done yet?

After these changes, I got:

```
[tomi@notes ~]$ __bashrc_bench=1 bash -i
/home/tomi/.bashrc.d/10_env.sh: 0,001
/home/tomi/.bashrc.d/20_history.sh: 0,000
/home/tomi/.bashrc.d/20_prompt.sh: 0,002
/home/tomi/.bashrc.d/30_completion_git.sh: 0,000
/home/tomi/.bashrc.d/31_completion.sh: 0,012
/home/tomi/.bashrc.d/50_aliases.sh: 0,002
/home/tomi/.bashrc.d/50_aliases_sudo.sh: 0,000
/home/tomi/.bashrc.d/50_functions.sh: 0,001
/home/tomi/.bashrc.d/50_git_dotfiles.sh: 0,000
/home/tomi/.bashrc.d/50_mc.sh: 0,000
/home/tomi/.bashrc.d/90_fzf.sh: 0,011
```

That's 29 ms, brilliant! Or… is it? <emoji>🤔</emoji>

```
[tomi@notes ~]$ hyperfine 'bash -i'
Benchmark #1: bash -i
  Time (mean ± σ):      55.7 ms ±   1.0 ms    [User: 47.6 ms, System: 11.1 ms]
  Range (min … max):    54.8 ms …  58.9 ms    53 runs
```

#### history

Some of those additional 26 ms are spent reading my huge
(`HISTSIZE=​50000`) `.bash_​history` file. I will skip the details
about how I investigated this, because I didn't: I stumbled upon this by
chance while testing something else.

We can see that using an empty history file brings us down to a little under
40 ms:

```
[tomi@notes ~]$ HISTFILE=/tmp/.bash_history_tmp hyperfine 'bash -i'
Benchmark #1: bash -i
  Time (mean ± σ):      38.6 ms ±   0.7 ms    [User: 34.0 ms, System: 7.8 ms]
  Range (min … max):    37.8 ms …  42.3 ms    75 runs
```

Now, cutting 17 ms by sacrificing the shell history is probably not a good
deal for most people. I settled for setting up a systemd
[timer](https://github.com/liskin/dotfiles/blob/f978be7424946afebe56dbe5ecc85c9f36d1e057/.config/systemd/user/liskin-backup-bash-history.timer)
to [back up
`.bash_​history`](https://github.com/liskin/dotfiles/blob/f978be7424946afebe56dbe5ecc85c9f36d1e057/bin/liskin-backup-bash-history)
to git once a day and lowered `HISTSIZE` to 5000[^history]. This still keeps
my bash startup below 40 ms:

```
[tomi@notes ~]$ hyperfine 'bash -i'
Benchmark #1: bash -i
  Time (mean ± σ):      39.9 ms ±   0.5 ms    [User: 36.1 ms, System: 6.8 ms]
  Range (min … max):    39.1 ms …  42.1 ms    73 runs
```

[^history]:
    5000 is a bit limiting in practice, as it rolls over in a few weeks. In
    2020, you'd expect your shell to keep [unlimited
    history](https://superuser.com/questions/137438/how-to-unlimited-bash-shell-history)
    without slowdown. I will address this in another post soon.

### Conclusion

By dropping unnecessary invocation of `man -w`, deferring loading of git
completions to when they're needed, and shortening my shell history file, I
managed to speed up bash startup from 165 ms to 40 ms.

```
Benchmark #1: bash -i
  Time (mean ± σ):     165.8 ms ±   0.7 ms    [User: 156.3 ms, System: 12.8 ms]
  Range (min … max):   164.9 ms … 167.1 ms    17 runs
```

```
Benchmark #1: bash -i
  Time (mean ± σ):      39.9 ms ±   0.5 ms    [User: 36.1 ms, System: 6.8 ms]
  Range (min … max):    39.1 ms …  42.1 ms    73 runs
```

More importantly, I no longer type before the prompt, even if I try!

![not messed up prompt]({{ "/img" | relative_url }}/{{ page.slug }}/corrtype.png)

And at this point I can finally agree with Daniel that further tweaking will
only have diminishing returns[^latency]. <emoji>😊</emoji>

[^latency]:
    Some people may be even more sensitive to latency than me, but
    measurements by [Dan Luu](https://danluu.com/) suggest that at this scale
    there are other bottlenecks: [Computer
    latency](https://danluu.com/input-lag/), [Keyboard
    latency](https://danluu.com/keyboard-latency/).

---
