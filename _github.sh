#!/usr/bin/env bash

set -eu -o pipefail
shopt -s lastpipe inherit_errexit

## include ~/bin/.o
#!  bash
# shellcheck disable=SC2239

# shellcheck disable=SC2218
exec {_o_stderr}>&2
# shellcheck disable=SC2120
function exec { if (( $# )); then builtin exec {_o_stderr}>&- "$@"; else builtin exec "$@"; fi; }

if [[ -t $_o_stderr ]]; then _o_tput_bold=$(tput bold || :); _o_tput_reset=$(tput sgr0 || :); else _o_tput_bold=; _o_tput_reset=; fi
function o { printf -->&$_o_stderr "%s%s:%s%s\\n" "$_o_tput_bold" "${0##*/}" "$_o_tput_reset" "$(printf " %q" "$@")"; "$@"; }
function oo { printf -->&$_o_stderr "%s%s:%s %s\\n" "$_o_tput_bold" "${0##*/}" "$_o_tput_reset" "$*"; }
## end include ~/bin/.o

function github-user-repos {
	o gh api --paginate users/"${1:?user}"/repos | jq --compact-output '.[]'
}

function github-watched-repos {
	o gh api --paginate users/"${1:?user}"/subscriptions | jq --compact-output '.[]'
}

function filter-original {
	jq --compact-output --slurp 'map(select(.fork | not)) | .[]'
}

function filter-public {
	jq --compact-output --slurp 'map(select(.private | not)) | .[]'
}

function filter-active {
	jq --compact-output --slurp 'map(select(.archived | not)) | .[]'
}

function filter-archived {
	jq --compact-output --slurp 'map(select(.archived)) | .[]'
}

function filter-not-owned-by {
	jq --compact-output --slurp --arg owner "${1:?user}" 'map(select(.owner.login != $owner)) | .[]'
}

function filter-admin {
	jq --compact-output --slurp 'map(select(.permissions.admin)) | .[]'
}

function filter-push {
	jq --compact-output --slurp 'map(select(.permissions.push)) | .[]'
}

function filter-pushed-recently {
	local date
	date=$(date --iso-8601 -d "now - ${1:?ago}")
	jq --compact-output --slurp --arg date "$date" 'map(select(.pushed_at > $date)) | .[]'
}

function filter-stars-at-least {
	jq --compact-output --slurp --argjson min "${1:?min}" 'map(select(.stargazers_count >= $min)) | .[]'
}

function sort-by-stars {
	jq --compact-output --slurp 'sort_by(.stargazers_count) | reverse | .[]'
}

function sort-by-modification {
	jq --compact-output --slurp 'sort_by(.pushed_at) | reverse | .[]'
}

function set-difference {
	jq --null-input --raw-input --raw-output --arg b "${1?}" '[inputs] - ($b | split("\\s+";"")) | .[]'
}

function names {
	jq --raw-output '."name"'
}

function full-names {
	jq --raw-output '."full_name"'
}

function format-pin {
	local user repo
	: "${1:?}"
	user=${1%%/*}
	repo=${1#*/}
	echo "[![$1](https://github-stats-extended.vercel.app/api/pin/?username=$user&repo=$repo&show_owner=true)](https://github.com/$1)"
}

function format-pins {
	local r
	while read -r r; do
		format-pin "$r"
	done
}

function report {
	user=${1:-liskin}
	hidden_gems_list=(
		liskin/strava-ical
		liskin/foursquare-swarm-ical
		liskin/arbtt-chart
		liskin/empty-tab
	)
	ignore_list=(
		liskin/covid19-bloom
		liskin/patches
		xmonad/.github
		xmonad/X11-xft
		xmonad/xmonad-docs
		xmonad/xmonad-extras
		xmonad/xmonad-testing
		xmonad/xmonad-web
	)

	repos=$(github-user-repos "$user" | filter-public | filter-original)
	active_repos=$(filter-active <<<"$repos")
	archived_repos=$(filter-archived <<<"$repos")

	starred_active=$(<<<"$active_repos" filter-stars-at-least 25 | sort-by-stars | full-names | set-difference "${ignore_list[*]}")
	hidden_gems=$(<<<"${hidden_gems_list[*]}" xargs -n1 | set-difference "$starred_active")
	starred_archived=$(<<<"$archived_repos" filter-stars-at-least 10 | sort-by-stars | full-names | set-difference "${ignore_list[*]}")

	watched_active=$(github-watched-repos "$user" | filter-public | filter-original | filter-active)
	maintained=$(<<<"$watched_active" filter-not-owned-by "$user" | filter-push | sort-by-stars | full-names)
	maintained=$(<<<"$maintained" set-difference "${ignore_list[*]}")

	echo '### Popular projects (co-maintainer)'
	echo '<div markdown="span" class="grid-2 dark-img-filter">'
	format-pins <<<"$maintained"
	echo '</div>'
	echo
	echo '### Popular projects (author)'
	echo '<div markdown="span" class="grid-2 dark-img-filter">'
	format-pins <<<"$starred_active"
	echo '</div>'
	echo
	echo '### Hidden gems'
	echo '<div markdown="span" class="grid-2 dark-img-filter">'
	format-pins <<<"$hidden_gems"
	echo '</div>'
	echo
	echo '### Formerly popular, now archived projects'
	echo '<div markdown="span" class="grid-2 dark-img-filter">'
	format-pins <<<"$starred_archived"
	echo '</div>'
}

function not-watching {
	user=${1:-liskin}
	repos=$(github-user-repos "$user" | full-names)
	watching=$(github-watched-repos "$user" | full-names)
	set-difference <<<"$repos" "$watching"
}

function list-not-watching {
	not-watching | while read -r repo; do
		echo "https://github.com/$repo"
	done
}

function watch-not-watching {
	not-watching | while read -r repo; do
		o gh api -X PUT /repos/"$repo"/subscription -f subscribed=true
	done
}

"$@"
