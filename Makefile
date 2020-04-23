.PHONY: build
build:
	jekyll build --config _config.yml,_config.github.yml

.PHONY: serve
serve:
	jekyll serve --config _config.yml,_config.github.yml --host localhost --port 12345 --livereload
