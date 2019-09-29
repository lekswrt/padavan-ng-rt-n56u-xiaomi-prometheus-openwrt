#ifndef __BACKPORT_LINUX_CLK_PROVIDER_H
#define __BACKPORT_LINUX_CLK_PROVIDER_H
#define CONFIG_COMMON_CLK       1
#define CONFIG_HAVE_CLK         1
#define CONFIG_CLKDEV_LOOKUP    1
#define CONFIG_HAVE_CLK_PREPARE 1
#include_next <linux/clk-provider.h>
#include <linux/version.h>

#endif /* __LINUX_CLK_PROVIDER_H */
