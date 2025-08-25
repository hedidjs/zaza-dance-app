#!/bin/bash

# 🚀 Zaza Dance - Quick Development Script
# רץ את האפליקציה עם הגדרות אופטימליות לפיתוח

set -e

echo "🔥 זזה דאנס - פיתוח מהיר"
echo "=========================="

# Function to check if simulator is running
check_simulator() {
    if xcrun simctl list devices | grep -q "Booted"; then
        echo "✅ iOS Simulator is running"
        return 0
    else
        echo "📱 Starting iOS Simulator..."
        open -a Simulator
        sleep 3
        return 1
    fi
}

# Function to run Flutter with best settings for hot reload
run_flutter() {
    echo "🚀 Starting Flutter with hot reload..."
    
    # Clean build first (this helps with hot reload issues)
    flutter clean > /dev/null 2>&1
    flutter pub get > /dev/null 2>&1
    
    # Run with optimized settings
    flutter run \
        --debug \
        --hot \
        --dart-define=flutter.inspector.structuredErrors=false \
        --disable-service-auth-codes \
        --enable-software-rendering \
        --start-paused=false
}

# Main execution
echo "🔍 Checking devices..."
flutter devices

echo ""
echo "🎯 Tips for better hot reload:"
echo "   • Save files to trigger hot reload"
echo "   • Press 'r' for hot reload"
echo "   • Press 'R' for hot restart (if reload fails)"
echo "   • Press 'q' to quit"
echo ""

# Check for simulator
check_simulator

# Start the app
run_flutter