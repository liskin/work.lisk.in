MAKECMDGOALS := $(filter-out build-prod,$(MAKECMDGOALS))

# Forward all targets to just
.PHONY: _just_default_ $(MAKECMDGOALS)
_just_default_ $(MAKECMDGOALS) &::
	$(warning $(shell tput bold setaf 1)Use just instead of make.$(shell tput sgr0))
	@just $(MAKECMDGOALS)

build-prod:
	-git fetch --unshallow
	_plugins/git-restore-mtime.py --commit-time
	jekyll build --verbose --trace
