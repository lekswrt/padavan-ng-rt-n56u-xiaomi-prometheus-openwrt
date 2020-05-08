SRC_NAME=util-linux-2.3X.X

THISDIR = $(shell pwd)

CFLAGS += -ffunction-sections -fdata-sections
LDFLAGS += -Wl,--gc-sections

all: config_test
	$(MAKE) -j$(HOST_NCPU) -C $(SRC_NAME) && \
	$(MAKE) -C $(SRC_NAME) install DESTDIR=$(STAGEDIR)

config_test:
	( if [ -f ./config_done ]; then \
		echo "the same configuration"; \
	else \
		make configure && touch config_done; \
	fi )

configure:
	( cd $(SRC_NAME) ; \
	scanf_cv_type_modifier=no \
	./configure \
		--prefix= \
		--without-audit \
		--without-btrfs \
		--without-libz \
		--without-ncurses \
		--without-ncursesw \
		--without-python \
		--without-readline \
		--without-selinux \
		--without-slang \
		--without-smack \
		--without-systemd \
		--without-tinfo \
		--without-udev \
		--without-user \
		--without-utempter \
		--without-util \
		--disable-all-programs \
		--disable-bash-completion \
		--disable-colors-default \
		--disable-libfdisk \
		--disable-libmount \
		--disable-libsmartcols \
		--disable-makeinstall-chown \
		--disable-makeinstall-setuid \
		--disable-nls \
		--disable-plymouth_support \
		--disable-rpath \
		--disable-use-tty-group \
		--disable-widechar \
		--enable-libblkid \
		--enable-libuuid \
		--enable-blkid \
		--host=$(HOST_TARGET) \
		--build=$(HOST_BUILD) ; \
	)

clean:
	if [ -f $(SRC_NAME)/Makefile ] ; then \
		$(MAKE) -C $(SRC_NAME) distclean ; \
	fi ; \
	rm -f config_done
	rm -rf install

romfs:
	$(ROMFSINST) $(STAGEDIR)/sbin/blkid /sbin/blkid
	$(ROMFSINST) $(STAGEDIR)/lib/libblkid.so.1.1.0 /lib/libblkid.so.1.1.0
	$(ROMFSINST) $(STAGEDIR)/lib/libuuid.so.1.3.0 /lib/libuuid.so.1.3.0
	$(ROMFSINST) -s libblkid.so.1.1.0 /lib/libblkid.so
	$(ROMFSINST) -s libblkid.so.1.1.0 /lib/libblkid.so.1
	$(ROMFSINST) -s libuuid.so.1.3.0 /lib/libuuid.so
	$(ROMFSINST) -s libuuid.so.1.3.0 /lib/libuuid.so.1
