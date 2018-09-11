VERSION?=3.1
VERSION_ALTERNATE?=-1~fasterize
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
	rm -rf mozjpeg-${VERSION}/
	rm -rf $(TEMP)

prepare:
	mkdir $(TEMP) || true

fetch-git:
	git clone https://github.com/mozilla/mozjpeg.git

fetch-release:
	curl -L -z mozjpeg-${VERSION}-release-source.tar.gz -o mozjpeg-${VERSION}-release-source.tar.gz https://github.com/mozilla/mozjpeg/archive/v${VERSION}.tar.gz
	tar zxf mozjpeg-${VERSION}-release-source.tar.gz

compile:
	cd mozjpeg-${VERSION} && autoreconf -fiv
	cd mozjpeg-${VERSION} && ./configure \
		--prefix=/usr/local \
		--with-jpeg8 \
		--without-turbojpeg
	cd mozjpeg-${VERSION} && $(MAKE) install DESTDIR=$(TEMP)

package:
	bundle install
	bundle exec fpm -s dir \
			-t deb \
			-C $(TEMP) \
			--force \
			--name mozjpeg \
			--version $(VERSION)$(VERSION_ALTERNATE) \
			--vendor "$(VENDOR)" \
			--maintainer "$(VENDOR)" \
			--license "$(LICENSE)" \
			--url "$(URL)" \
			--description "$(DESC)" \
			--package "mozjpeg-$(VERSION)$(VERSION_ALTERNATE)_$(ARCH).deb" \
			--depends "libc6 >= 2.19" \
			--deb-shlibs "libjpeg 8 mozjpeg (= $(VERSION)$(VERSION_ALTERNATE))" \
			--deb-compression xz \
			--deb-no-default-config-files \
			usr/local/lib
	bundle exec fpm -s dir \
			-t deb \
			-C $(TEMP) \
			--force \
			--name mozjpeg-dev \
			--version $(VERSION)$(VERSION_ALTERNATE) \
			--vendor "$(VENDOR)" \
			--maintainer "$(VENDOR)" \
			--license "$(LICENSE)" \
			--url "$(URL)" \
			--description "$(DESC)" \
			--package "mozjpeg-dev-$(VERSION)$(VERSION_ALTERNATE)_$(ARCH).deb" \
			--depends "mozjpeg = $(VERSION)$(VERSION_ALTERNATE)" \
			--deb-compression xz \
			--deb-no-default-config-files \
			usr/local/include
