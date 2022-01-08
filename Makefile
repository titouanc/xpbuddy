VERSION = $(shell git describe --always --tags)

all: test dist

dist: xpmeter-$(VERSION).zip

test:
	lua test.lua

clean:
	rm -rf xpmeter *.zip

.PHONY: all clean dist test

xpmeter: src/*.lua
	mkdir -p $@
	cp $^ $@/

xpmeter-$(VERSION).zip: xpmeter xpmeter/xpmeter.toc
	zip $@ -r $<

xpmeter/xpmeter.toc: src/xpmeter.toc.tpl .git
	VERSION=$(VERSION) envsubst < $< > $@
