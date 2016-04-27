Facts: Facts.js Facts.pack.js

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
