VERSION:=$(shell cat VERSION)
TEST_FILES:=$(shell find test -type f)
SHA:=$(shell git rev-parse --short HEAD)

export VERSION

.PHONY: test
test:
	env -i TERM=${TERM} task/test -f tap $(TEST_FILES)

build: test
	mkdir -p build
	task/build | sed "s/VERSION=dev/VERSION=\"$(VERSION) \/ $(SHA)\"/"> build/kwm
	chmod +x build/kwm

release: ensure-clean build
	task/update-readme
	task/update-changelog
	git commit -a -m "[no-changelog] ${VERSION}"
	git push origin master
	task/create-release
	task/upload-artifact

.PHONY: ensure-clean
ensure-clean:
	@git status --porcelain | grep -v VERSION && (echo "working tree is not clean"; exit 1) || true

.PHONY: clean
clean:
	rm -rf build
