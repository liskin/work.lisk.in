CONFIG = _config.github-defaults.yml,_config.yml,_config.github-overrides.yml

.PHONY: build
build:
	jekyll build --config $(CONFIG) --drafts

.PHONY: serve
serve:
	jekyll serve --config $(CONFIG) --drafts --host localhost --port 12345 --livereload

.PHONY: serve-public
serve-public:
	jekyll serve --config $(CONFIG) --drafts --host 0.0.0.0 --port 12123 --livereload --livereload-port 12124

.PHONY: github-report
github-report:
	./_github.sh report >_includes/github.md

.PHONY: pushl
pushl:
	pushl --cache _pushl_cache -vv https://work.lisk.in/atom.xml
