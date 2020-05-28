#ifndef _XHCI_MTK_H
#define _XHCI_MTK_H

#include <linux/usb.h>
#include "../xhci.h"

#include <asm/rt2880/rt_mmap.h>

#define SSUSB_U3_XHCI_BASE		RALINK_XHCI_HOST_BASE
#define SSUSB_U3_MAC_BASE		(SSUSB_U3_XHCI_BASE + 0x2400)
#define SSUSB_U3_SYS_BASE		(SSUSB_U3_XHCI_BASE + 0x2600)
#define SSUSB_U2_SYS_BASE		(SSUSB_U3_XHCI_BASE + 0x3400)
#define SSUSB_SIFSLV_TOP		RALINK_XHCI_UPHY_BASE

#define SIFSLV_IPPC			(SSUSB_SIFSLV_TOP + 0x0700)
#define U2_PHY_P0_BASE			(SSUSB_SIFSLV_TOP + 0x0800)
#define U2_PHY_P1_BASE			(SSUSB_SIFSLV_TOP + 0x1000)

#define U3_PIPE_LATCH_SEL_ADD		(SSUSB_U3_MAC_BASE + 0x130)
#define U3_PIPE_LATCH_TX		0
#define U3_PIPE_LATCH_RX		0

#define U3_UX_EXIT_LFPS_TIMING_PAR	0xa0
#define U3_REF_CK_PAR			0xb0
#define U3_RX_UX_EXIT_LFPS_REF_OFFSET	8
#define U3_RX_UX_EXIT_LFPS_REF		3
#define U3_REF_CK_VAL			10

#define U3_TIMING_PULSE_CTRL		0xb4
#define CNT_1US_VALUE			63 //62.5MHz:63, 70MHz:70, 80MHz:80, 100MHz:100, 125MHz:125

#define USB20_TIMING_PARAMETER		0x40
#define TIME_VALUE_1US			63 //62.5MHz:63, 80MHz:80, 100MHz:100, 125MHz:125

#define LINK_PM_TIMER			0x8
#define PM_LC_TIMEOUT_VALUE		3

#define XHCI_IMOD			0x624
#define XHCI_IMOD_MT7621_VALUE		0x10

#define SSUSB_HDMA_CFG			0x950
#define SSUSB_HDMA_CFG_MT7621_VALUE	0x10E0E0C

#define U3_LTSSM_TIMING_PARAMETER3		0x2514
#define U3_LTSSM_TIMING_PARAMETER3_VALUE	0x3E8012C

#define U2_PHYD_CR1			0x64

#define SSUSB_IP_SPAR0			0xC8

#define SYNC_HS_EOF			0x938
#define SYNC_HS_EOF_VALUE		0x201F3

#define HSCH_CFG1			0x960
#define SCH2_FIFO_DEPTH_OFFSET		16

#define SSUSB_IP_CAP			(SIFSLV_IPPC + 0x024)
#define SSUSB_U3_PORT_NUM(p)		(p & 0xff)
#define SSUSB_U2_PORT_NUM(p)		((p >> 8) & 0xff)

void mtk_xhci_init_reg(void);
void mtk_xhci_enable_ports_power(struct xhci_hcd *xhci);

#endif
