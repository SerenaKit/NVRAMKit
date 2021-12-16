TARGET := iphone:clang:latest:14.0

include $(THEOS)/makefiles/common.mk

TOOL_NAME = nvramutil

nvramutil_FILES = $(shell find Sources/* -name '*.swift')
nvramutil_CODESIGN_FLAGS = -SSources/NVRAMUtil/ios-entitlements.plist
nvramutil_SWIFT_BRIDGING_HEADER = Sources/NVRAMUtil/iOS-Bridge.h
nvramutil_FRAMEWORKS = IOKit
nvramutil_INSTALL_PATH = /usr/bin

include $(THEOS_MAKE_PATH)/tool.mk
