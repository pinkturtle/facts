default: facts.pack.js facts.core.js index.html

index.html: Documentation/index.*.html Documentation/core.css Documentation/index.css
	echo '<!DOCTYPE HTML><meta charset="UTF-8">' > $@
	echo '<title>Facts • playful outformation model for ECMAScript</title>' >> $@
	echo '<script src="facts.pack.js"></script>' >> $@
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

ECMAScript:
	coffee --compile Documentation/*.coffee Library/*.coffee Tests/*.coffee

facts.pack.js: facts.pack.uncompressed.js
	@rm -f $@
	@echo "// https://pinkturtle.github.io/facts version 0.0.0" >> $@
	@echo "// Includes https://facebook.github.io/immutable-js" >> $@
	@echo "// ••••••••••••••••••••••••••••••••••••••••••••••••" >> $@
	uglifyjs $< --mangle --screw-ie8 >> $@

facts.pack.uncompressed.js: ECMAScript
	browserify Library/index.js --debug --standalone Facts > $@

facts.core.js: facts.core.uncompressed.js
	@rm -f $@
	@echo "// https://pinkturtle.github.io/facts version 0.0.0" >> $@
	@echo "// Requires https://facebook.github.io/immutable-js" >> $@
	@echo "// ••••••••••••••••••••••••••••••••••••••••••••••••" >> $@
	uglifyjs $< --mangle --screw-ie8 >> $@

facts.core.uncompressed.js: ECMAScript
	browserify Library/index.js --debug --exclude immutable --standalone Facts > $@

Tests/window.test.pack.js: ECMAScript
	browserify Tests/*Tests.js --debug > $@

clean:
	rm -f facts.*.js Library/*.js Tests/*.js

.git:
	git init
	git config core.ignorecase false
	git config user.name "pinkturtle"
	git config user.email "purplespots@lostpond"
	git remote add github git@github.com:pinkturtle/facts.git

	git checkout -b principle
	git add UNLICENSE
	git commit -m "Init principle branch."
	# git push --set-upstream github principle:principle

	git checkout -b draft
	git add --all
	git commit -m "Init draft branch."
	# git push github draft:gh-pages
	git log
