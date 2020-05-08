SRC_NAME=sqlite-32XXXXX

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
		--prefix= \
		$(if $(LIBS_BUILD_SHARED),--disable-static,--enable-static) \
		$(if $(LIBS_BUILD_SHARED),--enable-shared,--disable-shared) \
		--disable-readline \
		--disable-dynamic-extensions \
		--disable-fts3 \
		--disable-fts4 \
		--disable-fts5 \
		--disable-json1 \
		--disable-rtree \
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
ifeq ($(LIBS_BUILD_SHARED),y)
	cp -fP $(DESTDIR)/lib/libsqlite3.so* $(ROMFSDIR)/lib ;
endif

