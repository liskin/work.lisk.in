#!/usr/bin/env bash

set -eu -o pipefail
shopt -s lastpipe inherit_errexit

function o { printf -->&2 "%s:%s\\n" "${0##*/}" "$(printf " %q" "$@")"; "$@"; }

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

function sort-by-stars {
	jq --compact-output --slurp 'sort_by(.stargazers_count) | reverse | .[]'
}

function sort-by-modification {
	jq --compact-output --slurp 'sort_by(.pushed_at) | reverse | .[]'
}

function set-difference {
	jq --null-input --raw-output --arg a "${1?}" --arg b "${2?}" '($a | split("\\s+";"")) - ($b | split("\\s+";"")) | .[]'
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
	echo "[![$1](https://github-readme-stats.vercel.app/api/pin/?username=$user&repo=$repo&show_owner=true)](https://github.com/$1)"
}

function format-pins {
	local r
	while read -r r; do
		format-pin "$r"
	done
}

function report {
	user=${1:-liskin}
	hidden_gems="liskin/strava-ical liskin/cervi liskin/emoji-rofi-menu liskin/empty-tab"
	maintained_ignore="xmonad/xmonad-extras xmonad/xmonad-web xmonad/xmonad-docs xmonad/xmonad-testing xmonad/.github"

	repos=$(github-user-repos "$user" | filter-public | filter-original)
	active_repos=$(filter-active <<<"$repos")
	archived_repos=$(filter-archived <<<"$repos")

	starred_active=$(<<<"$active_repos" sort-by-stars | full-names | head -10)
	hidden_gems=$(set-difference "$hidden_gems" "$starred_active")
	starred_archived=$(<<<"$archived_repos" sort-by-stars | full-names | head -2)

	watched_active=$(github-watched-repos "$user" | filter-public | filter-original | filter-active)
	maintained=$(<<<"$watched_active" filter-not-owned-by "$user" | filter-push | sort-by-stars | full-names)
	maintained=$(set-difference "$maintained" "$maintained_ignore" | head -10)

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
	not_watching=$(set-difference "$repos" "$watching")
	for repo in $not_watching; do
		echo "https://github.com/$repo"
	done
}

"$@"
