all :
	./node_modules/.bin/coffee \
		--compile \
		--lint \
		--output lib src

test :
	./node_modules/.bin/mocha \
	 -t 20000 \
	 --reporter list \
	 --compilers coffee:coffee-script \
	 --recursive \
	 spec/


# ---

tag:
	git tag v`coffee -e "console.log JSON.parse(require('fs').readFileSync 'package.json').version"`

