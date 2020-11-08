#!/usr/bin/env bash

set -eu -o pipefail
shopt -s lastpipe inherit_errexit

function o { printf -->&2 "%s:%s\\n" "${0##*/}" "$(printf " %q" "$@")"; "$@"; }

function do-curl {
	if [[ -z ${GITHUB_TOKEN-} ]]; then
		GITHUB_TOKEN=$(yq -r '."github.com"[0].oauth_token' ~/.config/hub)
	fi

	curl --silent --show-error --fail -H "Authorization: token ${GITHUB_TOKEN}" "$@"
}

function github-paginate() (
	page="page=1"
	exec {stdout}>&1

	while [[ -n $page ]]; do
		o do-curl --get "$@" --data-urlencode "$page" \
			--output /dev/fd/${stdout} --dump-header /dev/fd/1 \
			| gawk '$1 == "Link:" && match($0, /<[^<>]*[&?](page=[0-9]+)[^<>]*>; rel="next"/, m) { print m[1] }' \
			| { read -r page || :; }
	done
)

function github-user-repos {
	o github-paginate "https://api.github.com/users/${1:?user}/repos" | jq --compact-output '.[]'
}

function github-watched-repos {
	o github-paginate "https://api.github.com/users/${1:?user}/subscriptions" | jq --compact-output '.[]'
}

function filter-my-repos {
	jq --compact-output --slurp 'map(select((.private | not) and (.fork | not))) | .[]'
}

function filter-active-repos {
	jq --compact-output --slurp 'map(select(.archived | not)) | .[]'
}

function filter-archived-repos {
	jq --compact-output --slurp 'map(select(.archived)) | .[]'
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

function format-pin {
	echo "[![${2:?}](https://github-readme-stats.vercel.app/api/pin/?username=${1:?}&repo=$2&show_owner=true)](https://github.com/$1/$2)"
}

function format-pins {
	local r
	while read -r r; do
		format-pin "${1:?}" "$r"
	done
}

function report {
	user=${1:-liskin}
	hidden_gems="cervi foursquare-swarm-ical gh-problem-matcher-wrap emoji-rofi-menu empty-tab"

	repos=$(github-user-repos "$user")
	my_repos=$(filter-my-repos <<<"$repos")
	active_repos=$(filter-active-repos <<<"$my_repos")
	archived_repos=$(filter-archived-repos <<<"$my_repos")

	starred_active=$(<<<"$active_repos" sort-by-stars | names | head -10)
	hidden_gems=$(set-difference "$hidden_gems" "$starred_active")
	starred_archived=$(<<<"$archived_repos" sort-by-stars | names | head -6)

	echo '### Popular projects'
	echo '<div markdown="span" class="grid-2">'
	format-pins "$user" <<<"$starred_active"
	echo '</div>'
	echo
	echo '### Hidden gems'
	echo '<div markdown="span" class="grid-2">'
	format-pins "$user" <<<"$hidden_gems"
	echo '</div>'
	echo
	echo '### Formerly popular, now archived projects'
	echo '<div markdown="span" class="grid-2">'
	format-pins "$user" <<<"$starred_archived"
	echo '</div>'
}

function not-watching {
	user=${1:-liskin}
	repos=$(github-user-repos "$user" | names)
	watching=$(github-watched-repos "$user" | names)
	not_watching=$(set-difference "$repos" "$watching")
	for repo in $not_watching; do
		echo "https://github.com/$user/$repo"
	done
}

"$@"
