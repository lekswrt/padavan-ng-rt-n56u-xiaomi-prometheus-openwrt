/*

*/

#include "rt_config.h"


/*
	IEEE 802.11AC D2.0 sec 22.3.14
	Channelization, Table 22-21

	A VHT channel is specified by the four PLME MIB fields
	(Fields to specify VHT channels).

	dot11CurrentChannelBandwidth:
		Channel bandwidth. Possible values are 
			cbw20, cbw40, cbw80, cbw160 and cbw80p80.
	dot11CurrentChannelCenterFrequencyIndex1:
		In 20 MHz, 40 MHz, 80 MHz and 160 MHz channels, denotes the channel
			center frequency.
		In 80+80 MHz channels, denotes the center frequency of the frequency 
			segment 1, which is the frequency segment containing the primary
			channel..
		Valid range = 1, ¡K, 200.
	dot11CurrentChannelCenterFrequencyIndex2:
		In 80+80 MHz channels, denotes the center frequency of the frequency
			segment 2, which is the frequency segment that does not contain the
			primary channel.
			Valid range = 1, ¡K, 200.
		Undefined for 20 MHz, 40 MHz, 80 MHz and 160 MHz channels.
	dot11CurrentPrimaryChannel:
		Denotes the location of the primary 20 MHz channel.
		Valid range = 1, ¡K, 200.


	Formula:
	 A channel center frequency of 5.000 GHz shall be indicated by 
	 	dot11ChannelStartingFactor = 8000, and
		dot11CurrentPrimaryChannel = 200.

	 Channel starting frequency
	 	= dot11ChannelStartingFactor ¡Ñ 0500 kHz.
	 
	Channel center frequency [MHz]
		= Channel starting frequency + 5 * dot11CurrentChannelCenterFrequencyIndex

	Primary 20 MHz channel center frequency [MHz]
		= Channel starting frequency + 5 * dot11CurrentPrimaryChannel

	ex:  a channel specified by:
		dot11CurrentChannelBandwidth = 80 MHz
		dot11CurrentChannelCenterFrequencyIndex1 = 42
		dot11CurrentPrimaryChannel = 36
		
		=>is an 80 MHz channel with a center frequency of 5210 MHz and 
			the primary 20 MHz channel centered at 5180 MHz.

*/
struct vht_ch_layout{
	UCHAR ch_low_bnd;
	UCHAR ch_up_bnd;
	UCHAR cent_freq_idx;
};

static struct vht_ch_layout vht_ch_80M[]={
	{36, 48, 42},
	{52, 64, 58},
	{100,112, 106},
	{116, 128, 122},
	{132, 144, 138},
	{149, 161, 155},
	{0, 0 ,0},
};




VOID dump_vht_cap(RTMP_ADAPTER *pAd, VHT_CAP_IE *vht_ie)
{
#ifdef DBG
	VHT_CAP_INFO *vht_cap = &vht_ie->vht_cap;
	VHT_MCS_SET *vht_mcs = &vht_ie->mcs_set;

	DBGPRINT(RT_DEBUG_OFF, ("Dump VHT_CAP IE\n"));	
	hex_dump("VHT CAP IE Raw Data", (UCHAR *)vht_ie, sizeof(VHT_CAP_IE));

	DBGPRINT(RT_DEBUG_OFF, ("VHT Capabilities Info Field\n"));
	DBGPRINT(RT_DEBUG_OFF, ("\tMaximum MPDU Length=%d\n", vht_cap->max_mpdu_len));
	DBGPRINT(RT_DEBUG_OFF, ("\tSupported Channel Width=%d\n", vht_cap->ch_width));
	DBGPRINT(RT_DEBUG_OFF, ("\tRxLDPC=%d\n", vht_cap->rx_ldpc));
	DBGPRINT(RT_DEBUG_OFF, ("\tShortGI_80M=%d\n", vht_cap->sgi_80M));
	DBGPRINT(RT_DEBUG_OFF, ("\tShortGI_160M=%d\n", vht_cap->sgi_160M));
	DBGPRINT(RT_DEBUG_OFF, ("\tTxSTBC=%d\n", vht_cap->tx_stbc));
	DBGPRINT(RT_DEBUG_OFF, ("\tRxSTBC=%d\n", vht_cap->rx_stbc));
	DBGPRINT(RT_DEBUG_OFF, ("\tSU BeamformerCap=%d\n", vht_cap->bfer_cap_su));
	DBGPRINT(RT_DEBUG_OFF, ("\tSU BeamformeeCap=%d\n", vht_cap->bfee_cap_su));
	DBGPRINT(RT_DEBUG_OFF, ("\tCompressedSteeringNumOfBeamformerAnt=%d\n", vht_cap->cmp_st_num_bfer));
	DBGPRINT(RT_DEBUG_OFF, ("\tNumber of Sounding Dimensions=%d\n", vht_cap->num_snd_dimension));	
	DBGPRINT(RT_DEBUG_OFF, ("\tMU BeamformerCap=%d\n", vht_cap->bfer_cap_mu));
	DBGPRINT(RT_DEBUG_OFF, ("\tMU BeamformeeCap=%d\n", vht_cap->bfee_cap_mu));
	DBGPRINT(RT_DEBUG_OFF, ("\tVHT TXOP PS=%d\n", vht_cap->vht_txop_ps));
	DBGPRINT(RT_DEBUG_OFF, ("\t+HTC-VHT Capable=%d\n", vht_cap->htc_vht_cap));
	DBGPRINT(RT_DEBUG_OFF, ("\tMaximum A-MPDU Length Exponent=%d\n", vht_cap->max_ampdu_exp));
	DBGPRINT(RT_DEBUG_OFF, ("\tVHT LinkAdaptation Capable=%d\n", vht_cap->vht_link_adapt));

	DBGPRINT(RT_DEBUG_OFF, ("VHT Supported MCS Set Field\n"));
	DBGPRINT(RT_DEBUG_OFF, ("\tRx Highest SupDataRate=%d\n", vht_mcs->rx_high_rate));
	DBGPRINT(RT_DEBUG_OFF, ("\tRxMCS Map_1SS=%d\n", vht_mcs->rx_mcs_map.mcs_ss1));
	DBGPRINT(RT_DEBUG_OFF, ("\tRxMCS Map_2SS=%d\n", vht_mcs->rx_mcs_map.mcs_ss2));
	DBGPRINT(RT_DEBUG_OFF, ("\tTx Highest SupDataRate=%d\n", vht_mcs->tx_high_rate));
	DBGPRINT(RT_DEBUG_OFF, ("\tTxMCS Map_1SS=%d\n", vht_mcs->tx_mcs_map.mcs_ss1));
	DBGPRINT(RT_DEBUG_OFF, ("\tTxMCS Map_2SS=%d\n", vht_mcs->tx_mcs_map.mcs_ss2));
#endif
}


VOID dump_vht_op(RTMP_ADAPTER *pAd, VHT_OP_IE *vht_ie)
{
#ifdef DBG
	VHT_OP_INFO *vht_op = &vht_ie->vht_op_info;
	VHT_MCS_MAP *vht_mcs = &vht_ie->basic_mcs_set;
	
	DBGPRINT(RT_DEBUG_OFF, ("Dump VHT_OP IE\n"));	
	hex_dump("VHT OP IE Raw Data", (UCHAR *)vht_ie, sizeof(VHT_OP_IE));

	DBGPRINT(RT_DEBUG_OFF, ("VHT Operation Info Field\n"));
	DBGPRINT(RT_DEBUG_OFF, ("\tChannelWidth=%d\n", vht_op->ch_width));
	DBGPRINT(RT_DEBUG_OFF, ("\tChannelCenterFrequency Seg 1=%d\n", vht_op->center_freq_1));
	DBGPRINT(RT_DEBUG_OFF, ("\tChannelCenterFrequency Seg 1=%d\n", vht_op->center_freq_2));

	DBGPRINT(RT_DEBUG_OFF, ("VHT Basic MCS Set Field\n"));
	DBGPRINT(RT_DEBUG_OFF, ("\tRxMCS Map_1SS=%d\n", vht_mcs->mcs_ss1));
	DBGPRINT(RT_DEBUG_OFF, ("\tRxMCS Map_2SS=%d\n", vht_mcs->mcs_ss2));
#endif
}


/*
	Get BBP Channel Index by RF channel info
	return value: 0~3
*/
UCHAR vht_prim_ch_idx(UCHAR vht_cent_ch, UCHAR prim_ch)
{
	INT idx = 0;
	UCHAR bbp_idx = 0;

	if (vht_cent_ch == prim_ch)
		goto done;

	while (vht_ch_80M[idx].ch_up_bnd != 0)
	{
		if (vht_cent_ch == vht_ch_80M[idx].cent_freq_idx)
		{
			if (prim_ch == vht_ch_80M[idx].ch_up_bnd)
				bbp_idx = 3;
			else if (prim_ch == vht_ch_80M[idx].ch_low_bnd)
				bbp_idx = 0;
			else {
				bbp_idx = prim_ch > vht_cent_ch ? 2 : 1;
			}
			break;
		}
		idx++;
	}

done:
	DBGPRINT(RT_DEBUG_TRACE, ("%s():(VhtCentCh=%d, PrimCh=%d) =>BbpChIdx=%d\n",
				__FUNCTION__, vht_cent_ch, prim_ch, bbp_idx));
	return bbp_idx;
}


/*
	Currently we only consider about VHT 80MHz!
*/
UCHAR vht_cent_ch_freq(RTMP_ADAPTER *pAd, UCHAR prim_ch)
{
	INT idx = 0;

	if (pAd->CommonCfg.vht_bw < VHT_BW_80 || prim_ch < 36)
	{
		//pAd->CommonCfg.vht_cent_ch = 0;
		//pAd->CommonCfg.vht_cent_ch2 = 0;
		return prim_ch;
	}

	while (vht_ch_80M[idx].ch_up_bnd != 0)
	{
		if (prim_ch >= vht_ch_80M[idx].ch_low_bnd &&
			prim_ch <= vht_ch_80M[idx].ch_up_bnd)
		{
			//pAd->CommonCfg.vht_cent_ch = vht_ch_80M[idx].cent_freq_idx;
			return vht_ch_80M[idx].cent_freq_idx;
		}
		idx++;
	}

	return prim_ch;
}

INT vht_mode_adjust(RTMP_ADAPTER *pAd, MAC_TABLE_ENTRY *pEntry, VHT_CAP_IE *cap, VHT_OP_IE *op)
{
	MULTISSID_STRUCT *wdev;

	wdev = &pAd->ApCfg.MBSSID[pEntry->apidx];

	pEntry->MaxHTPhyMode.field.MODE = MODE_VHT;
	pAd->CommonCfg.AddHTInfo.AddHtInfo2.NonGfPresent = 1;
	pAd->MacTab.fAnyStationNonGF = TRUE;

	if (op != NULL && op->vht_op_info.ch_width >= 1 && pEntry->MaxHTPhyMode.field.BW == BW_40 &&
		wdev->DesiredHtPhyInfo.vht_bw == VHT_BW_80)
	{
		pEntry->MaxHTPhyMode.field.BW = BW_80;
    	}

	/* recheck STBC/SGI for 80MHz */
	if (pEntry->MaxHTPhyMode.field.BW == BW_80) {
		pEntry->MaxHTPhyMode.field.STBC = (pAd->CommonCfg.vht_stbc && cap->vht_cap.rx_stbc > 1) ? 1 : 0;
		pEntry->MaxHTPhyMode.field.ShortGI = (pAd->CommonCfg.vht_sgi_80 && cap->vht_cap.sgi_80M) ? 1 : 0;
	}

	return TRUE;
}

INT ap_vht_mode_adjust(RTMP_ADAPTER *pAd, MAC_TABLE_ENTRY *pEntry, VHT_CAP_IE *cap, VHT_OP_IE *op)
{
	RT_PHY_INFO *ht_phyinfo;
	MULTISSID_STRUCT *wdev;
	PSTRING pCountry = (PSTRING)(pAd->CommonCfg.CountryCode);

	wdev = &pAd->ApCfg.MBSSID[pEntry->apidx];

	pEntry->MaxHTPhyMode.field.MODE = MODE_VHT;

	if (!wdev) 
		return FALSE;


	pAd->CommonCfg.AddHTInfo.AddHtInfo2.NonGfPresent = 1;
	pAd->MacTab.fAnyStationNonGF = TRUE;

	ht_phyinfo = &wdev->DesiredHtPhyInfo;
	if (pEntry->MaxHTPhyMode.field.BW == BW_40) {
		if (ht_phyinfo) {
			DBGPRINT(RT_DEBUG_TRACE, ("%s: DesiredHtPhyInfo->vht_bw=%d, ch_width=%d\n", __FUNCTION__, ht_phyinfo->vht_bw, cap->vht_cap.ch_width));
			if((ht_phyinfo->vht_bw == VHT_BW_2040)) {
				pEntry->MaxHTPhyMode.field.ShortGI = (pAd->CommonCfg.vht_sgi_80 & (cap->vht_cap.sgi_80M));
				pEntry->MaxHTPhyMode.field.STBC = ((pAd->CommonCfg.vht_stbc & cap->vht_cap.rx_stbc) > 1 ? 1 : 0);
			} else if((ht_phyinfo->vht_bw >= VHT_BW_80) && (cap->vht_cap.ch_width == 0)) {
				if (op != NULL) {
					if(op->vht_op_info.ch_width == 0) { //peer support VHT20,40
						pEntry->MaxHTPhyMode.field.BW = BW_40;
					} else {
						pEntry->MaxHTPhyMode.field.BW = BW_80;
					}
				} else {
					/* can not know peer capability, use it's maximum capability */
					pEntry->MaxHTPhyMode.field.BW = BW_80;
				}
				pEntry->MaxHTPhyMode.field.ShortGI = (pAd->CommonCfg.vht_sgi_80 & (cap->vht_cap.sgi_80M));
				pEntry->MaxHTPhyMode.field.STBC = ((pAd->CommonCfg.vht_stbc & cap->vht_cap.rx_stbc) > 1 ? 1 : 0);
			} else if((ht_phyinfo->vht_bw == VHT_BW_80) && (cap->vht_cap.ch_width != 0)) {
				pEntry->MaxHTPhyMode.field.BW = BW_80;
				pEntry->MaxHTPhyMode.field.ShortGI = (pAd->CommonCfg.vht_sgi_80 & (cap->vht_cap.sgi_80M));
				pEntry->MaxHTPhyMode.field.STBC = ((pAd->CommonCfg.vht_stbc& cap->vht_cap.rx_stbc) > 1 ? 1 : 0);
			}
		}
	} else if (pEntry->MaxHTPhyMode.field.BW == BW_80 && ht_phyinfo && ht_phyinfo->vht_bw == VHT_BW_2040) {
		/* limit max phy mode for clients reported only 2040 support */
		DBGPRINT(RT_DEBUG_TRACE, ("%s: DesiredHtPhyInfo->vht_bw=%d, ch_width=%d\n", __FUNCTION__, ht_phyinfo->vht_bw, cap->vht_cap.ch_width));
	        pEntry->MaxHTPhyMode.field.BW = BW_40;
	}

#ifdef BADBCM_FIX
	/* Iphone6, some mackbooks and some huawai honor phones dos not work correctly with 80MHz channel width (BUG?) drop BW to 40MHz */
	if ((pAd->CommonCfg.Channel > 14 && pEntry->MaxHTPhyMode.field.BW > BW_40) &&
		(strncmp(pCountry, "US", 2) != 0) && (strncmp(pCountry, "DE", 2) != 0) &&
		(strncmp(pCountry, "EU", 2) != 0) && (strncmp(pCountry, "FI", 2) != 0)) {
		UCHAR BAD_IPHONE6_1_OUI[]  = {0x74, 0x1B, 0xB2};
		UCHAR BAD_IPHONE6_2_OUI[]  = {0x84, 0x89, 0xAD};
		UCHAR BAD_IPHONE6_3_OUI[]  = {0xD8, 0x1D, 0x72};
		UCHAR BAD_IPHONE6_4_OUI[]  = {0x60, 0xF8, 0x1D};
		UCHAR BAD_IPHONE6_5_OUI[]  = {0x60, 0xA3, 0x7D};
		UCHAR BAD_IPHONE6_6_OUI[]  = {0x88, 0x66, 0xA5};
		UCHAR BAD_IPHONE6_7_OUI[]  = {0x50, 0xA6, 0x7F};
		UCHAR BAD_IPHONE6_8_OUI[]  = {0x6C, 0x72, 0xE7};
		UCHAR BAD_IPHONE6_9_OUI[]  = {0x2C, 0x61, 0xF6};
		UCHAR BAD_IPHONE6_10_OUI[]  = {0x90, 0x8D, 0x6C};
		UCHAR BAD_IPHONE6_11_OUI[]  = {0x90, 0x4F, 0xDA};
		UCHAR BAD_MACBOOK_1_OUI[]  = {0xAC, 0xBC, 0x32};
		UCHAR BAD_MACBOOK_2_OUI[]  = {0xB8, 0xE8, 0x56};
		UCHAR BAD_MACBOOK_3_OUI[]  = {0x08, 0x6D, 0x41};
		UCHAR BAD_MACBOOK_4_OUI[]  = {0x18, 0x65, 0x90};
		UCHAR BAD_MACBOOK_5_OUI[]  = {0xA8, 0x66, 0x7F};
		UCHAR BAD_MACBOOK_6_OUI[]  = {0x98, 0x01, 0xA7};
		UCHAR BAD_HUAWEI_1_OUI[]  = {0x3C, 0xFA, 0x43};
		UCHAR BAD_HUAWEI_2_OUI[]  = {0x7C, 0x11, 0xCB};
		UCHAR BAD_HUAWEI_3_OUI[]  = {0xF0, 0x43, 0x47};
		UCHAR BAD_HUAWEI_4_OUI[]  = {0xA8, 0xC8, 0x3A};
		UCHAR BAD_HUAWEI_5_OUI[]  = {0x10, 0xB1, 0xF8};
		UCHAR BAD_HUAWEI_6_OUI[]  = {0x5C, 0xC3, 0x07};
		UCHAR BAD_HUAWEI_7_OUI[]  = {0x0C, 0x8F, 0xFF};
		UCHAR BAD_ONEPLUS_1_OUI[]  = {0x94, 0x0E, 0x6B};
		if (NdisEqualMemory(pEntry->Addr, BAD_MACBOOK_1_OUI, 3)
			    || NdisEqualMemory(pEntry->Addr, BAD_MACBOOK_2_OUI, 3)
			    || NdisEqualMemory(pEntry->Addr, BAD_MACBOOK_3_OUI, 3)
			    || NdisEqualMemory(pEntry->Addr, BAD_MACBOOK_4_OUI, 3)
			    || NdisEqualMemory(pEntry->Addr, BAD_MACBOOK_5_OUI, 3)
			    || NdisEqualMemory(pEntry->Addr, BAD_MACBOOK_6_OUI, 3)
			    || NdisEqualMemory(pEntry->Addr, BAD_IPHONE6_1_OUI, 3)
			    || NdisEqualMemory(pEntry->Addr, BAD_IPHONE6_2_OUI, 3)
			    || NdisEqualMemory(pEntry->Addr, BAD_IPHONE6_3_OUI, 3)
			    || NdisEqualMemory(pEntry->Addr, BAD_IPHONE6_4_OUI, 3)
			    || NdisEqualMemory(pEntry->Addr, BAD_IPHONE6_5_OUI, 3)
			    || NdisEqualMemory(pEntry->Addr, BAD_IPHONE6_6_OUI, 3)
			    || NdisEqualMemory(pEntry->Addr, BAD_IPHONE6_7_OUI, 3)
			    || NdisEqualMemory(pEntry->Addr, BAD_IPHONE6_8_OUI, 3)
			    || NdisEqualMemory(pEntry->Addr, BAD_IPHONE6_9_OUI, 3)
			    || NdisEqualMemory(pEntry->Addr, BAD_IPHONE6_10_OUI, 3)
			    || NdisEqualMemory(pEntry->Addr, BAD_IPHONE6_11_OUI, 3)
			    || NdisEqualMemory(pEntry->Addr, BAD_HUAWEI_1_OUI, 3)
			    || NdisEqualMemory(pEntry->Addr, BAD_HUAWEI_2_OUI, 3)
			    || NdisEqualMemory(pEntry->Addr, BAD_HUAWEI_3_OUI, 3)
			    || NdisEqualMemory(pEntry->Addr, BAD_HUAWEI_4_OUI, 3)
			    || NdisEqualMemory(pEntry->Addr, BAD_HUAWEI_5_OUI, 3)
			    || NdisEqualMemory(pEntry->Addr, BAD_HUAWEI_6_OUI, 3)
			    || NdisEqualMemory(pEntry->Addr, BAD_HUAWEI_7_OUI, 3)
			    || NdisEqualMemory(pEntry->Addr, BAD_ONEPLUS_1_OUI, 3)) {
			    pEntry->MaxHTPhyMode.field.BW = BW_40;
			    printk("Client %02x:%02x:%02x:%02x:%02x:%02x is bcm BCM4345x based. Disable 80MHz channel (bcm bug).\n", PRINT_MAC(pEntry->Addr));
		}
	}

	/* Galaxy S5 with 6.0.1 android not correct work in VHT modes at high channels, must be fixed in Android7 update from samsung */
	if (pAd->CommonCfg.Channel > 64 && pEntry->MaxHTPhyMode.field.BW > BW_40 && pEntry->MaxHTPhyMode.field.MODE == MODE_VHT) {
		UCHAR BAD_SAMSUNG_1_OUI[]  = {0x84, 0x38, 0x38};
		if (NdisEqualMemory(pEntry->Addr, BAD_SAMSUNG_1_OUI, 3)) {
			    pEntry->MaxHTPhyMode.field.BW = BW_20;
			    printk("Client %02x:%02x:%02x:%02x:%02x:%02x is bcm BCM4345x based. Fallback to 20MHz for VHT (samsung bug).\n", PRINT_MAC(pEntry->Addr));
		}
	}
#endif /* BADBCM_FIX */

	/* recheck STBC/SGI for 80MHz */
	if (pEntry->MaxHTPhyMode.field.BW == BW_80) {
		pEntry->MaxHTPhyMode.field.STBC = (pAd->CommonCfg.vht_stbc && cap->vht_cap.rx_stbc > 1) ? 1 : 0;
		pEntry->MaxHTPhyMode.field.ShortGI = (pAd->CommonCfg.vht_sgi_80 && cap->vht_cap.sgi_80M) ? 1 : 0;
	}

	return TRUE;
}


INT get_vht_op_ch_width(RTMP_ADAPTER *pAd)
{
	
	return TRUE;
}

INT build_vht_txpwr_envelope(RTMP_ADAPTER *pAd, UCHAR *buf)
{
	INT len = 0, pwr_cnt;
	VHT_TXPWR_ENV_IE txpwr_env;

	NdisZeroMemory(&txpwr_env, sizeof(txpwr_env));

	if (pAd->CommonCfg.vht_bw == VHT_BW_80) {
		pwr_cnt = 2;
	} else {
		if (pAd->CommonCfg.AddHTInfo.AddHtInfo.RecomWidth == 1)
			pwr_cnt = 1;
		else
			pwr_cnt = 0;
	}
	txpwr_env.tx_pwr_info.max_tx_pwr_cnt = pwr_cnt;
	txpwr_env.tx_pwr_info.max_tx_pwr_interpretation = TX_PWR_INTERPRET_EIRP;

// TODO: fixme, we need the real tx_pwr value for each port.
	for (len = 0; len < pwr_cnt; len++)
		txpwr_env.tx_pwr_bw[len] = (RTMP_GetTxPwr(pAd, pAd->MacTab.Content[0].HTPhyMode) * 2 - 1); /* current tx pwr -0.5dB */

	len = 2 + pwr_cnt;
	NdisMoveMemory(buf, &txpwr_env, len);
	
	return len;
}

/********************************************************************
	Procedures for 802.11 AC Information elements
********************************************************************/
/*
	Defined in IEEE 802.11AC

	Appeared in Beacon, ProbResp frames
*/
INT build_quiet_channel(RTMP_ADAPTER *pAd, UCHAR *buf)
{
	INT len = 0;


	return len;
}


/*
	Defined in IEEE 802.11AC

	Appeared in Beacon, ProbResp frames
*/
INT build_ext_bss_load(RTMP_ADAPTER *pAd, UCHAR *buf)
{
	INT len = 0;


	return len;
}

VOID vht_max_mcs_cap(RTMP_ADAPTER *pAd)
{
#ifdef CONFIG_DISABLE_VHT80_256_QAM
	DBGPRINT(RT_DEBUG_TRACE, ("@@@ %s: disable_vht_256QAM = 0x%x\n",
		__FUNCTION__, pAd->CommonCfg.disable_vht_256QAM));

	if ((pAd->CommonCfg.vht_bw == VHT_BW_80) &&
		(pAd->CommonCfg.disable_vht_256QAM & DISABLE_VHT80_256_QAM))
		pAd->CommonCfg.vht_max_mcs_cap = VHT_MCS_CAP_7;
	else
#endif /* DISABLE_VHT80_256_QAM */
	pAd->CommonCfg.vht_max_mcs_cap = VHT_MCS_CAP_9;

	DBGPRINT(RT_DEBUG_TRACE, ("@@@ %s: vht_max_mcs_cap = %d\n",
		__FUNCTION__, pAd->CommonCfg.vht_max_mcs_cap));	
}

/*
	Defined in IEEE 802.11AC

	Appeared in Beacon, ProbResp frames
*/
INT build_ext_pwr_constraint(RTMP_ADAPTER *pAd, UCHAR *buf)
{
	INT len = 0;


	return len;
}


/*
	Defined in IEEE 802.11AC

	Appeared in Beacon, ProbResp frames
*/
INT build_vht_pwr_envelope(RTMP_ADAPTER *pAd, UCHAR *buf)
{
	INT len = 0;

	
	return len;
}


/*
	Defined in IEEE 802.11AC

	Appeared in Beacon, (Re)AssocResp, ProbResp frames
*/	
INT build_vht_op_ie(RTMP_ADAPTER *pAd, UCHAR *buf)
{
	VHT_OP_IE vht_op;
	UCHAR cent_ch;
#ifdef RT_BIG_ENDIAN
	UINT16 tmp;
#endif /* RT_BIG_ENDIAN */

	NdisZeroMemory((UCHAR *)&vht_op, sizeof(VHT_OP_IE));
	vht_op.vht_op_info.ch_width = (pAd->CommonCfg.vht_bw == VHT_BW_80 ? 1: 0);

#ifdef CONFIG_AP_SUPPORT
#ifdef DFS_SUPPORT
	if (pAd->CommonCfg.Channel > 14 && 
		(pAd->CommonCfg.bIEEE80211H == 1) && 
		(pAd->Dot11_H.RDMode == RD_SWITCHING_MODE))
		cent_ch = vht_cent_ch_freq(pAd, pAd->Dot11_H.org_ch);
	else
#endif /* DFS_SUPPORT */
#endif /* CONFIG_AP_SUPPORT */
		cent_ch = vht_cent_ch_freq(pAd, pAd->CommonCfg.Channel);

	switch (vht_op.vht_op_info.ch_width)
	{
		case VHT_BW_2040:
			vht_op.vht_op_info.ch_width = 0;
			vht_op.vht_op_info.center_freq_1 = 0;
			vht_op.vht_op_info.center_freq_2 = 0;
			break;
		case VHT_BW_80:
			vht_op.vht_op_info.ch_width = 1;
			vht_op.vht_op_info.center_freq_1 = cent_ch;
			vht_op.vht_op_info.center_freq_2 = 0;
			break;
		case VHT_BW_160:
			vht_op.vht_op_info.ch_width = 2;
			vht_op.vht_op_info.center_freq_1 = cent_ch;
			vht_op.vht_op_info.center_freq_2 = 0;
			break;
		case VHT_BW_8080:
			vht_op.vht_op_info.ch_width = 3;
			vht_op.vht_op_info.center_freq_1 = cent_ch;
			vht_op.vht_op_info.center_freq_2 = pAd->CommonCfg.vht_cent_ch2;
			break;
	}

	vht_op.basic_mcs_set.mcs_ss1 = 3;
	vht_op.basic_mcs_set.mcs_ss2 = 3;
	vht_op.basic_mcs_set.mcs_ss3 = 3;
	vht_op.basic_mcs_set.mcs_ss4 = 3;
	vht_op.basic_mcs_set.mcs_ss5 = 3;
	vht_op.basic_mcs_set.mcs_ss6 = 3;
	vht_op.basic_mcs_set.mcs_ss7 = 3;
	vht_op.basic_mcs_set.mcs_ss8 = 3;
	switch  (pAd->CommonCfg.RxStream)
	{
		case 2:
			vht_op.basic_mcs_set.mcs_ss2 = VHT_MCS_CAP_7;
		case 1:
#ifdef MT76x0
			if (IS_MT76x0(pAd))
			{
				/*
					MT7650E2 support VHT_MCS8 & VHT_MCS9.
				*/
				vht_op.basic_mcs_set.mcs_ss1 = (((pAd->CommonCfg.vht_bw == VHT_BW_2040)
					&& (pAd->CommonCfg.RegTransmitSetting.field.BW == BW_20)) ? VHT_MCS_CAP_8 : VHT_MCS_CAP_9);
			}
			else
#endif /* MT76x0 */
				vht_op.basic_mcs_set.mcs_ss1 = VHT_MCS_CAP_7;
			break;
	}

#ifdef RT_BIG_ENDIAN
	//SWAP16((UINT16)vht_op.basic_mcs_set);
	NdisCopyMemory(&tmp,&vht_op.basic_mcs_set, 2);
	tmp=SWAP16(tmp);
	NdisCopyMemory(&vht_op.basic_mcs_set,&tmp, 2);
#endif /* RT_BIG_ENDIAN */
	NdisMoveMemory((UCHAR *)buf, (UCHAR *)&vht_op, sizeof(VHT_OP_IE));
	
	return sizeof(VHT_OP_IE);
}


/*
	Defined in IEEE 802.11AC

	Appeared in Beacon, (Re)AssocReq, (Re)AssocResp, ProbReq/Resp frames
*/
INT build_vht_cap_ie(RTMP_ADAPTER *pAd, UCHAR *buf, UCHAR VhtMaxMcsCap)
{
	VHT_CAP_IE vht_cap_ie;
	INT rx_nss, tx_nss;
#ifdef RT_BIG_ENDIAN
	UINT32 tmp_1;
	UINT64 tmp_2;
#endif /*RT_BIG_ENDIAN*/

	NdisZeroMemory((UCHAR *)&vht_cap_ie,  sizeof(VHT_CAP_IE));
	vht_cap_ie.vht_cap.max_mpdu_len = 0; // TODO: Ask Jerry about hardware limitation.
	vht_cap_ie.vht_cap.ch_width = 0; /* not support 160 or 80 + 80 MHz */

	/* always set ldpc to 0 7610 do not support it */
	vht_cap_ie.vht_cap.rx_ldpc = 0;

	vht_cap_ie.vht_cap.sgi_80M = pAd->CommonCfg.vht_sgi_80 && (pAd->CommonCfg.BBPCurrentBW == BW_80);
	vht_cap_ie.vht_cap.htc_vht_cap = 1;
	vht_cap_ie.vht_cap.max_ampdu_exp = 3; // TODO: Ask Jerry about the hardware limitation, currently set as 64K

	vht_cap_ie.vht_cap.tx_stbc = 0;
	vht_cap_ie.vht_cap.rx_stbc = 0;
	if (pAd->CommonCfg.vht_stbc)
	{
		if (pAd->CommonCfg.TxStream >= 2)
			vht_cap_ie.vht_cap.tx_stbc = 1;
		else
			vht_cap_ie.vht_cap.tx_stbc = 0;
		
		if (pAd->CommonCfg.RxStream >= 1)
			vht_cap_ie.vht_cap.rx_stbc = 1; // TODO: is it depends on the number of our antennas?
		else
			vht_cap_ie.vht_cap.rx_stbc = 0;
	}

	vht_cap_ie.vht_cap.tx_ant_consistency = 1;
	vht_cap_ie.vht_cap.rx_ant_consistency = 1;

	vht_cap_ie.mcs_set.rx_mcs_map.mcs_ss1 = VHT_MCS_CAP_NA;
	vht_cap_ie.mcs_set.rx_mcs_map.mcs_ss2 = VHT_MCS_CAP_NA;
	vht_cap_ie.mcs_set.rx_mcs_map.mcs_ss3 = VHT_MCS_CAP_NA;
	vht_cap_ie.mcs_set.rx_mcs_map.mcs_ss4 = VHT_MCS_CAP_NA;
	vht_cap_ie.mcs_set.rx_mcs_map.mcs_ss5 = VHT_MCS_CAP_NA;
	vht_cap_ie.mcs_set.rx_mcs_map.mcs_ss6 = VHT_MCS_CAP_NA;
	vht_cap_ie.mcs_set.rx_mcs_map.mcs_ss7 = VHT_MCS_CAP_NA;
	vht_cap_ie.mcs_set.rx_mcs_map.mcs_ss8 = VHT_MCS_CAP_NA;

	vht_cap_ie.mcs_set.tx_mcs_map.mcs_ss1 = VHT_MCS_CAP_NA;
	vht_cap_ie.mcs_set.tx_mcs_map.mcs_ss2 = VHT_MCS_CAP_NA;
	vht_cap_ie.mcs_set.tx_mcs_map.mcs_ss3 = VHT_MCS_CAP_NA;
	vht_cap_ie.mcs_set.tx_mcs_map.mcs_ss4 = VHT_MCS_CAP_NA;
	vht_cap_ie.mcs_set.tx_mcs_map.mcs_ss5 = VHT_MCS_CAP_NA;
	vht_cap_ie.mcs_set.tx_mcs_map.mcs_ss6 = VHT_MCS_CAP_NA;
	vht_cap_ie.mcs_set.tx_mcs_map.mcs_ss7 = VHT_MCS_CAP_NA;
	vht_cap_ie.mcs_set.tx_mcs_map.mcs_ss8 = VHT_MCS_CAP_NA;

	rx_nss = pAd->CommonCfg.RxStream;
	tx_nss = pAd->CommonCfg.TxStream;

	switch  (rx_nss)
	{
		case 1:
			vht_cap_ie.mcs_set.rx_high_rate = 292;
#ifdef MT76x0
			if (IS_MT76x0(pAd))
			{
				/*
					MT7650E2 support VHT_MCS8 & VHT_MCS9.
				*/
				vht_cap_ie.mcs_set.rx_mcs_map.mcs_ss1 = VhtMaxMcsCap;
			}
			else
#endif /* MT76x0 */
			vht_cap_ie.mcs_set.rx_mcs_map.mcs_ss1 = VHT_MCS_CAP_7;

			break;
		case 2:
			vht_cap_ie.mcs_set.rx_high_rate = 585;
			vht_cap_ie.mcs_set.rx_mcs_map.mcs_ss1 = VHT_MCS_CAP_7;
			vht_cap_ie.mcs_set.rx_mcs_map.mcs_ss2 = VHT_MCS_CAP_7;
			break;
		default:
			vht_cap_ie.mcs_set.rx_high_rate = 0;
			break;
	}

	switch (tx_nss)
	{
		case 1:
			vht_cap_ie.mcs_set.tx_high_rate = 292;
#ifdef MT76x0
			if (IS_MT76x0(pAd))
			{
				/*
					MT7650E2 support VHT_MCS8 & VHT_MCS9.
				*/
				vht_cap_ie.mcs_set.tx_mcs_map.mcs_ss1 = VhtMaxMcsCap;
			}
			else
#endif /* MT76x0 */
			vht_cap_ie.mcs_set.tx_mcs_map.mcs_ss1 = VHT_MCS_CAP_7;
			break;
		case 2:
			vht_cap_ie.mcs_set.tx_high_rate = 585;
			vht_cap_ie.mcs_set.tx_mcs_map.mcs_ss1 = VHT_MCS_CAP_7;
			vht_cap_ie.mcs_set.tx_mcs_map.mcs_ss2 = VHT_MCS_CAP_7;
			break;
		default:
			vht_cap_ie.mcs_set.tx_high_rate = 0;
			break;
	}

#ifdef RT_BIG_ENDIAN
	NdisCopyMemory(&tmp_1,&vht_cap_ie.vht_cap, 4);
	tmp_1 = SWAP32(tmp_1);
	NdisCopyMemory(&vht_cap_ie.vht_cap,&tmp_1, 4);
	
	NdisCopyMemory(&tmp_2,&vht_cap_ie.mcs_set, 8);	
	tmp_2=SWAP64(tmp_2);
	NdisCopyMemory(&vht_cap_ie.mcs_set,&tmp_2, 8);

	//hex_dump("&vht_cap_ie", &vht_cap_ie,  sizeof(VHT_CAP_IE));
	//SWAP32((UINT32)vht_cap_ie.vht_cap);
	//SWAP32((UINT32)vht_cap_ie.mcs_set);
#endif /* RT_BIG_ENDIAN */

	NdisMoveMemory(buf, (UCHAR *)&vht_cap_ie, sizeof(VHT_CAP_IE));

	return sizeof(VHT_CAP_IE);
}

INT build_vht_op_mode_ies(RTMP_ADAPTER *pAd, UCHAR *buf)
{
	INT len = 0;
	EID_STRUCT eid_hdr;
	OPERATING_MODE operating_mode_ie;   
    
	NdisZeroMemory((UCHAR *)&operating_mode_ie,  sizeof(OPERATING_MODE));
    
	eid_hdr.Eid = IE_OPERATING_MODE_NOTIFY;
	eid_hdr.Len = sizeof(OPERATING_MODE);
	NdisMoveMemory(buf, (UCHAR *)&eid_hdr, 2);
	len = 2;

	operating_mode_ie.rx_nss_type = 0;
	operating_mode_ie.rx_nss = (pAd->CommonCfg.RxStream - 1);

	if (pAd->CommonCfg.vht_bw == VHT_BW_2040)
		operating_mode_ie.ch_width = 1;
	else if (pAd->CommonCfg.vht_bw == VHT_BW_80)
		operating_mode_ie.ch_width = 2;
	else if ((pAd->CommonCfg.vht_bw == VHT_BW_160) ||
		(pAd->CommonCfg.vht_bw == VHT_BW_8080))
		operating_mode_ie.ch_width = 3;
	else
		operating_mode_ie.ch_width = 0;

	buf += len;
	NdisMoveMemory(buf, (UCHAR *)&operating_mode_ie, sizeof(OPERATING_MODE));
	len += eid_hdr.Len;
    
	return len;
    
}

INT build_vht_ies(RTMP_ADAPTER *pAd, UCHAR *buf, UCHAR frm, UCHAR VhtMaxMcsCap)
{
	INT len = 0;
	EID_STRUCT eid_hdr;

        NdisZeroMemory(&eid_hdr, sizeof(EID_STRUCT));

	eid_hdr.Eid = IE_VHT_CAP;
	eid_hdr.Len = sizeof(VHT_CAP_IE);
	NdisMoveMemory(buf, (UCHAR *)&eid_hdr, 2);
	len = 2;

	len += build_vht_cap_ie(pAd, (UCHAR *)(buf + len), VhtMaxMcsCap);
	if (frm == SUBTYPE_BEACON || frm == SUBTYPE_PROBE_RSP ||
		frm == SUBTYPE_ASSOC_RSP || frm == SUBTYPE_REASSOC_RSP)
	{
		eid_hdr.Eid = IE_VHT_OP;
		eid_hdr.Len = sizeof(VHT_OP_IE);
		NdisMoveMemory((UCHAR *)(buf + len), (UCHAR *)&eid_hdr, 2);
		len +=2;

		len += build_vht_op_ie(pAd, (UCHAR *)(buf + len));
	}
	
	return len;
}

BOOLEAN vht80_channel_group( RTMP_ADAPTER *pAd, UCHAR channel)
{
	INT idx = 0;

	if (channel <= 14)
		return FALSE;
	
	while (vht_ch_80M[idx].ch_up_bnd != 0)
	{
		if (channel >= vht_ch_80M[idx].ch_low_bnd &&
			channel <= vht_ch_80M[idx].ch_up_bnd)
		{
			if ( (pAd->CommonCfg.RDDurRegion == JAP ||
				pAd->CommonCfg.RDDurRegion == JAP_W53 ||
				pAd->CommonCfg.RDDurRegion == JAP_W56 ||
				pAd->CommonCfg.RDDurRegion == CE
				) &&
				vht_ch_80M[idx].cent_freq_idx == 138)
			{
				idx++;
				continue;
			}

			return TRUE;
		}
		idx++;
	}

	return FALSE;
}

