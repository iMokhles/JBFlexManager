DEBUG=0
GO_EASY_ON_ME=1
export THEOS_DEVICE_IP=192.168.1.10
ARCHS = armv7 arm64 arm64e
TARGET = iphone:clang:11.2:9.0

export ADDITIONAL_LDFLAGS = -Wl,-segalign,4000

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = JBFlexManager
JBFlexManager_FILES = JBFlexManager.mm PFStatusBarAlert.mm
JBFlexManager_INSTALL_PATH = /Library/PreferenceBundles
JBFlexManager_FRAMEWORKS = UIKit
JBFlexManager_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/JBFlexManager.plist$(ECHO_END)
