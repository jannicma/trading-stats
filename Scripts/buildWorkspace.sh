#!/bin/bash
set -e

# always resolve to repo root (one folder above where this script lives)
cd "$(dirname "$0")/.."

xcodebuild -workspace Atlas.xcworkspace \
           -scheme AtlasDesk \
           -configuration Debug \
           -sdk macosx \
           -derivedDataPath build
