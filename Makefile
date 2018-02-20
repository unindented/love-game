GAME_NAME := love-game
GAME_VERSION := $(shell git describe --tags $(shell git rev-list --tags --max-count=1))
LOVE_VERSION := 0.10.2

# URLS =========================================================================

LOVE_REPOSITORY_URL := https://bitbucket.org/rude/love
LOVE_ANDROID_REPOSITORY_URL := https://bitbucket.org/MartinFelis/love-android-sdl2

LOVE_WINX86_APP_ZIP := love-$(LOVE_VERSION)-win32.zip
LOVE_WINX86_APP_URL := https://bitbucket.org/rude/love/downloads/$(LOVE_WINX86_APP_ZIP)
LOVE_WINX64_APP_ZIP := love-$(LOVE_VERSION)-win64.zip
LOVE_WINX64_APP_URL := https://bitbucket.org/rude/love/downloads/$(LOVE_WINX64_APP_ZIP)
LOVE_MACOS_LIBRARIES_ZIP := love-osx-frameworks-$(basename $(LOVE_VERSION)).zip
LOVE_MACOS_LIBRARIES_URL := https://love2d.org/sdk/$(LOVE_MACOS_LIBRARIES_ZIP)
LOVE_IOS_LIBRARIES_ZIP := love-$(LOVE_VERSION)-ios-libraries.zip
LOVE_IOS_LIBRARIES_URL := https://bitbucket.org/rude/love/downloads/$(LOVE_IOS_LIBRARIES_ZIP)

# DIRS & FILES =================================================================

ROOT_DIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))

LOVE_DIR := $(ROOT_DIR)/vendor/love
LOVE_LINUX_DIR := $(LOVE_DIR)/platform/unix
LOVE_WINX86_DIR := $(LOVE_DIR)/platform/winx86
LOVE_WINX64_DIR := $(LOVE_DIR)/platform/winx64
LOVE_XCODE_DIR := $(LOVE_DIR)/platform/xcode
LOVE_MACOS_DIR := $(LOVE_XCODE_DIR)/macosx
LOVE_MACOS_LIBRARIES_DIR := /Library/Frameworks
LOVE_IOS_DIR := $(LOVE_XCODE_DIR)/ios
LOVE_IOS_LIBRARIES_DIR := $(LOVE_IOS_DIR)
LOVE_ANDROID_DIR := $(ROOT_DIR)/vendor/love-android
LOVE_ANDROID_RES_DIR := $(LOVE_ANDROID_DIR)/app/src/main/assets

LOVE_MACOS_LIBRARIES := FreeType.framework Lua.framework Ogg.framework OpenAL-Soft.framework SDL2.framework Theora.framework Vorbis.framework libmodplug.framework mpg123.framework physfs.framework
LOVE_MACOS_LIBRARIES := $(addprefix $(LOVE_MACOS_LIBRARIES_DIR)/, $(LOVE_MACOS_LIBRARIES))

LOVE_IOS_LIBRARIES := include libraries
LOVE_IOS_LIBRARIES := $(addprefix $(LOVE_IOS_LIBRARIES_DIR)/, $(LOVE_IOS_LIBRARIES))

SRC_DIR := $(ROOT_DIR)/src
DIST_DIR := $(ROOT_DIR)/dist
ARCHIVE_DIR := $(ROOT_DIR)/archive

SRC_FILES := $(wildcard $(SRC_DIR)/*.lua)
DIST_FILE := $(DIST_DIR)/game.love

WINX86_APP := $(LOVE_WINX86_DIR)/$(GAME_NAME).exe
WINX86_APP_CONSOLE := $(LOVE_WINX86_DIR)/$(GAME_NAME)-console.exe
WINX64_APP := $(LOVE_WINX64_DIR)/$(GAME_NAME).exe
WINX64_APP_CONSOLE := $(LOVE_WINX64_DIR)/$(GAME_NAME)-console.exe
MACOS_APP := $(LOVE_MACOS_DIR)/Build/Products/Release/$(GAME_NAME).app
IOS_APP := $(LOVE_IOS_DIR)/Build/Products/Release-iphonesimulator/$(GAME_NAME).app
ANDROID_APP := $(LOVE_ANDROID_DIR)/app/build/outputs/apk/release/$(GAME_NAME).apk

LINUX_ARCHIVE := $(ARCHIVE_DIR)/$(GAME_NAME)-linux-$(GAME_VERSION).snap
WINX86_ARCHIVE := $(ARCHIVE_DIR)/$(GAME_NAME)-winx86-$(GAME_VERSION).zip
WINX64_ARCHIVE := $(ARCHIVE_DIR)/$(GAME_NAME)-winx64-$(GAME_VERSION).zip
MACOS_ARCHIVE := $(ARCHIVE_DIR)/$(GAME_NAME)-macos-$(GAME_VERSION).zip
IOS_ARCHIVE := $(ARCHIVE_DIR)/$(GAME_NAME)-ios-$(GAME_VERSION).zip
ANDROID_ARCHIVE := $(ARCHIVE_DIR)/$(GAME_NAME)-android-$(GAME_VERSION).apk

# TASKS ========================================================================

.PHONY: \
	clean \
	dist \
	install \
	linux \
	linux-build \
	linux-launch \
	linux-archive \
	winx86 \
	winx86-build \
	winx86-launch \
	winx86-archive \
	winx64 \
	winx64-build \
	winx64-launch \
	winx64-archive \
	macos \
	macos-build \
	macos-launch \
	macos-archive \
	ios \
	ios-build \
	ios-install \
	ios-launch \
	ios-archive \
	android \
	android-build \
	android-install \
	android-launch \
	android-archive

all: dist

## SHARED ======================================================================

$(DIST_DIR):
	mkdir -p "$(DIST_DIR)"

$(ARCHIVE_DIR):
	mkdir -p "$(ARCHIVE_DIR)"

$(LOVE_DIR):
	hg clone $(LOVE_REPOSITORY_URL) -r $(LOVE_VERSION) "$(LOVE_DIR)"

$(LOVE_ANDROID_DIR):
	git clone $(LOVE_ANDROID_REPOSITORY_URL) -b $(basename $(LOVE_VERSION)).x "$(LOVE_ANDROID_DIR)"

## CLEAN =======================================================================

clean:
	rm -fr "$(DIST_DIR)" "$(ARCHIVE_DIR)" "$(LOVE_DIR)" "$(LOVE_ANDROID_DIR)"

## DIST ========================================================================

dist: $(DIST_FILE)

$(DIST_FILE): $(SRC_FILES) | $(DIST_DIR)
	python -c "import shutil; shutil.make_archive('$(DIST_FILE)', 'zip', '$(SRC_DIR)')"
	mv $(DIST_FILE).zip $(DIST_FILE)

## INSTALL =====================================================================

install: $(DIST_FILE)
	cp $(DIST_FILE) $(DESTDIR)

## LINUX =======================================================================

linux: linux-build linux-launch

linux-build: $(LINUX_ARCHIVE)

linux-launch: $(LINUX_ARCHIVE)
	snap install --devmode "$(LINUX_ARCHIVE)"
	snap run $(GAME_NAME)

linux-archive: $(LINUX_ARCHIVE)

$(LINUX_ARCHIVE): $(DIST_FILE) | $(ARCHIVE_DIR)
	snapcraft snap --output $(LINUX_ARCHIVE)
# List dir for debugging.
	ls -al "$(dir $(LINUX_ARCHIVE))"

## WINX86 ======================================================================

winx86: winx86-build winx86-launch

winx86-build: $(WINX86_APP)

winx86-launch: $(WINX86_APP)
	start "$(WINX86_APP)"

winx86-archive: $(WINX86_ARCHIVE)

$(WINX86_APP): $(DIST_FILE) | $(LOVE_DIR)
# Download and extract LÖVE binaries.
	$(eval TMP := C:$(shell mktemp -d))
	mkdir -p "$(TMP)"
	curl -fsSL -o "$(TMP)/$(LOVE_WINX86_APP_ZIP)" "$(LOVE_WINX86_APP_URL)"
	7z e -o"$(TMP)" "$(TMP)/$(LOVE_WINX86_APP_ZIP)"
	rm "$(TMP)/$(LOVE_WINX86_APP_ZIP)"
	mkdir -p "$(LOVE_WINX86_DIR)"
	cp -r "$(TMP)/." "$(LOVE_WINX86_DIR)/"
	rm -fr "$(TMP)"
# Concatenate our game to the main and console binaries.
	cat "$(LOVE_WINX86_DIR)/love.exe" "$(DIST_FILE)" > $(WINX86_APP)
	cat "$(LOVE_WINX86_DIR)/lovec.exe" "$(DIST_FILE)" > $(WINX86_APP_CONSOLE)
# Clean up.
	rm "$(LOVE_WINX86_DIR)/love.exe"
	rm "$(LOVE_WINX86_DIR)/lovec.exe"
# List dir for debugging.
	ls -al "$(dir $(WINX86_APP))"

$(WINX86_ARCHIVE): $(WINX86_APP) | $(ARCHIVE_DIR)
# Zip with Python, as other tools aren't guaranteed to be on all platforms.
	python -c "import shutil; shutil.make_archive('$(basename $(WINX86_ARCHIVE))', 'zip', '$(dir $(WINX86_APP))')"
# List dir for debugging.
	ls -al "$(dir $(WINX86_ARCHIVE))"

## WINX64 ======================================================================

winx64: winx64-build winx64-launch

winx64-build: $(WINX64_APP)

winx64-launch: $(WINX64_APP)
	start "$(WINX64_APP)"

winx64-archive: $(WINX64_ARCHIVE)

$(WINX64_APP): $(DIST_FILE) | $(LOVE_DIR)
# Download and extract LÖVE binaries.
	$(eval TMP := C:$(shell mktemp -d))
	mkdir -p "$(TMP)"
	curl -fsSL -o "$(TMP)/$(LOVE_WINX64_APP_ZIP)" "$(LOVE_WINX64_APP_URL)"
	7z e -o"$(TMP)" "$(TMP)/$(LOVE_WINX64_APP_ZIP)"
	rm "$(TMP)/$(LOVE_WINX64_APP_ZIP)"
	mkdir -p "$(LOVE_WINX64_DIR)"
	cp -r "$(TMP)/." "$(LOVE_WINX64_DIR)/"
	rm -fr "$(TMP)"
# Concatenate our game to the main and console binaries.
	cat "$(LOVE_WINX64_DIR)/love.exe" "$(DIST_FILE)" > $(WINX64_APP)
	cat "$(LOVE_WINX64_DIR)/lovec.exe" "$(DIST_FILE)" > $(WINX64_APP_CONSOLE)
# Clean up.
	rm "$(LOVE_WINX64_DIR)/love.exe"
	rm "$(LOVE_WINX64_DIR)/lovec.exe"
# List dir for debugging.
	ls -al "$(LOVE_WINX64_DIR)"

$(WINX64_ARCHIVE): $(WINX64_APP) | $(ARCHIVE_DIR)
# Zip with Python, as other tools aren't guaranteed to be on all platforms.
	python -c "import shutil; shutil.make_archive('$(basename $(WINX64_ARCHIVE))', 'zip', '$(dir $(WINX64_APP))')"
# List dir for debugging.
	ls -al "$(dir $(WINX64_ARCHIVE))"

## MACOS =======================================================================

macos: macos-build macos-launch

macos-build: $(MACOS_APP)

macos-launch: $(MACOS_APP)
	open "$(MACOS_APP)"

macos-archive: $(MACOS_ARCHIVE)

$(LOVE_MACOS_LIBRARIES): | $(LOVE_DIR)
# Download and extract LÖVE libraries (will probably fail without sudo).
	$(eval TMP := $(shell mktemp -d))
	wget -P "$(TMP)" "$(LOVE_MACOS_LIBRARIES_URL)"
	unzip -d "$(TMP)" "$(TMP)/$(LOVE_MACOS_LIBRARIES_ZIP)"
	sudo cp -r "$(TMP)/$(basename $(LOVE_MACOS_LIBRARIES_ZIP))/." "$(LOVE_MACOS_LIBRARIES_DIR)/"
	rm -fr "$(TMP)"

$(MACOS_APP): $(DIST_FILE) $(LOVE_MACOS_LIBRARIES) | $(LOVE_DIR)
# Ensure our game gets copied during build.
	ruby tasks/xcode/add_resource.rb "$(LOVE_XCODE_DIR)/love.xcodeproj" "$(DIST_FILE)"
# Build LÖVE binaries.
	xcrun xcodebuild \
		-project "$(LOVE_XCODE_DIR)/love.xcodeproj" \
		-scheme love-macosx \
		-configuration Release \
		-derivedDataPath "$(LOVE_MACOS_DIR)/" \
		build
# Rename app.
	mv "$(dir $(MACOS_APP))/love.app" "$(MACOS_APP)"
# List dir for debugging.
	ls -al "$(dir $(MACOS_APP))"

$(MACOS_ARCHIVE): $(MACOS_APP) | $(ARCHIVE_DIR)
# Compress app using `ditto` to get same results as when using Finder.
	ditto -c -k --sequesterRsrc --keepParent "$(MACOS_APP)" "$(MACOS_ARCHIVE)"
# List dir for debugging.
	ls -al "$(dir $(MACOS_ARCHIVE))"

## IOS =========================================================================

ios: ios-build ios-install ios-launch

ios-build: $(IOS_APP)

ios-install: $(IOS_APP)
	xcrun simctl install booted "$(IOS_APP)"

ios-launch: $(IOS_APP)
	$(eval APP_ID := $(shell /usr/libexec/PlistBuddy -c Print:CFBundleIdentifier "$(IOS_APP)/Info.plist"))
	xcrun simctl launch booted $(APP_ID)

ios-archive: $(IOS_ARCHIVE)

$(LOVE_IOS_LIBRARIES): | $(LOVE_DIR)
# Download and extract LÖVE libraries.
	$(eval TMP := $(shell mktemp -d))
	wget -P "$(TMP)" "$(LOVE_IOS_LIBRARIES_URL)"
	unzip -d "$(TMP)" "$(TMP)/$(LOVE_IOS_LIBRARIES_ZIP)"
	cp -r "$(TMP)/$(basename $(LOVE_IOS_LIBRARIES_ZIP))/." "$(LOVE_IOS_LIBRARIES_DIR)/"
	rm -fr "$(TMP)"

$(IOS_APP): $(DIST_FILE) $(LOVE_IOS_LIBRARIES) | $(LOVE_DIR)
# Ensure our game gets copied during build.
	ruby tasks/xcode/add_resource.rb "$(LOVE_XCODE_DIR)/love.xcodeproj" "$(DIST_FILE)"
# Build LÖVE binaries.
	xcrun xcodebuild \
		-project "$(LOVE_XCODE_DIR)/love.xcodeproj" \
		-scheme love-ios \
		-configuration Release \
		-sdk iphonesimulator \
		-derivedDataPath "$(LOVE_IOS_DIR)/" \
		build
# Rename app.
	mv "$(dir $(IOS_APP))/love.app" "$(IOS_APP)"
# List dir for debugging.
	ls -al "$(dir $(IOS_APP))"

$(IOS_ARCHIVE): $(IOS_APP) | $(ARCHIVE_DIR)
# Compress app using `ditto` to get same results as when using Finder.
	ditto -c -k --sequesterRsrc --keepParent "$(IOS_APP)" "$(IOS_ARCHIVE)"
# List dir for debugging.
	ls -al "$(dir $(IOS_ARCHIVE))"

## ANDROID =====================================================================

android: android-build android-install android-launch

android-build: $(ANDROID_APP)

android-install: $(ANDROID_APP)
	adb install "$(ANDROID_APP)"

android-launch: $(ANDROID_APP)
	adb -d install "$(ANDROID_APP)"

android-archive: $(ANDROID_ARCHIVE)

$(ANDROID_APP): $(DIST_FILE) | $(LOVE_ANDROID_DIR)
# Configure SDK and NDK paths.
	echo "sdk.dir=$(ANDROID_HOME)" >> "$(LOVE_ANDROID_DIR)/local.properties"
	echo "ndk.dir=$(ANDROID_NDK_HOME)" >> "$(LOVE_ANDROID_DIR)/local.properties"
# Add missing `google()` repository.
	grep -q 'google' "$(LOVE_ANDROID_DIR)/build.gradle" ||\
		sed -i -e '/jcenter()/a\ \ \ \ \ \ \ \ google()' "$(LOVE_ANDROID_DIR)/build.gradle"
# Copy our game.
	mkdir -p $(LOVE_ANDROID_RES_DIR)
	cp "$(DIST_FILE)" "$(LOVE_ANDROID_RES_DIR)/"
# Build Android binaries.
	(cd "$(LOVE_ANDROID_DIR)" ; ./gradlew build)
# Rename app.
	mv "$(dir $(ANDROID_APP))/app-release-unsigned.apk" "$(ANDROID_APP)"
# List dir for debugging.
	ls -al "$(dir $(ANDROID_APP))"

$(ANDROID_ARCHIVE): $(ANDROID_APP) | $(ARCHIVE_DIR)
# Just copy the file, no need to compress.
	cp "$(ANDROID_APP)" "$(ANDROID_ARCHIVE)"
# List dir for debugging.
	ls -al "$(dir $(ANDROID_ARCHIVE))"
