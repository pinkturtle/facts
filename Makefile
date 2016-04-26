default: Facts.js Facts.pack.js index.html

index.html: Documentation/index.*.html Documentation/core.css Documentation/index.css
	echo '<!DOCTYPE HTML><meta charset="UTF-8">' > $@
	echo '<title>Facts • playful outformation model for ECMAScript</title>' >> $@
	echo '<script src="Facts.pack.js"></script>' >> $@
	echo '<meta name="viewport" content="width=device-width">' >> $@
	echo '<link rel="icon" type="image/png" href="Documentation/images/icon.png">' >> $@
	echo '<style media="screen">' >> $@
	cat Documentation/core.css >> $@
	cat Documentation/index.css >> $@
	echo '</style>' >> $@
	echo '<body>' >> $@
	cat Documentation/index.header.html >> $@
	cat Documentation/index.foreword.html >> $@
	cat Documentation/index.downloads.html >> $@
	cat Documentation/index.tutorial.html >> $@
	cat Documentation/index.constructor.html >> $@
	cat Documentation/index.methods.html >> $@
	cat Documentation/index.properties.html >> $@
	cat Documentation/index.functions.html >> $@
	cat Documentation/index.installation.html >> $@
	cat Documentation/index.examples.html >> $@
	cat Documentation/index.appendix.html >> $@
	cat Documentation/index.nav.html >> $@
	cat Documentation/index.footer.html >> $@
	echo '</body>' >> $@
	echo '<script>' >> $@
	cat Documentation/scripts/highlight.pack.js >> $@
	cat Documentation/window.js >> $@
	cat Documentation/syntax.highlight.js >> $@
	cat Documentation/width.height.js >> $@
	cat Documentation/index.js >> $@
	cat Documentation/index.scroll.js >> $@
	cat Documentation/index.videos.js >> $@
	echo '</script>' >> $@

ECMAScript: Facts.js
	coffee --compile Documentation/*.coffee Tests/*.coffee

Facts.js: Facts.coffee
	@rm -f $@
	@echo "// https://pinkturtle.github.io/facts version 0.0.0" >> $@
	@echo "// Requires https://facebook.github.io/immutable-js" >> $@
	@echo "// ••••••••••••••••••••••••••••••••••••••••••••••••" >> $@
	@echo "// Facts.js (Public Domain)" >> $@
	coffee --compile --print Facts.coffee >> $@

Facts.pack.js: node_modules/immutable/dist/immutable.min.js Facts.js
	@rm -f $@
	@echo "// https://pinkturtle.github.io/facts version 0.0.0" >> $@
	@echo "// Includes https://facebook.github.io/immutable-js" >> $@
	@echo "// ••••••••••••••••••••••••••••••••••••••••••••••••" >> $@
	@echo "// immutable.min.js (© Facebook, Inc.)" >> $@
	cat node_modules/immutable/dist/immutable.min.js >> $@
	@echo "" >> $@
	@echo "// ••••••••••••••••••••••••••••••••••••••••••••••••" >> $@
	@echo "// Facts.compressed.js (Public Domain)" >> $@
	uglifyjs Facts.js --mangle >> $@

node_modules/immutable/dist/immutable.min.js:
	npm install

Tests/window.test.pack.js: Tests/*.coffee
	coffee --compile Tests/*.coffee
	browserify Tests/*Tests.js > Tests/window.test.pack.js

.git:
	git init
	git config core.ignorecase false
	git config user.name "pinkturtle"
	git config user.email "purplespots@lostpond"
	git remote add github git@github.com:pinkturtle/facts.git
	git checkout -b principle
	git add UNLICENSE
	git commit -m "Init principle branch."
	git checkout -b draft
	git add --all
	git commit -m "Init draft branch."
	git log
