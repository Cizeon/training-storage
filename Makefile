FORGE=forge
CAST=cast

.PHONY: coverage clean test deploy

all:
	- $(FORGE) build

test:
	- $(FORGE) test

coverage:
	- rm -rf coverage && mkdir coverage
	- $(FORGE) coverage --report lcov && genhtml lcov.info --branch-coverage --output-dir coverage

clean:
	- rm -rf broadcast coverage lcov.info .git
	- $(FORGE) clean