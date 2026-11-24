#!/usr/bin/env bash
set -e

echo "=== 1. Setting up Flutter on Render ==="
if [ ! -d "flutter" ]; then
  git clone https://github.com/flutter/flutter.git -b stable --depth 1 flutter
fi

export PATH="$PATH:$PWD/flutter/bin"

echo "=== 2. Verifying Flutter Environment ==="
flutter --version

echo "=== 3. Getting Dependencies ==="
flutter pub get

echo "=== 4. Building Flutter Web Release ==="
flutter build web --release

echo "=== 5. Web Build Finished Successfully ==="
