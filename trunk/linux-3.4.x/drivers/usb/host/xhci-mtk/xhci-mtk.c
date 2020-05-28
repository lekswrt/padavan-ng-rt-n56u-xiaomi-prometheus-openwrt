#include <linux/kernel.h>       /* printk() */
#include <linux/slab.h>
#include <linux/delay.h>
#include <asm/uaccess.h>
#include <linux/dma-mapping.h>
#include <linux/platform_device.h>

#include "../xhci.h"
#include "xhci-mtk.h"
#include "xhci-mtk-scheduler.h"

void mtk_xhci_init_reg(void)
{
	__u32 __iomem *addr;
	u32 temp;

	/* set SSUSB DMA burst size to 128B */
	addr = (__u32 __iomem *)(SSUSB_U3_XHCI_BASE + SSUSB_HDMA_CFG);
	temp = SSUSB_HDMA_CFG_MT7621_VALUE;
	writel(temp, addr);

	/* extend U3 LTSSM Polling.LFPS timeout value */
	addr = (__u32 __iomem *)(SSUSB_U3_XHCI_BASE + U3_LTSSM_TIMING_PARAMETER3);
	temp = U3_LTSSM_TIMING_PARAMETER3_VALUE;
	writel(temp, addr);

	/* EOF */
	addr = (__u32 __iomem *)(SSUSB_U3_XHCI_BASE + SYNC_HS_EOF);
	temp = SYNC_HS_EOF_VALUE;
	writel(temp, addr);

#if defined (CONFIG_PERIODIC_ENP)
	/* HSCH_CFG1: SCH2_FIFO_DEPTH */
	addr = (__u32 __iomem *)(SSUSB_U3_XHCI_BASE + HSCH_CFG1);
	temp = readl(addr);
	temp &= ~(0x3 << SCH2_FIFO_DEPTH_OFFSET);
	writel(temp, addr);
#endif

	/* Doorbell handling */
	addr = (__u32 __iomem *)(SIFSLV_IPPC + SSUSB_IP_SPAR0);
	temp = 0x1;
	writel(temp, addr);

	/* Set SW PLL Stable mode to 1 for U2 LPM device remote wakeup */
	/* Port 0 */
	addr = (__u32 __iomem *)(U2_PHY_P0_BASE + U2_PHYD_CR1);
	temp = readl(addr);
	temp &= ~(0x3 << 18);
	temp |= (1 << 18);
	writel(temp, addr);

	/* Port 1 */
	addr = (__u32 __iomem *)(U2_PHY_P1_BASE + U2_PHYD_CR1);
	temp = readl(addr);
	temp &= ~(0x3 << 18);
	temp |= (1 << 18);
	writel(temp, addr);
}

void mtk_xhci_enable_ports_power(struct xhci_hcd *xhci)
{
	int i;
	u32 port_id, num_u3_port, num_u2_port, temp;
	__le32 __iomem addr;

	num_u3_port = SSUSB_U3_PORT_NUM(readl((const volatile void __iomem *)SSUSB_IP_CAP));
	num_u2_port = SSUSB_U2_PORT_NUM(readl((const volatile void __iomem *)SSUSB_IP_CAP));

	for (i = 1; i <= num_u3_port; i++) {
		port_id = i;
		addr =  (__le32 __iomem)(&xhci->op_regs->port_status_base);
		addr += NUM_PORT_REGS * ((port_id - 1) & 0xff) * sizeof(__le32);
		temp = xhci_readl(xhci, (__le32 __iomem *)addr);
		temp = xhci_port_state_to_neutral(temp);
		temp |= PORT_POWER;
		xhci_writel(xhci, temp, (__le32 __iomem *)addr);
	}

	for (i = 1; i <= num_u2_port; i++) {
		port_id = i + num_u3_port;
		addr =  (__le32 __iomem)(&xhci->op_regs->port_status_base);
		addr += NUM_PORT_REGS * ((port_id - 1) & 0xff) * sizeof(__le32);
		temp = xhci_readl(xhci, (__le32 __iomem *)addr);
		temp = xhci_port_state_to_neutral(temp);
		temp |= PORT_POWER;
		xhci_writel(xhci, temp, (__le32 __iomem *)addr);
	}
}

