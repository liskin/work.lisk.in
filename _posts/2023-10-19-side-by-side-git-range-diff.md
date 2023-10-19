---
layout: default
title: 'Side by side git-range-diff'
comments_issue: 16
image: summary.png
large_image: true

---

[`git range-diff`][git-range-diff] compares two commit ranges (two versions of
a branch, e.g. before and after a rebase). Its output is difficult to
comprehend, though. It's a diff between diffs, presented in one dimension
using two columns of pluses/​minuses/​spaces. Wouldn't it be better
if we used two dimensions and some nice colors?

{% include toc.md %}

### Motivation/Example

To illustrate my point, let's take a work-in-progress[^at-the-time-of-writing]
[pull request from
xmonad-contrib](https://github.com/xmonad/xmonad-contrib/pull/836), `git
rebase` it to autosquash the fixup commits, and then use [`git
range-diff`][git-range-diff] to see what the rebase actually did:

```console
$ gh pr checkout 836
$ git checkout -b wx-partial-rebase
$ git rebase -i --keep-base --autosquash origin/master
$ git range-diff wx-partial...wx-partial-rebase
```

<figure markdown="block">
<figcaption>git range-diff</figcaption>
{% include {{ page.slug }}/git-range-diff.html %}
</figure>

This is a simple example—neither the old (05a5291e) nor new (d5c45f98) commits
remove any lines, so the inner column is always `+`. Some of you can therefore
figure out that the difference is that the old commit adds a line with "TODO"
in it, while the new adds a line (somewhere else!) with a meaningful error
message instead.

Now let's look at it side by side (in 2 dimensions):

```console
$ git si-range-diff wx-partial...wx-partial-rebase
```
(note: si-range-diff is my alias; don't try this at home—just yet)

<figure markdown="block">
<figcaption>git si-range-diff</figcaption>
{% include {{ page.slug }}/git-si-range-diff.html %}
</figure>

Much better. It's easier to see what's going on here. Left side is the old
diff, right side is the new one. Both are syntax-highlighted using foreground
(text) colours. The inter-diff diff is syntax-highlighted using background
colours—the removed line on the left side is dark red, the added one on the
right side is darkish green.

Here's a longer example from the Linux kernel, which I believe requires
superhuman abilities to understand (made more difficult by the `##` and `@@`
lines appearing in the context of neighbouring diff hunks):

<details markdown="block">
<summary>Expand/Collapse</summary>
<figure markdown="block">
<figcaption>git range-diff</figcaption>
{% include {{ page.slug }}/git-range-diff-kernel.html %}
</figure>
<figure markdown="block">
<figcaption>git si-range-diff</figcaption>
{% include {{ page.slug }}/git-si-range-diff-kernel.html %}
</figure>
</details>

### Implementation

Ideally, this side-by-side view of [`git range-diff`][git-range-diff] would
just appear after I configure `pager.range-diff='delta -s'` in
[`.gitconfig`][git-config]. Unfortunately, it's not that easy:

* [delta][] can't parse the output of [`git range-diff`][git-range-diff]
* that output [isn't even meant to be
  machine-readable](https://git-scm.com/docs/git-range-diff#_output_stability)

Nevertheless, I hacked together a proof-of-concept preprocessor that takes the
output of [`git range-diff`][git-range-diff] and turns it into something that
[delta][] parses and presents nicely to a human:

<figure markdown="block">
<figcaption markdown="span">[git-range-diff-delta-preproc][]</figcaption>
```bash
#!/usr/bin/env bash

# preprocessor for "git range-diff" output to be fed into "delta" for side-by-side diff
# see ~/.config/git/config for usage (si-range-diff alias)
#
# depends on ansi2txt from https://github.com/kilobyte/colorized-logs
#
# developed against git 2.40 - git range-diff doesn't have stable output, might need adjustments
# see https://github.com/git/git/blob/ee48e70a829d1fa2da82f14787051ad8e7c45b71/range-diff.c#L376

set -eu

coproc ansi2txt {
	stdbuf -oL ansi2txt
}

while IFS= read -r l; do
	# decolor line for matching/processing
	printf "%s\n" "$l" >&"${ansi2txt[1]}"
	IFS= read -r ll <&"${ansi2txt[0]}"

	if [[ $ll == "    @@ "* ]]; then # hunk header line
		# fake hunk header for delta
		printf "@@ -0,0 +0,0 @@ %s\n" "${ll#    @@ }"
	elif [[ $ll == "    "* ]]; then # hunk diff line
		# un-indent diff
		printf "%s\n" "${ll#    }"
	else # pair header line
		# horizontal separator before the line
		tput setaf 39; tput setab 235; printf %"$(tput cols)"s | sed 's/ /─/g'; tput sgr0
		printf "%s\n" "$l"

		if [[ $ll =~ ^[[:digit:]][[:digit:]]*:"  "([[:alnum:]][[:alnum:]]*)" ! "[[:digit:]][[:digit:]]*:"  "([[:alnum:]][[:alnum:]]*)" " ]]; then
			# fake file header for delta to syntax highlight as patch
			echo "--- ${BASH_REMATCH[1]}.patch"
			echo "+++ ${BASH_REMATCH[2]}.patch"
		else
			# extra line for unmatched commits
			echo
		fi
	fi
done
```
</figure>

To use this, override `pager.range-diff` when invoking `git range-diff`, like
so:
```console
$ git -c pager.range-diff='
        git-range-diff-delta-preproc \
        | delta \
                --side-by-side \
                --file-style=omit \
                --line-numbers-left-format="" \
                --line-numbers-right-format="│ " \
                --hunk-header-style=syntax \
        ' range-diff wx-partial...wx-partial-rebase
```

(Or just steal all the delta-related bits from [my git
config](https://github.com/liskin/dotfiles/blob/b13cc7da57c223a6d2e00acd99234731efaa62fe/.config/git/config#L61).)

Yeah, I know, it's a massive hack. <emoji>😞</emoji>

### Next steps

To make this easier to use for the general public, we'd need:

* machine-readable output from [`git range-diff`][git-range-diff] (other git
  commands have that, e.g. `git status --porcelain`)
* implement parsing of that output in [delta][]

Unfortunately, I can't volunteer to do either at this point[^burnout],
apologies.

[^burnout]:
    At present, I'm (very slowly) recovering from a mental health crisis. Just
    getting this blog post out took me several months.

    (This isn't a call for help, it's just context for why I can't be expected
    to do anything besides publishing this.)

[git-range-diff]: https://git-scm.com/docs/git-range-diff
[git-config]: https://git-scm.com/docs/git-config
[delta]: https://github.com/dandavison/delta
[git-range-diff-delta-preproc]: https://github.com/liskin/dotfiles/blob/b13cc7da57c223a6d2e00acd99234731efaa62fe/bin/git-range-diff-delta-preproc

---

[^at-the-time-of-writing]:
    At the time of writing.
