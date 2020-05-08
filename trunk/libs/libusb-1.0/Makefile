SRC_NAME=libusb-1.0.X

all: config_test
	$(MAKE) -j$(HOST_NCPU) -C $(SRC_NAME)

config_test:
	( if [ -f ./config_done ]; then \
		echo "the same configuration"; \
	else \
		make configure && touch config_done; \
	fi )

configure:
	( cd $(SRC_NAME) ; \
	autoreconf ; \
	ac_cv_lib_rt_clock_gettime=no \
	./configure \
		--prefix= \
		--disable-static \
		--disable-log \
		--disable-udev \
		--disable-timerfd \
		--disable-examples-build \
		--disable-tests-build \
		--host=$(HOST_TARGET) \
		--build=$(HOST_BUILD) ; \
	)

clean:
	if [ -f $(SRC_NAME)/Makefile ] ; then \
		$(MAKE) -C $(SRC_NAME) distclean ; \
	fi ; \
	rm -f config_done

install:
	$(MAKE) -C $(SRC_NAME) install DESTDIR=$(STAGEDIR)

romfs:
	cp -fP $(DESTDIR)/lib/libusb-1.0.so* $(ROMFSDIR)/lib

