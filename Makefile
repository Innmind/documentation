# This command is intended to be run on your computer
serve:
	docker build -t squidfunk/mkdocs-material .
	docker run --rm -it -p 8000:8000 -v ${PWD}:/docs squidfunk/mkdocs-material

build:
	docker build -t squidfunk/mkdocs-material .
	docker run --rm -it -v ${PWD}:/docs squidfunk/mkdocs-material build
