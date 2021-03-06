CLOSURE_LIBRARY=static/closure-library
CLOSURE_LINTER=closure-linter
COMPILER_JAR=compiler.jar
TARGETS=\
	static/webglmaps/deps.js \
	views/webglmaps/css.tpl \
	views/webglmaps/js.tpl

.PHONY: all
all: webglmaps lint

.PHONY: webglmaps
webglmaps: debug compiled

.PHONY: compiled
compiled: \
	views/webglmaps/css.tpl \
	views/webglmaps/js.tpl

views/webglmaps/css.tpl: static/webglmaps/webglmaps.css
	cp $< $@

views/webglmaps/js.tpl: \
	$(filter-out $(TARGETS),$(shell find static/webglmaps -name \*.js)) \
	externs/webgl_extra.js \
	$(CLOSURE_LIBRARY) \
	$(COMPILER_JAR)
	$(CLOSURE_LIBRARY)/closure/bin/build/closurebuilder.py \
		--compiler_flags=--compilation_level=ADVANCED_OPTIMIZATIONS \
		--compiler_flags=--define=goog.DEBUG=false \
		--compiler_flags=--define=goog.dom.ASSUME_STANDARDS_MODE=true \
		--compiler_flags=--externs=externs/webgl_extra.js \
		--compiler_flags=--warning_level=VERBOSE \
		--compiler_jar=$(COMPILER_JAR) \
		--root=$(CLOSURE_LIBRARY)/ \
		--root=static/webglmaps/ \
		--namespace=webglmaps.main \
		--output_mode=compiled \
		--output_file=$@

.PHONY: debug
debug: static/webglmaps/deps.js

static/webglmaps/deps.js: \
	$(filter-out $(TARGETS),$(shell find static/webglmaps -name \*.js)) \
	$(CLOSURE_LIBRARY)
	$(CLOSURE_LIBRARY)/closure/bin/build/depswriter.py \
		--root_with_prefix="$(CLOSURE_LIBRARY)/closure/ ../" \
		--root_with_prefix="static/webglmaps/ ../../../webglmaps/" \
		--output_file=$@

.PHONY: lint
lint: $(CLOSURE_LINTER)
	$(CLOSURE_LINTER)/closure_linter/gjslint.py --strict $(filter-out $(TARGETS),$(shell find externs static/webglmaps -name \*.js))

.PHONY: clean
clean:
	rm -f $(TARGETS)

.PHONY: update
update: update-closure-compiler update-closure-library update-closure-linter

.PHONY: update-closure-compiler
update-closure-compiler:
	wget -O - http://closure-compiler.googlecode.com/files/compiler-latest.tar.gz | tar -Oxzf - compiler.jar > $(COMPILER_JAR)

.PHONY: update-closure-library
update-closure-library: $(CLOSURE_LIBRARY)
	( cd $(CLOSURE_LIBRARY) && svn update )

.PHONY: update-closure-linter
update-closure-linter: $(CLOSURE_LINTER)
	( cd $(CLOSURE_LINTER) && svn update )

$(CLOSURE_LIBRARY):
	mkdir -p $(dir $@)
	if [ -e ../closure-library ]; then ln -s ../../closure-library $@ ; else svn checkout http://closure-library.googlecode.com/svn/trunk/ $@ ; fi

$(CLOSURE_LINTER):
	if [ -e ../closure-linter ]; then ln -s ../closure-linter $@ ; else svn checkout http://closure-linter.googlecode.com/svn/trunk/ $@ ; fi

$(COMPILER_JAR):
	mkdir -p $(dir $@)
	if [ -e ../compiler.jar ] ; then ln -s ../compiler.jar $@ ; else wget -O - http://closure-compiler.googlecode.com/files/compiler-latest.tar.gz | tar -Oxzf - compiler.jar > $@ ; fi
