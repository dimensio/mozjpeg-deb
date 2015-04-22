VERSION=3.0
TEMP=/tmp/mozjpeg
ARCH=$(shell dpkg --print-architecture)

# metadata
VENDOR=Mozilla Research
LICENSE=https://github.com/mozilla/mozjpeg/blob/master/LICENSE.txt
URL=https://github.com/mozilla/mozjpeg
DESC=A JPEG codec that provides increased compression for JPEG images (at the expense of compression performance)

all: clean prepare fetch-release compile package

git: clean prepare fetch-git compile package

.PHONY: clean prepare fetch-git fetch-release compile package

clean:
	rm -f *.deb
	rm -rf mozjpeg/
	rm -rf $(TEMP)

prepare:
	mkdir $(TEMP) || true

fetch-git:
	git clone https://github.com/mozilla/mozjpeg.git

fetch-release:
	curl -L -O -z mozjpeg-${VERSION}-release-source.tar.gz https://github.com/mozilla/mozjpeg/releases/download/v${VERSION}/mozjpeg-${VERSION}-release-source.tar.gz
	tar zxf mozjpeg-${VERSION}-release-source.tar.gz

compile:
	cd mozjpeg && autoreconf -fiv
	cd mozjpeg && ./configure \
		--prefix=/usr/local \
		--disable-static \
		--with-jpeg8 \
		--without-turbojpeg
	cd mozjpeg && $(MAKE) install DESTDIR=$(TEMP)

package:
	bundle install
	fpm -s dir \
			-t deb \
			-C $(TEMP) \
			--force \
			--name mozjpeg \
			--version $(VERSION) \
			--vendor "$(VENDOR)" \
			--maintainer "$(VENDOR)" \
			--license "$(LICENSE)" \
			--url "$(URL)" \
			--description "$(DESC)" \
			--package "mozjpeg-$(VERSION)_$(ARCH).deb" \
			--depends "libc6 >= 2.19" \
			--deb-shlibs "mozjpeg 8 libjpeg (= $(VERSION))" \
			--deb-compression xz \
			usr/local/lib
	fpm -s dir \
			-t deb \
			-C $(TEMP) \
			--force \
			--name mozjpeg-dev \
			--version $(VERSION) \
			--vendor "$(VENDOR)" \
			--maintainer "$(VENDOR)" \
			--license "$(LICENSE)" \
			--url "$(URL)" \
			--description "$(DESC)" \
			--package "mozjpeg-dev-$(VERSION)_$(ARCH).deb" \
			--depends "mozjpeg = $(VERSION)" \
			--deb-compression xz \
			usr/local/include
