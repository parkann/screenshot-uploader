#!/bin/bash

# Quick Snip Uploader - Build Script
# This script builds the macOS app from source

set -e  # Exit on error

echo "🚀 Quick Snip Uploader - Build Script"
echo "======================================"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if we're on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo -e "${RED}❌ Error: This app can only be built on macOS${NC}"
    exit 1
fi

# Check if Swift is installed
if ! command -v swift &> /dev/null; then
    echo -e "${RED}❌ Error: Swift is not installed${NC}"
    echo "Please install Xcode from the App Store"
    exit 1
fi

# Check Swift version
SWIFT_VERSION=$(swift --version | head -n 1)
echo -e "${BLUE}ℹ️  $SWIFT_VERSION${NC}"
echo ""

# Build configuration
BUILD_CONFIG="${1:-release}"  # Default to release, or use first argument

if [[ "$BUILD_CONFIG" != "debug" && "$BUILD_CONFIG" != "release" ]]; then
    echo -e "${YELLOW}⚠️  Invalid build configuration: $BUILD_CONFIG${NC}"
    echo "Usage: ./build.sh [debug|release]"
    exit 1
fi

echo -e "${BLUE}🔨 Building in $BUILD_CONFIG mode...${NC}"
echo ""

# Clean previous builds (optional)
if [[ "$2" == "clean" ]]; then
    echo -e "${YELLOW}🧹 Cleaning previous builds...${NC}"
    swift package clean
    echo ""
fi

# Build the project
swift build -c $BUILD_CONFIG

if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}✅ Build successful!${NC}"
    echo ""

    # Show the executable location
    if [[ "$BUILD_CONFIG" == "release" ]]; then
        EXECUTABLE_PATH=".build/release/QuickSnipUploader"
    else
        EXECUTABLE_PATH=".build/debug/QuickSnipUploader"
    fi

    echo -e "${GREEN}📦 Executable location:${NC}"
    echo "   $EXECUTABLE_PATH"
    echo ""

    # Offer to run the app
    echo -e "${BLUE}To run the app:${NC}"
    echo "   $EXECUTABLE_PATH"
    echo ""
    echo -e "${BLUE}Or use:${NC}"
    echo "   swift run"
    echo ""

    # Check if we want to create an app bundle
    read -p "Would you like to create a macOS app bundle? (y/n) " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo ""
        echo -e "${BLUE}📱 Creating app bundle...${NC}"

        APP_NAME="Quick Snip Uploader"
        APP_BUNDLE="$APP_NAME.app"

        # Create app bundle structure
        mkdir -p "$APP_BUNDLE/Contents/MacOS"
        mkdir -p "$APP_BUNDLE/Contents/Resources"

        # Copy executable
        cp "$EXECUTABLE_PATH" "$APP_BUNDLE/Contents/MacOS/QuickSnipUploader"

        # Copy Info.plist
        cp Info.plist "$APP_BUNDLE/Contents/Info.plist"

        # Make executable
        chmod +x "$APP_BUNDLE/Contents/MacOS/QuickSnipUploader"

        echo -e "${GREEN}✅ App bundle created: $APP_BUNDLE${NC}"
        echo ""
        echo -e "${BLUE}To install:${NC}"
        echo "   mv \"$APP_BUNDLE\" /Applications/"
        echo ""
        echo -e "${BLUE}To run:${NC}"
        echo "   open \"$APP_BUNDLE\""
        echo ""
    fi

else
    echo ""
    echo -e "${RED}❌ Build failed${NC}"
    exit 1
fi
