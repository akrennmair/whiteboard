DART_SRC=$(wildcard *.dart)
JS_SRC=$(patsubst %.dart,%.dart.js,$(DART_SRC))
GOBIN=whiteboard
GOSRC=$(wildcard *.go)

all: $(JS_SRC) $(GOBIN)

%.dart.js: %.dart
	$$DART_SDK/bin/dart2js --out=$@ $< || ( $(RM) $@ && exit 1 )

$(GOBIN): $(GOSRC)
	go build -o $@

clean:
	$(RM) $(JS_SRC) $(GOBIN)

