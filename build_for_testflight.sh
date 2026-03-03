#!/bin/bash

# CipherForge TestFlight Build Script
# This script automates building and preparing your app for TestFlight

set -e  # Exit on error

echo "🚀 CipherForge TestFlight Build Script"
echo "======================================="
echo ""

# Fix xcode-select path if needed
echo "🔧 Checking Xcode configuration..."
if xcode-select -p 2>/dev/null | grep -q "CommandLineTools"; then
    echo "⚠️  Switching to Xcode (requires password)..."
    sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
    echo "✅ Xcode path updated"
fi
echo ""

# Configuration
PROJECT_PATH="/Users/curtiswyatt/AustinCipher/CipherForge.xcodeproj"
SCHEME="CipherForge"
CONFIGURATION="Release"
ARCHIVE_PATH="/Users/curtiswyatt/AustinCipher/build/CipherForge.xcarchive"
EXPORT_PATH="/Users/curtiswyatt/AustinCipher/build/export"
BUILD_DIR="/Users/curtiswyatt/AustinCipher/build"

# Create build directory
mkdir -p "$BUILD_DIR"

# Step 1: Clean build folder
echo "🧹 Cleaning build folder..."
rm -rf "$BUILD_DIR"/*
xcodebuild clean -project "$PROJECT_PATH" -scheme "$SCHEME" -configuration "$CONFIGURATION"

# Step 2: Create archive
echo ""
echo "📦 Creating archive (this may take 2-5 minutes)..."
xcodebuild archive \
  -project "$PROJECT_PATH" \
  -scheme "$SCHEME" \
  -configuration "$CONFIGURATION" \
  -archivePath "$ARCHIVE_PATH" \
  -destination 'generic/platform=iOS' \
  CODE_SIGN_IDENTITY="Apple Development" \
  DEVELOPMENT_TEAM="" \
  | grep -E "^(===|Build|Archive)" || true

if [ ! -d "$ARCHIVE_PATH" ]; then
    echo "❌ Archive failed!"
    echo ""
    echo "Common fixes:"
    echo "1. Open Xcode and go to Preferences → Accounts"
    echo "2. Sign in with your Apple Developer account"
    echo "3. Run this script again"
    exit 1
fi

echo "✅ Archive created successfully!"

# Step 3: Create ExportOptions.plist
echo ""
echo "📝 Creating export configuration..."
cat > "$BUILD_DIR/ExportOptions.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>app-store</string>
    <key>uploadSymbols</key>
    <true/>
    <key>uploadBitcode</key>
    <false/>
    <key>compileBitcode</key>
    <false/>
    <key>manageAppVersionAndBuildNumber</key>
    <true/>
</dict>
</plist>
EOF

# Step 4: Export archive
echo ""
echo "📤 Exporting for App Store..."
xcodebuild -exportArchive \
  -archivePath "$ARCHIVE_PATH" \
  -exportPath "$EXPORT_PATH" \
  -exportOptionsPlist "$BUILD_DIR/ExportOptions.plist" \
  | grep -E "^(===|Export)" || true

if [ ! -f "$EXPORT_PATH/CipherForge.ipa" ]; then
    echo "❌ Export failed!"
    echo ""
    echo "This usually means you need to configure signing in Xcode:"
    echo "1. Open CipherForge.xcodeproj in Xcode"
    echo "2. Select CipherForge target → Signing & Capabilities"
    echo "3. Check 'Automatically manage signing'"
    echo "4. Select your Team"
    echo "5. Run this script again"
    exit 1
fi

echo "✅ Export successful!"

# Step 5: Upload instructions
echo ""
echo "🎉 Build complete!"
echo "=================="
echo ""
echo "Your IPA is ready at:"
echo "$EXPORT_PATH/CipherForge.ipa"
echo ""
echo "NEXT STEPS:"
echo "----------"
echo "Option 1 - Upload via Xcode (Easiest):"
echo "  1. Open Xcode → Window → Organizer"
echo "  2. Select 'Archives' tab"
echo "  3. Select your CipherForge archive"
echo "  4. Click 'Distribute App'"
echo "  5. Choose 'App Store Connect' → Upload"
echo ""
echo "Option 2 - Upload via Command Line:"
echo "  Run: xcrun altool --upload-app -f \"$EXPORT_PATH/CipherForge.ipa\" \\"
echo "       --type ios -u YOUR_APPLE_ID -p YOUR_APP_SPECIFIC_PASSWORD"
echo ""
echo "Option 3 - Upload via Transporter app:"
echo "  1. Download 'Transporter' from Mac App Store"
echo "  2. Drag your IPA file into Transporter"
echo "  3. Click 'Deliver'"
echo ""
