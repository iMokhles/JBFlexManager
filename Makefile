DEBUG=0
GO_EASY_ON_ME=1
export THEOS_DEVICE_IP=localhost
export THEOS_DEVICE_PORT=2222
ARCHS = armv7 arm64 arm64e
TARGET = iphone:clang:latest:9.0
FINALPACKAGE = 1
FOR_RELEASE = 1
export ADDITIONAL_LDFLAGS = -Wl,-segalign,4000

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = JBFlexManager
JBFlexManager_CFLAGS = -fobjc-arc -Wno-deprecated-declarations -Wno-unused-function -Wunsupported-availability-guard -Wunused-property-ivar
JBFlexManager_FILES = JBFlexManager.xm JBFlexManagerHelper.m $(wildcard FLEX/*.m) $(wildcard FLEX/*.c) $(wildcard FLEX/*.mm)
JBFlexManager_FRAMEWORKS = Foundation UIKit CoreGraphics QuartzCore ImageIO
JBFlexManager_LIBRARIES = substrate MobileGestalt z sqlite3
include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 backboardd"
SUBPROJECTS += jbflexmanager
SUBPROJECTS += sbdebug
include $(THEOS_MAKE_PATH)/aggregate.mk
