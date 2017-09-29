GO ?= go
DIST_DIRS := find * -type d -exec
VERSION ?= $(shell git describe --tags)
VERSION_INCODE = $(shell perl -ne '/^var version.*"([^"]+)".*$$/ && print "v$$1\n"' glide.go)
VERSION_INCHANGELOG = $(shell perl -ne '/^\# Release (\d+(\.\d+)+) / && print "$$1\n"' CHANGELOG.md | head -n1)

build:
	${GO} build -o goconfigure -ldflags "-X main.version=${VERSION}"

install: build
	install -d ${DESTDIR}/usr/local/bin/
	install -m 755 ./goconfigure ${DESTDIR}/usr/local/bin/goconfigure

test:
	${GO} test . ./gb ./path ./action ./tree ./util ./godep ./godep/strip ./gpm ./cfg ./dependency ./importer ./msg ./repo ./mirrors

integration-test:
	${GO} build
	./glide up
	./glide install

clean:
	rm -f ./glide.test
	rm -f ./glide
	rm -rf ./dist

bootstrap-dist:
	${GO} get -u github.com/Masterminds/gox
	${GO} get -u github.com/Masterminds/glide
	glide install

build-all:
	gox -verbose \
	-ldflags "-X main.version=${VERSION}" \
	-os="linux darwin windows freebsd openbsd netbsd" \
	-arch="amd64 386 armv5 armv6 armv7 arm64 s390x" \
	-osarch="!darwin/arm64" \
	-output="dist/{{.OS}}-{{.Arch}}/{{.Dir}}" .

dist: build-all
	cd dist && \
	$(DIST_DIRS) cp ../LICENSE {} \; && \
	$(DIST_DIRS) cp ../README.md {} \; && \
	$(DIST_DIRS) tar -zcf goconfigure-${VERSION}-{}.tar.gz {} \; && \
	$(DIST_DIRS) zip -r goconfigure-${VERSION}-{}.zip {} \; && \
	cd ..

verify-version:
	@if [ "$(VERSION_INCODE)" = "v$(VERSION_INCHANGELOG)" ]; then \
		echo "glide: $(VERSION_INCHANGELOG)"; \
	elif [ "$(VERSION_INCODE)" = "v$(VERSION_INCHANGELOG)-dev" ]; then \
		echo "glide (development): $(VERSION_INCHANGELOG)"; \
	else \
		echo "Version number in glide.go does not match CHANGELOG.md"; \
		echo "glide.go: $(VERSION_INCODE)"; \
		echo "CHANGELOG : $(VERSION_INCHANGELOG)"; \
		exit 1; \
	fi

.PHONY: build test install clean bootstrap-dist build-all dist integration-test verify-version