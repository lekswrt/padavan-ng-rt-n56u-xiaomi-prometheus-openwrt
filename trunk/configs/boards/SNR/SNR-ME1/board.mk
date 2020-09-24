##################################################################
# Board PID # Board Name       # PRODUCT # Note
##################################################################
# SNR-ME1 # SNR-ME1  # MT7621  #
##################################################################

# Must force use single mac mode.
CFLAGS += -DBOARD_SNRME1
BOARD_NUM_USB_PORTS=1
