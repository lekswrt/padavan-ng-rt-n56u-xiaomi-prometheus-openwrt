#ifndef __BACKPORT_LINUX_I2C_DEV_H
#define __BACKPORT_LINUX_I2C_DEV_H
#define CONFIG_I2C         1
#define CONFIG_I2C_CHARDEV 1
#define CONFIG_I2C_MUX     1
#define CONFIG_I2C_COMPAT  1
#include_next <linux/i2c-dev.h>
#include <linux/version.h>

#endif /* __BACKPORT_LINUX_I2C_DEV_H */
