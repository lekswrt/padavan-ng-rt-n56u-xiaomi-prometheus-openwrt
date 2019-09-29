#ifndef __BACKPORT_LINUX_I2C_MUX_H
#define __BACKPORT_LINUX_I2C_MUX_H
#define CONFIG_I2C         1
#define CONFIG_I2C_CHARDEV 1
#define CONFIG_I2C_MUX     1
#define CONFIG_I2C_COMPAT  1
#include_next <linux/i2c-mux.h>
#include <linux/version.h>

#if 0 /* */
#if (LINUX_VERSION_CODE < KERNEL_VERSION(3,5,0))
#define i2c_add_mux_adapter(parent, mux_dev, mux_priv, force_nr, chan_id, class, select, deselect) \
	i2c_add_mux_adapter(parent, mux_priv, force_nr, chan_id, select, deselect)
#elif (LINUX_VERSION_CODE < KERNEL_VERSION(3,7,0))
#define i2c_add_mux_adapter(parent, mux_dev, mux_priv, force_nr, chan_id, class, select, deselect) \
	i2c_add_mux_adapter(parent, mux_dev, mux_priv, force_nr, chan_id, select, deselect)
#endif
#endif /* */

#endif /* __BACKPORT_LINUX_I2C_MUX_H */
