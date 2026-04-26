APP_NAME = MySlintApp
APP_VERSION = 1.0.0
COMPANY_NAME = "Vinicius Costa"

ifeq ($(OS),Windows_NT)
    DETECTED_OS := Windows
    RAW_ARCH := $(PROCESSOR_ARCHITECTURE)
else
    DETECTED_OS := $(shell uname -s)
    RAW_ARCH := $(shell uname -m)
endif

ifeq ($(RAW_ARCH),x86_64)
    ARCH := x86
else ifeq ($(RAW_ARCH),AMD64)
    ARCH := x86
else ifeq ($(RAW_ARCH),arm64)
    ifeq ($(DETECTED_OS),Darwin)
        ARCH := aarch64
    else
        ARCH := arm64
    endif
else ifeq ($(RAW_ARCH),aarch64)
    ARCH := aarch64
else
    ARCH := $(RAW_ARCH)
endif

NUITKA_BASE_FLAGS = --assume-yes-for-downloads --standalone --onefile --include-data-dir=src/ui=ui --output-dir=dist

ifeq ($(DETECTED_OS),Darwin)
    TARGET_FILE = $(APP_NAME)-v$(APP_VERSION)-$(ARCH).dmg
    NUITKA_FLAGS = --standalone --include-data-dir=src/ui=ui --output-dir=dist \
        --macos-create-app-bundle \
        --macos-app-name="$(APP_NAME)" \
        --macos-app-version="$(APP_VERSION)" \
        --output-filename="$(APP_NAME)"
    # Command to generate the DMG after the bundle
    POST_BUILD_CMD = @if [ -d "dist/$(APP_NAME).app" ]; then hdiutil create -volname "$(APP_NAME)" -srcfolder "dist/$(APP_NAME).app" -ov -format UDZO "dist/$(TARGET_FILE)"; fi
else ifeq ($(DETECTED_OS),Linux)
    TARGET_FILE = $(APP_NAME)-v$(APP_VERSION)-$(ARCH).bin
    NUITKA_FLAGS = $(NUITKA_BASE_FLAGS) --output-filename="$(TARGET_FILE)"
    POST_BUILD_CMD = @echo "Linux build complete: $(TARGET_FILE)"
else
    TARGET_FILE = $(APP_NAME)-v$(APP_VERSION)-$(ARCH).exe
    NUITKA_FLAGS = $(NUITKA_BASE_FLAGS) \
        --windows-product-name="$(APP_NAME)" \
        --windows-product-version="$(APP_VERSION)" \
        --windows-company-name="$(COMPANY_NAME)" \
        --output-filename="$(TARGET_FILE)"
    POST_BUILD_CMD = @echo "Windows build complete: $(TARGET_FILE)"
endif

PYTHON = python
PIP = pip

.PHONY: info install dev build clean

info:
	@echo "--- Build Info ---"
	@echo "App: $(APP_NAME) v$(APP_VERSION)"
	@echo "OS: $(DETECTED_OS)"
	@echo "Architecture: $(ARCH)"
	@echo "Target File: $(TARGET_FILE)"
	@echo "------------------"

install:
	$(PIP) install --upgrade pip
	$(PIP) install -r requirements.txt

dev:
	$(PYTHON) src/main.py

build: info
	$(PYTHON) -m nuitka $(NUITKA_FLAGS) src/main.py
	$(POST_BUILD_CMD)

clean:
	rm -rf dist build
