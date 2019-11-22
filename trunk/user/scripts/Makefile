include $(ROOTDIR)/user/shared/board.mk

all:

clean:

romfs:
	./makedevlinks $(ROMFSDIR)
	$(ROMFSINST) /sbin/dev_init.sh
	$(ROMFSINST) /sbin/reset_ss.sh
	$(ROMFSINST) /sbin/mtd_storage.sh
ifeq ($(STORAGE_ENABLED),y)
	$(ROMFSINST) /sbin/automount.sh
endif
ifdef CONFIG_BLK_DEV_SD
	$(ROMFSINST) /sbin/hddtune.sh
	$(ROMFSINST) /sbin/spindown.sh
endif
	# FIXME:
ifneq (,$(filter -DBOARD_ARCHER_MR200,$(CFLAGS)))
	echo "\nadb wait-for-device\nadb shell chmod +x /WEBSERVER/www/cgi-bin/*\nadb shell httpd -h /WEBSERVER/www/" >> $(INSTALLDIR)/sbin/dev_init.sh ;\
	echo "echo \"2357 000d\" > /sys/bus/usb-serial/drivers/option1/new_id\nsleep 2\nadb kill-server\n" >> $(INSTALLDIR)/sbin/dev_init.sh
endif
	$(ROMFSINST) /etc_ro/protocols
	$(ROMFSINST) /etc_ro/services
	$(ROMFSINST) /etc_ro/profile
	$(ROMFSINST) /etc_ro/shells
	$(ROMFSINST) /etc_ro/mdev.conf
	mkdir -p $(INSTALLDIR)/usr/share/terminfo
	tar -xzf ./terminfo.tar.gz -C $(INSTALLDIR)/usr/share
