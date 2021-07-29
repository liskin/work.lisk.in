export BUNDLE_PATH ?= $(CURDIR)/.bundle/gems

.PHONY: build
build: .bundle/.done
	bundle exec jekyll build --drafts

.PHONY: serve
serve: .bundle/.done
	bundle exec jekyll serve --drafts --host localhost --port 12345 --livereload

.PHONY: serve
serve-public: .bundle/.done
	bundle exec jekyll serve --drafts --host 0.0.0.0 --port 12123 --livereload --livereload-port 12124

.PHONY: github-report
github-report:
	./_github.sh report >_includes/github.md

.PHONY: pushl
pushl:
	pushl --cache _pushl_cache -vv https://work.lisk.in/atom.xml

.bundle/.done: Gemfile
	bundle install
	touch $@

.PHONY: clean
clean:
	$(RM) -r Gemfile.lock .bundle .sass-cache _site
