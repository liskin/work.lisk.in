.PHONY: build
build:
	jekyll build --config _config.yml,_config.github.yml --drafts

.PHONY: serve
serve:
	jekyll serve --config _config.yml,_config.github.yml --drafts --host localhost --port 12345 --livereload

.PHONY: serve-public
serve-public:
	jekyll serve --config _config.yml,_config.github.yml --drafts --host 0.0.0.0 --port 12123 --livereload --livereload-port 12124
