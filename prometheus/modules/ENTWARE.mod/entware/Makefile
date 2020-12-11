THISDIR = $(shell pwd)

romfs:
	mkdir -p $(INSTALLDIR)/usr/opt
	# cp -af $(THISDIR)/opt/* $(INSTALLDIR)/usr/opt
	tar -zxvf $(THISDIR)/entware.tar.gz -C $(INSTALLDIR)/usr/opt
	chmod 755 -R $(INSTALLDIR)/usr/opt
	mkdir -p $(INSTALLDIR)/usr/bin
	$(ROMFSINST) -p +x /usr/bin/entware_start.sh
	$(ROMFSINST) -p +x /usr/bin/entware_stop.sh
	
