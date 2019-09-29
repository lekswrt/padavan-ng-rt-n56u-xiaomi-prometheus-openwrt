/*
 *
 * fe_remap.c: Remap frontend interface for work VLC, minisatip and etc.
 *
 * Copyright (C) 2016 McMCC
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public License
 * as published by the Free Software Foundation; either version 2.1
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
 */

#include "dvb_frontend.h"
#include "fe_remap.h"

static struct remap_frontend_id remap_frontend_id_list[] = {
	{ "dvb_usb_rtl28xxu", "Realtek RTL2832 (DVB-T)", 0, 1 },
	{ "dvb_usb_rtl28xxu", "Panasonic MN88472",       1, 0 },
	{ "dvb_usb_rtl28xxu", "Panasonic MN88473",       1, 0 },
	{ "dvb_usb_rtl28xxu", "Sony CXD2837ER DVB-T/T2/C demodulator",  1, 0 },
	{ NULL, NULL,                                   -1, -1},
};

static int search_frontend(const char *name_adap_module, char *name_frontend, int id)
{
	int i = 0;

	for (;;) {
		if (remap_frontend_id_list[i].num == -1)
			break;
		if (!strncmp(remap_frontend_id_list[i].name_adap_module, name_adap_module,
						strlen(remap_frontend_id_list[i].name_adap_module))
		    && !strncmp(remap_frontend_id_list[i].name_frontend, name_frontend,
						strlen(remap_frontend_id_list[i].name_frontend))
		    && id == remap_frontend_id_list[i].num )
			return remap_frontend_id_list[i].renum;
		i++;
	}
	return -1;
}

int remap_id_frontend(struct dvb_adapter *adap, void *priv, int type, int id)
{
	int remap, num = id;

	if (type == DVB_DEVICE_FRONTEND) {
		struct dvb_frontend *fe = (struct dvb_frontend *)priv;
		if (fe) {
			char *name_frontend = fe->ops.info.name;
			if((remap = search_frontend(adap->module->name, name_frontend, fe->id)) >= 0)
			{
				printk(KERN_INFO "%s: Adapter%d '%s' frontend%d '%s' rename as frontend%d\n",
					adap->module->name, adap->num, adap->name, fe->id, name_frontend, remap);
				num = remap;
			}
		}
	}
	return num;
}
/* EXPORT_SYMBOL(remap_id_frontend); */
