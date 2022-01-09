VERSION = $(shell git describe --always --tags)

all: test dist

dist: xpbuddy-$(VERSION).zip

test:
	lua runtests.lua

clean:
	rm -rf xpbuddy *.zip

.PHONY: all clean dist test

xpbuddy: src/*.lua
	mkdir -p $@
	cp $^ $@/

xpbuddy-$(VERSION).zip: xpbuddy xpbuddy/xpbuddy.toc
	zip $@ -r $<

xpbuddy/xpbuddy.toc: src/xpbuddy.toc.tpl .git
	VERSION=$(VERSION) envsubst < $< > $@
