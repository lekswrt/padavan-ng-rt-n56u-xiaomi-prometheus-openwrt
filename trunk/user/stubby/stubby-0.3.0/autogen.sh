#!/bin/sh
if [ -x "`which autoreconf 2>/dev/null`" ] ; then
   exec autoreconf -ivf
fi

libtoolize --copy && \
aclocal -I m4 && \
autoheader && \
automake --add-missing --force-missing --include-deps --copy && \
autoconf -I m4
