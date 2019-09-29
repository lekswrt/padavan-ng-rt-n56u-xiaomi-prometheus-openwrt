#ifndef __BACKPORT_LINUX_FIRMWARE_H
#define __BACKPORT_LINUX_FIRMWARE_H
#define CONFIG_FW_LOADER 1
#include_next <linux/firmware.h>

#if LINUX_VERSION_CODE < KERNEL_VERSION(3,14,0)
#if defined(CONFIG_FW_LOADER) || (defined(CONFIG_FW_LOADER_MODULE) && defined(MODULE))
int request_firmware_direct(const struct firmware **fw, const char *name,
		      struct device *device);

#else
static inline int request_firmware_direct(const struct firmware **fw,
		      const char *name,
		      struct device *device)
{
	return -EINVAL;
}
#endif
#endif

#endif /* __BACKPORT_LINUX_FIRMWARE_H */
