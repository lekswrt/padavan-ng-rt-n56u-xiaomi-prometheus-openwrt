##################################################################
# Board PID # Board Name       # PRODUCT # Note
##################################################################
# ARCHERC20  # TP-LINK ARCHER C20    # MT7628  #
##################################################################

CFLAGS += -DBOARD_ARCHER_C20 -DVENDOR_TPLINK
BOARD_NUM_USB_PORTS=0

### TP-LINK firmware description ###
TPLINK_HWID=0xc200005
TPLINK_HWREV=0x1
TPLINK_HWREVADD=0x5
TPLINK_FLASHLAYOUT=8MSUmtk
TPLINK_HVERSION=3
