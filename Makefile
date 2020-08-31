FINALPACKAGE = 1

export TARGET = iphone:14.0:11.0
export ADDITIONAL_CFLAGS = -DTHEOS_LEAN_AND_MEAN -fobjc-arc

ARCHS = arm64 arm64e

include $(THEOS)/makefiles/common.mk

LIBRARY_NAME = libmitsuhaforever
$(LIBRARY_NAME)_OBJC_FILES = $(wildcard *.m)
$(LIBRARY_NAME)_FILES = $(wildcard *.swift)
$(LIBRARY_NAME)_LIBRARIES = colorpicker

include $(THEOS_MAKE_PATH)/library.mk

after-install::
	install.exec "killall -9 SpringBoard"

stage::
	mkdir -p $(THEOS_STAGING_DIR)/usr/include/MitsuhaForever
	$(ECHO_NOTHING)rsync -a ./public/* $(THEOS_STAGING_DIR)/usr/include/MitsuhaForever $(FW_RSYNC_EXCLUDES)$(ECHO_END)
	mkdir -p $(THEOS)/include/MitsuhaForever
	cp -r ./public/* $(THEOS)/include/MitsuhaForever
	cp $(THEOS_STAGING_DIR)/usr/lib/libmitsuhaforever.dylib $(THEOS)/lib/libmitsuhaforever.dylib
