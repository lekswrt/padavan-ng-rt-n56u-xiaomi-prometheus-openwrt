SRC_NAME=curl-7

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
	autoreconf -f ; \
	./configure \
		--prefix=$(STAGEDIR) \
		--enable-static \
		--enable-openssl-auto-load-config \
		--disable-shared \
		$(if $(CONFIG_IPV6),--enable-ipv6,--disable-ipv6) \
		--disable-gopher \
		--disable-ldap \
		--disable-ldaps \
		--disable-rt \
		--disable-rtsp \
		--disable-telnet \
		--disable-tftp \
		--disable-smb \
		--disable-smtp \
		--disable-pop3 \
		--disable-imap \
		--disable-sspi \
		--disable-dict \
		--disable-ares \
		--disable-debug \
		--disable-curldebug \
		--disable-manual \
		--disable-verbose \
		--disable-tls-srp \
		--disable-libcurl-option \
		--disable-threaded-resolver \
		--without-brotli \
		--without-gnutls \
		--without-ca-path \
		--without-ca-fallback \
		--without-ca-bundle \
		--without-cyassl \
		--without-darwinssl \
		--without-default-ssl-backend \
		--without-libidn2 \
		--without-libmetalink \
		--without-libpsl \
		--without-librtmp \
		--without-libssh \
		--without-libssh2 \
		--without-krb4 \
		--without-nghttp2 \
		--without-nss \
		--without-mbedtls \
		--without-mesalink \
		--without-polarssl \
		--without-schannel \
		--without-wolfssl \
		--without-winidn \
		--without-winssl \
		--without-zsh-functions-dir \
		--with-random=/dev/urandom \
		--with-zlib=$(STAGEDIR) \
		--with-ssl=$(STAGEDIR) \
		--host=$(HOST_TARGET) \
		--build=$(HOST_BUILD) ; \
	)

clean:
	if [ -f $(SRC_NAME)/Makefile ] ; then \
		$(MAKE) -C $(SRC_NAME) distclean ; \
	fi ; \
	rm -f config_done

install:
	$(MAKE) -C $(SRC_NAME) install DESTDIR=""

romfs:

