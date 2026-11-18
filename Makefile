APP_NAME = LumnApp
BUNDLE_NAME = $(APP_NAME).app
CONTENTS_DIR = $(BUNDLE_NAME)/Contents
MACOS_DIR = $(CONTENTS_DIR)/MacOS
RESOURCES_DIR = $(CONTENTS_DIR)/Resources
EXEC_NAME = $(APP_NAME)
INFO_PLIST = Info.plist
SWIFT_FILES = $(shell find Sources -name "*.swift")
SWIFTC = swiftc
SWIFTC_FLAGS = -O -parse-as-library

.PHONY: all build clean

all: build

build: $(BUNDLE_NAME)

$(BUNDLE_NAME): $(MACOS_DIR)/$(EXEC_NAME)
	@if [ -f "$(INFO_PLIST)" ]; then \
		mkdir -p $(CONTENTS_DIR); \
		cp $(INFO_PLIST) $(CONTENTS_DIR)/; \
		echo "Copied Info.plist."; \
	else \
		echo "Warning: $(INFO_PLIST) not found (Security agent expected to generate it)."; \
	fi
	@echo "Build complete: $(BUNDLE_NAME)"

$(MACOS_DIR)/$(EXEC_NAME): $(SWIFT_FILES)
	@mkdir -p $(MACOS_DIR)
	@echo "Compiling swift files..."
	$(SWIFTC) $(SWIFTC_FLAGS) $(SWIFT_FILES) -o $@

clean:
	rm -rf $(BUNDLE_NAME)
