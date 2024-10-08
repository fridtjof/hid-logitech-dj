KVERSION := `uname -r`
KDIR := /lib/modules/${KVERSION}/build

LSMOD_GREP = $(shell lsmod | grep "hid_logitech_dj")
# USB_VENDOR_ID_LOGITECH
LSUSB_GREP = $(shell lsusb | grep "046d")


default:
	$(MAKE) -C $(KDIR) M=$$PWD

install: default
	$(MAKE) -C $(KDIR) M=$$PWD modules_install
	depmod -A
	insmod ./hid-logitech-dj.ko

uninstall:
ifeq ($(LSMOD_GREP),)
	@echo "module not installed, doing nothing"; \
	exit 1
else
	@echo "hid_logitech_dj module is installed, attempting to remove"
endif

ifeq ($(LSUSB_GREP),)
	@echo "device unplugged, OK to continue"
else
	@echo "ERROR: device is still plugged in, DO NOT RMMOD!"
	exit 1
endif

	@echo "checking if superuser"

ifeq ($(shell id -u), 0)
	@echo "user is superuser, removing module"
	rmmod hid-logitech-dj
else
	@echo "ERROR: must uninstall as superuser"
	exit 1
endif

clean:
	$(MAKE) -C $(KDIR) M=$$PWD clean
