SRC_NAME=getdns-1.6.0
#PKG_CONFIG_SYSROOT_DIR=$(STAGEDIR)


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
	./configure \
		--with-sysroot=$(STAGEDIR) \
		--prefix= \
		--with-ssl=$(STAGEDIR) \
		--with-libyaml=$(STAGEDIR) \
		--without-libidn \
		--without-libidn2 \
		--without-libunbound \
		$(if $(CONFIG_FIRMWARE_INCLUDE_OPENSSL_EC),--enable-gost,--disable-gost) \
		$(if $(CONFIG_FIRMWARE_INCLUDE_OPENSSL_EC),--enable-ecdsa,--disable-ecdsa) \
		--disable-shared \
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
#	cp -fP $(DESTDIR)/lib/libgetdns.so* $(ROMFSDIR)/lib
