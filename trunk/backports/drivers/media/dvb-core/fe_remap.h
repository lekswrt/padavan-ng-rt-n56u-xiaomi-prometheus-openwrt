/*
 *
 * fe_remap.h: Remap frontend interface for work VLC, minisatip and etc.
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

#ifndef FE_REMAP_H
#define FE_REMAP_H

struct remap_frontend_id {
	char *name_adap_module;		/* Module name				*/
	char *name_frontend;		/* Full name frontend			*/
	int num;			/* First number frontend interface	*/
	int renum;			/* Number for remap frontend interface	*/
};

int remap_id_frontend(struct dvb_adapter *adap, void *priv, int type, int id);

#endif
