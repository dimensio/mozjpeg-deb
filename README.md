# mozjpeg-deb

Selectively compile and package mozjpeg 3.0
for use as the system-wide shared JPEG library on
Ubuntu 14.04, 14.10 and 15.04
instead of libjpeg-turbo.

As mozjpeg is ABI-compatible with libjpeg-turbo,
only the shared library files are included.
The existing `cjpeg`, `djpeg` etc. binaries remain
but will take advantage of the updated shared library files.
Use of the `/usr/local` path prevents other existing files being trampled.

## How to

```sh
bundle install
make
```

This will:

1. Download [mozjpeg source](https://github.com/mozilla/mozjpeg/releases).
2. Compile only the required jpeg8 shared library from source.
3. Package shared library _mozjpeg_ and header files _mozjpeg-dev_ in `.deb` format.

## See also

The mozjpeg `Makefile` inherited from libjpeg-turbo contains a `deb` rule
to compile and bundle everything into a single `.deb` file,
which will suffice for some needs.
