export TARGET = iphone:clang:18.6:15.0
export SDK_PATH = $(THEOS)/sdks/iPhoneOS18.6.sdk/
export SYSROOT = $(SDK_PATH)
export ARCHS = arm64

export libcolorpicker_ARCHS = arm64
export libFLEX_ARCHS = arm64
export Alderis_XCODEOPTS = LD_DYLIB_INSTALL_NAME=@rpath/Alderis.framework/Alderis
export Alderis_XCODEFLAGS = DYLIB_INSTALL_NAME_BASE=/Library/Frameworks BUILD_LIBRARY_FOR_DISTRIBUTION=YES ARCHS="$(ARCHS)"
export libcolorpicker_LDFLAGS = -F$(TARGET_PRIVATE_FRAMEWORK_PATH) -install_name @rpath/libcolorpicker.dylib
export ADDITIONAL_CFLAGS = -I$(THEOS_PROJECT_DIR)/Tweaks/RemoteLog -I$(THEOS_PROJECT_DIR)/Tweaks # Allow YouTubeHeader to be accessible using #include <...>

ifneq ($(JAILBROKEN),1)
export DEBUGFLAG = -ggdb -Wno-unused-command-line-argument -L$(THEOS_OBJ_DIR) -F$(_THEOS_LOCAL_DATA_DIR)/$(THEOS_OBJ_DIR_NAME)/install/Library/Frameworks
MODULES = jailed
endif
PACKAGE_NAME = YTModPlus
PACKAGE_VERSION = X.X.X-X.X

INSTALL_TARGET_PROCESSES = YouTube
TWEAK_NAME = YTModPlus
DISPLAY_NAME = YouTube
BUNDLE_ID = com.google.ios.youtube

YTModPlus_FILES = YTModPlus.xm $(shell find Source -name '*.xm' -o -name '*.x' -o -name '*.m')
YTModPlus_FRAMEWORKS = UIKit Security
YTModPlus_INJECT_DYLIBS = Tweaks/YouMod/Library/MobileSubstrate/DynamicLibraries/YouMod.dylib .theos/obj/libFLEX.dylib .theos/obj/YTUHD.dylib .theos/obj/YouPiP.dylib .theos/obj/YouTubeDislikesReturn.dylib .theos/obj/YTABConfig.dylib .theos/obj/DontEatMyContent.dylib .theos/obj/YTVideoOverlay.dylib .theos/obj/YouTimeStamp.dylib .theos/obj/YouGroupSettings.dylib
YTModPlus_EMBED_LIBRARIES = $(THEOS_OBJ_DIR)/libcolorpicker.dylib
YTModPlus_EMBED_FRAMEWORKS = $(_THEOS_LOCAL_DATA_DIR)/$(THEOS_OBJ_DIR_NAME)/install_Alderis.xcarchive/Products/Library/Frameworks/Alderis.framework
YTModPlus_CFLAGS = -fobjc-arc -Wno-deprecated-declarations -Wno-unused-but-set-variable -DTWEAK_VERSION=\"$(PACKAGE_VERSION)\"
YTModPlus_EMBED_BUNDLES = $(wildcard Bundles/*.bundle)
YTModPlus_EMBED_EXTENSIONS = $(wildcard Extensions/*.appex)
YTModPlus_IPA = ./tmp/Payload/YouTube.app
YTModPlus_CFLAGS = -fobjc-arc -Wno-deprecated-declarations -Wno-unsupported-availability-guard -Wno-unused-but-set-variable -DTWEAK_VERSION=$(PACKAGE_VERSION) $(EXTRA_CFLAGS)
YTModPlus_USE_FISHHOOK = 0

include $(THEOS)/makefiles/common.mk
ifneq ($(JAILBROKEN),1)
SUBPROJECTS += Tweaks/Alderis Tweaks/FLEXing/libflex Tweaks/YTUHD Tweaks/YouPiP Tweaks/Return-YouTube-Dislikes Tweaks/YTABConfig Tweaks/DontEatMyContent Tweaks/YTVideoOverlay Tweaks/YouTimeStamp Tweaks/YouGroupSettings
include $(THEOS_MAKE_PATH)/aggregate.mk
endif
include $(THEOS_MAKE_PATH)/tweak.mk

FINALPACKAGE = 1
REMOVE_EXTENSIONS = 1
CODESIGN_IPA = 0

YOUMOD_PATH = Tweaks/YTLite
YOUMOD_VERSION ?= $(shell curl -s https://api.github.com/repos/dayanch96/YTLite/releases/latest | grep '"tag_name"' | sed 's/.*"v\(.*\)".*/\1/')
ifeq ($(YTLITE_VERSION),)
$(error Failed to fetch latest YTLite version from GitHub API)
endif
YOUMOD_DEB = $(YOUMOD_PATH)/dev.water888.youmod_$(YOUMOD_VERSION)_iphoneos-arm64.deb
YOUMOD_DYLIB = $(YTLITE_PATH)/Library/MobileSubstrate/DynamicLibraries/YouMod.dylib
YOUMOD_BUNDLE = $(YTLITE_PATH)/Library/Application\ Support/YouMod.bundle

internal-clean::
	@rm -rf $(YOUMOD_PATH)/*

ifneq ($(JAILBROKEN),1)
before-all::
	@if [[ ! -f $(YTLITE_DEB) ]]; then \
        	rm -rf $(YTLITE_PATH)/*; \
        	$(PRINT_FORMAT_BLUE) "Downloading YouMod"; \
	fi
before-all::
	@if [[ ! -f $(YTLITE_DEB) ]]; then \
		curl -s -L "https://github.com/dayanch96/YTLite/releases/download/v$(YTLITE_VERSION)/com.dvntm.ytlite_$(YTLITE_VERSION)_iphoneos-arm64.deb" -o $(YTLITE_DEB); \
	fi; \
	if [[ ! -f $(YTLITE_DYLIB) || ! -d $(YTLITE_BUNDLE) ]]; then \
		tar -xf $(YTLITE_DEB) -C $(YTLITE_PATH); tar -xf $(YTLITE_PATH)/data.tar* -C $(YTLITE_PATH); \
		if [[ ! -f $(YTLITE_DYLIB) || ! -d $(YTLITE_BUNDLE) ]]; then \
			$(PRINT_FORMAT_ERROR) "Failed to extract YTLite"; exit 1; \
		fi; \
	fi;
else
before-package::
	@mkdir -p $(THEOS_STAGING_DIR)/Library/Application\ Support; cp -r lang/YTLitePlus.bundle $(THEOS_STAGING_DIR)/Library/Application\ Support/
endif
