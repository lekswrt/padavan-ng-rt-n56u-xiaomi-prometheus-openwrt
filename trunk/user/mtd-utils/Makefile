SRC_NAME=mtd-utils-2.1.x

CFLAGS+=$(COPT) -ffunction-sections -fdata-sections -fvisibility=hidden
LDFLAGS += -Wl,--gc-sections

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
	./configure \
		--prefix= \
		--enable-static \
		--disable-shared \
		--disable-tests \
		--without-jffs \
		--without-xattr \
		--without-ubifs \
		--without-lzo \
		--host=$(HOST_TARGET) \
		--build=$(HOST_BUILD) ; \
	)

clean:
	if [ -f $(SRC_NAME)/Makefile ] ; then \
		$(MAKE) -C $(SRC_NAME) distclean; \
	fi ; \
	rm -f config_done

romfs:
	$(ROMFSINST) $(SRC_NAME)/ubiattach /sbin/ubiattach
	$(ROMFSINST) $(SRC_NAME)/ubidetach /sbin/ubidetach
	$(ROMFSINST) $(SRC_NAME)/ubiformat /sbin/ubiformat
	$(ROMFSINST) $(SRC_NAME)/ubimkvol /sbin/ubimkvol
	$(ROMFSINST) $(SRC_NAME)/ubinfo /sbin/ubinfo
