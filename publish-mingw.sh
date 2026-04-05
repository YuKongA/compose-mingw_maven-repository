#!/bin/bash
# Publish all mingwX64 libraries to the local maven repository
# Usage: ./publish-mingw.sh
# Prerequisites: w64devkit in PATH, Android SDK configured

set -e

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
SKIKO_DIR="$(dirname "$REPO_DIR")/skiko/skiko"
COMPOSE_DIR="$(dirname "$REPO_DIR")/compose-multiplatform-core"

# Read versions from project files
SKIKO_VERSION=$(grep "^deploy.version=" "$SKIKO_DIR/gradle.properties" | cut -d= -f2)
if [ "$SKIKO_VERSION" = "0.0.0" ]; then
  # Default dev version, use the one from skiko build
  SKIKO_VERSION=$(grep "skiko.version=" "$SKIKO_DIR/gradle.properties" 2>/dev/null | cut -d= -f2 || echo "0.144.5")
fi

# Read compose versions from libraryversions.toml
read_toml_version() {
  grep "^$1 = " "$COMPOSE_DIR/libraryversions.toml" | head -1 | sed 's/.*= "\(.*\)"/\1/'
}

COMPOSE_VERSION=$(read_toml_version "COMPOSE")
MATERIAL3_VERSION=$(read_toml_version "COMPOSE_MATERIAL3")
MATERIAL3_ADAPTIVE_VERSION=$(read_toml_version "COMPOSE_MATERIAL3_ADAPTIVE")
LIFECYCLE_VERSION=$(read_toml_version "LIFECYCLE")
NAVIGATION_VERSION=$(read_toml_version "NAVIGATION")
NAVIGATION3_VERSION=$(read_toml_version "NAVIGATION3")
NAVIGATIONEVENT_VERSION=$(read_toml_version "NAVIGATIONEVENT")
SAVEDSTATE_VERSION=$(read_toml_version "SAVEDSTATE")
WINDOW_VERSION=$(read_toml_version "WINDOW")

echo "=== Versions ==="
echo "Skiko: $SKIKO_VERSION"
echo "Compose: $COMPOSE_VERSION"
echo "Material3: $MATERIAL3_VERSION"
echo "Lifecycle: $LIFECYCLE_VERSION"
echo "Navigation: $NAVIGATION_VERSION"
echo "SavedState: $SAVEDSTATE_VERSION"

VERSION_PROPS="\
  -Pjetbrains.publication.version.COMPOSE=$COMPOSE_VERSION \
  -Pjetbrains.publication.version.COMPOSE_MATERIAL3=$MATERIAL3_VERSION \
  -Pjetbrains.publication.version.COMPOSE_MATERIAL3_ADAPTIVE=$MATERIAL3_ADAPTIVE_VERSION \
  -Pjetbrains.publication.version.LIFECYCLE=$LIFECYCLE_VERSION \
  -Pjetbrains.publication.version.NAVIGATION=$NAVIGATION_VERSION \
  -Pjetbrains.publication.version.NAVIGATION_3=$NAVIGATION3_VERSION \
  -Pjetbrains.publication.version.NAVIGATION_EVENT=$NAVIGATIONEVENT_VERSION \
  -Pjetbrains.publication.version.SAVEDSTATE=$SAVEDSTATE_VERSION \
  -Pjetbrains.publication.version.WINDOW=$WINDOW_VERSION"

PLAT="-Pandroidx.enabled.kmp.target.platforms=-js,-wasm,-android_native,-linux,+windows"

echo "=== Step 1: Publish Skiko mingwX64 ==="
cd "$SKIKO_DIR"
./gradlew --no-daemon \
  -Pskiko.native.windows.enabled=true \
  -Pskiko.awt.enabled=false \
  -Pskia.github.repo=YuKongA/skia \
  -Pdeploy.version=$SKIKO_VERSION -Pdeploy.release=true \
  publishMingwX64PublicationToMavenLocal \
  publishKotlinMultiplatformPublicationToMavenLocal

echo "=== Step 2: Publish Compose base modules ==="
cd "$COMPOSE_DIR"

./gradlew --no-daemon --no-configuration-cache $VERSION_PROPS $PLAT \
  :annotation:annotation:publishMingwX64PublicationToMavenLocal \
  :collection:collection:publishMingwX64PublicationToMavenLocal \
  :savedstate:savedstate:publishMingwX64PublicationToMavenLocal \
  :savedstate:savedstate-compose:publishMingwX64PublicationToMavenLocal

python3 "$COMPOSE_DIR/gen_root_modules.py"

echo "=== Step 3: Publish lifecycle + navigation ==="
./gradlew --no-daemon --no-configuration-cache $VERSION_PROPS $PLAT \
  :lifecycle:lifecycle-common:publishMingwX64PublicationToMavenLocal \
  :lifecycle:lifecycle-runtime:publishMingwX64PublicationToMavenLocal \
  :lifecycle:lifecycle-viewmodel:publishMingwX64PublicationToMavenLocal \
  :lifecycle:lifecycle-viewmodel-savedstate:publishMingwX64PublicationToMavenLocal \
  :lifecycle:lifecycle-runtime-compose:publishMingwX64PublicationToMavenLocal \
  :lifecycle:lifecycle-viewmodel-compose:publishMingwX64PublicationToMavenLocal \
  :navigationevent:navigationevent-compose:publishMingwX64PublicationToMavenLocal

python3 "$COMPOSE_DIR/gen_root_modules.py"

echo "=== Step 4: Publish compose core ==="
./gradlew --no-daemon --no-configuration-cache $VERSION_PROPS $PLAT \
  :compose:runtime:runtime:publishMingwX64PublicationToMavenLocal \
  :compose:runtime:runtime-saveable:publishMingwX64PublicationToMavenLocal \
  :compose:ui:ui-util:publishMingwX64PublicationToMavenLocal \
  :compose:ui:ui-geometry:publishMingwX64PublicationToMavenLocal \
  :compose:ui:ui-unit:publishMingwX64PublicationToMavenLocal \
  :compose:ui:ui-graphics:publishMingwX64PublicationToMavenLocal \
  :compose:ui:ui-text:publishMingwX64PublicationToMavenLocal \
  :compose:ui:ui-backhandler:publishMingwX64PublicationToMavenLocal \
  :compose:ui:ui:publishMingwX64PublicationToMavenLocal \
  :compose:animation:animation-core:publishMingwX64PublicationToMavenLocal \
  :compose:animation:animation:publishMingwX64PublicationToMavenLocal \
  :compose:foundation:foundation-layout:publishMingwX64PublicationToMavenLocal \
  :compose:foundation:foundation:publishMingwX64PublicationToMavenLocal

python3 "$COMPOSE_DIR/gen_root_modules.py"

echo "=== Step 5: Publish navigation + material ==="
./gradlew --no-daemon --no-configuration-cache $VERSION_PROPS $PLAT \
  :navigation:navigation-common:publishMingwX64PublicationToMavenLocal \
  :navigation:navigation-runtime:publishMingwX64PublicationToMavenLocal \
  :navigation:navigation-compose:publishMingwX64PublicationToMavenLocal \
  :compose:material:material-ripple:publishMingwX64PublicationToMavenLocal \
  :compose:material3:material3:publishMingwX64PublicationToMavenLocal

python3 "$COMPOSE_DIR/gen_root_modules.py"

echo "=== Step 6: Run publishComposeJbToMavenLocal ==="
./gradlew --no-daemon --no-configuration-cache $VERSION_PROPS $PLAT \
  -Pcompose.platforms=mingw \
  :mpp:publishComposeJbToMavenLocal

echo "=== Step 7: Copy to maven-repository ==="
RELEASES_DIR="$REPO_DIR/repository/releases"
rm -rf "$RELEASES_DIR/org/jetbrains"
mkdir -p "$RELEASES_DIR/org/jetbrains"
cp -r ~/.m2/repository/org/jetbrains/compose "$RELEASES_DIR/org/jetbrains/"
cp -r ~/.m2/repository/org/jetbrains/androidx "$RELEASES_DIR/org/jetbrains/"
cp -r ~/.m2/repository/org/jetbrains/skiko "$RELEASES_DIR/org/jetbrains/"

echo "=== Done! ==="
echo "Published to $RELEASES_DIR"
echo "Use: maven(\"https://raw.githubusercontent.com/YuKongA/maven-repository/main/repository/releases\")"
