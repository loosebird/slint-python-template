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
    ARCH := x64
else ifeq ($(RAW_ARCH),AMD64)
    ARCH := x64
else ifeq ($(RAW_ARCH),arm64)
    ARCH := arm64
else ifeq ($(RAW_ARCH),aarch64)
    ARCH := arm64
else
    ARCH := $(RAW_ARCH)
endif

# Variável unificada e posicionada ANTES das condições
NUITKA_BASE_FLAGS = --assume-yes-for-downloads --standalone --onefile --include-data-dir=src/ui=ui --output-dir=dist

ifeq ($(DETECTED_OS),Darwin)
    NUITKA_FLAGS = --standalone --include-data-dir=src/ui=ui --output-dir=dist \
        --macos-create-app-bundle \
        --macos-app-name="$(APP_NAME)" \
        --macos-app-version="$(APP_VERSION)" \
        --output-filename="$(APP_NAME)"
    POST_BUILD_CMD = @if [ -d "dist/main.app" ]; then mv dist/main.app dist/"$(APP_NAME).app"; fi
else ifeq ($(DETECTED_OS),Linux)
    TARGET_FILE = $(APP_NAME)-$(APP_VERSION)-$(ARCH).bin
    NUITKA_FLAGS = $(NUITKA_BASE_FLAGS) --output-filename="$(TARGET_FILE)"
    POST_BUILD_CMD = @echo ""
else
    TARGET_FILE = $(APP_NAME)-$(APP_VERSION)-$(ARCH).exe
    NUITKA_FLAGS = $(NUITKA_BASE_FLAGS) \
        --windows-product-name="$(APP_NAME)" \
        --windows-product-version="$(APP_VERSION)" \
        --windows-company-name="$(COMPANY_NAME)" \
        --output-filename="$(TARGET_FILE)"
    POST_BUILD_CMD = @echo ""
endif

PYTHON = venv/bin/python
PIP = venv/bin/pip

.PHONY: info install dev build preview clean

info:
	@echo "--- Build Information ---"
	@echo "App: $(APP_NAME) v$(APP_VERSION)"
	@echo "Detected OS: $(DETECTED_OS)"
	@echo "Architecture: $(ARCH)"
	@echo "-------------------------"

install:
	$(PIP) install --upgrade pip
	$(PIP) install -r requirements.txt

dev:
	$(PYTHON) src/main.py

build: info
	@echo "Starting cross-platform build with Nuitka..."
	$(PYTHON) -m nuitka $(NUITKA_FLAGS) src/main.py
	$(POST_BUILD_CMD)
	@echo "Build complete! Check the 'dist/' folder."

preview:
	@echo "Running compiled binary..."
ifeq ($(DETECTED_OS),Darwin)
	@echo "Opening macOS App Bundle..."
	open "dist/$(APP_NAME).app"
else
	@echo "Running binary..."
	./dist/$(TARGET_FILE)
endif

clean:
	rm -rf dist/ build/ __pycache__/ src/__pycache__/ src/core/__pycache__/
	@echo "Temporary files removed."
