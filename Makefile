all: index.html

index.html:
	node_modules/.bin/elm make --output index.html src/Main.elm

clean:
	rm -f index.html

