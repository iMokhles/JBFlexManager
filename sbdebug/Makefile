DEBUG=0
GO_EASY_ON_ME=1
export THEOS_DEVICE_IP=192.168.1.10
ARCHS = armv7 arm64 arm64e
TARGET = iphone:clang:11.2:9.0

export ADDITIONAL_LDFLAGS = -Wl,-segalign,4000


THEOS_BUILD_DIR = Packages

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = SBDebug
SBDebug_FILES = Switch.xm
SBDebug_FRAMEWORKS = UIKit
SBDebug_LIBRARIES = flipswitch
SBDebug_INSTALL_PATH = /Library/Switches

include $(THEOS_MAKE_PATH)/bundle.mk

after-install::
	install.exec "killall -9 SpringBoard"
