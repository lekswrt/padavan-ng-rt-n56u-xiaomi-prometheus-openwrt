SRC_NAME=libpcap-1.X.X

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
	ac_cv_netfilter_can_compile=no \
	./configure \
		--prefix= \
		--disable-shared \
		$(if $(CONFIG_IPV6),--enable-ipv6,--disable-ipv6) \
		--disable-yydebug \
		--disable-usb \
		--disable-dbus \
		--disable-bluetooth \
		--disable-netmap \
		--disable-rdma \
		--with-pcap=linux \
		--without-dag \
		--without-septel \
		--without-libnl \
		--without-snf \
		--host=$(HOST_TARGET) \
		--build=$(HOST_BUILD) ; \
	)

clean:
	if [ -f $(SRC_NAME)/Makefile ] ; then \
		$(MAKE) -C $(SRC_NAME) distclean ; \
	fi ; \
	rm -f config_done

install:
	$(MAKE) -C $(SRC_NAME) install DESTDIR=$(STAGEDIR) ;
	rm -f $(DESTDIR)/lib/libpcap.so* ;

romfs:

