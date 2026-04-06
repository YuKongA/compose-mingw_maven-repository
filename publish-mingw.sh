#!/bin/bash
# Publish mingwX64 libraries — modular scripts
# Usage: ./publish-mingw.sh [step...]
#   No args    = show help
#   all        = run all steps
#   skiko      = Step 1: Skiko
#   compose    = Steps 2-6: Compose Core (5 batches + redirect)
#   icons      = Step 7: compose-icons-mingw (icons, window-size-class, materialkolor, resources)
#   miuix      = Step 8: miuix
#   sync       = Step 9: Copy to maven-repository
#
# Examples:
#   ./publish-mingw.sh skiko compose sync    # Only rebuild skiko + compose, then sync
#   ./publish-mingw.sh icons miuix sync      # Only rebuild third-party + miuix, then sync
#   ./publish-mingw.sh all                   # Full rebuild

set -e

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
SKIKO_DIR="$(dirname "$REPO_DIR")/skiko/skiko"
COMPOSE_DIR="$(dirname "$REPO_DIR")/compose-multiplatform-core"
ICONS_DIR="$(dirname "$REPO_DIR")/compose-icons-mingw"
MIUIX_DIR="$(dirname "$REPO_DIR")/miuix-mingw"
RELEASES_DIR="$REPO_DIR/repository/releases"

# --- Version detection ---
SKIKO_VERSION=$(grep "^deploy.version=" "$SKIKO_DIR/gradle.properties" 2>/dev/null | cut -d= -f2)
if [ "$SKIKO_VERSION" = "0.0.0" ] || [ -z "$SKIKO_VERSION" ]; then
  SKIKO_VERSION=$(grep "skiko.version=" "$SKIKO_DIR/gradle.properties" 2>/dev/null | cut -d= -f2)
  [ -z "$SKIKO_VERSION" ] && SKIKO_VERSION="0.144.5"
fi

read_toml_version() {
  grep "^$1 = " "$COMPOSE_DIR/libraryversions.toml" | head -1 | sed 's/.*= "\(.*\)"/\1/'
}

VERSION_PROPS="\
  -Pjetbrains.publication.version.COMPOSE=$(read_toml_version COMPOSE) \
  -Pjetbrains.publication.version.COMPOSE_MATERIAL3=$(read_toml_version COMPOSE_MATERIAL3) \
  -Pjetbrains.publication.version.COMPOSE_MATERIAL3_ADAPTIVE=$(read_toml_version COMPOSE_MATERIAL3_ADAPTIVE) \
  -Pjetbrains.publication.version.LIFECYCLE=$(read_toml_version LIFECYCLE) \
  -Pjetbrains.publication.version.NAVIGATION=$(read_toml_version NAVIGATION) \
  -Pjetbrains.publication.version.NAVIGATION_3=$(read_toml_version NAVIGATION3) \
  -Pjetbrains.publication.version.NAVIGATION_EVENT=$(read_toml_version NAVIGATIONEVENT) \
  -Pjetbrains.publication.version.SAVEDSTATE=$(read_toml_version SAVEDSTATE) \
  -Pjetbrains.publication.version.WINDOW=$(read_toml_version WINDOW)"

PLAT="-Pandroidx.enabled.kmp.target.platforms=-js,-wasm,-android_native,-linux,+windows"

# --- Step functions ---

step_skiko() {
  echo "=== Skiko ==="
  cd "$SKIKO_DIR"
  ./gradlew clean \
    -Pskiko.native.windows.enabled=true -Pskiko.awt.enabled=false \
    -Pskia.dir=D:/GitHub/skia \
    -Pdeploy.version=$SKIKO_VERSION -Pdeploy.release=true \
    publishMingwX64PublicationToMavenLocal \
    publishKotlinMultiplatformPublicationToMavenLocal
}

step_compose() {
  echo "=== Compose: batch 1 (base) ==="
  cd "$COMPOSE_DIR"
  ./gradlew --no-configuration-cache $VERSION_PROPS $PLAT \
    :annotation:annotation:publishMingwX64PublicationToMavenLocal \
    :collection:collection:publishMingwX64PublicationToMavenLocal \
    :savedstate:savedstate:publishMingwX64PublicationToMavenLocal \
    :savedstate:savedstate-compose:publishMingwX64PublicationToMavenLocal
  python3 "$COMPOSE_DIR/gen_root_modules.py"

  echo "=== Compose: batch 2 (lifecycle + navigation) ==="
  ./gradlew --no-configuration-cache $VERSION_PROPS $PLAT \
    :lifecycle:lifecycle-common:publishMingwX64PublicationToMavenLocal \
    :lifecycle:lifecycle-runtime:publishMingwX64PublicationToMavenLocal \
    :lifecycle:lifecycle-viewmodel:publishMingwX64PublicationToMavenLocal \
    :lifecycle:lifecycle-viewmodel-savedstate:publishMingwX64PublicationToMavenLocal \
    :lifecycle:lifecycle-runtime-compose:publishMingwX64PublicationToMavenLocal \
    :lifecycle:lifecycle-viewmodel-compose:publishMingwX64PublicationToMavenLocal \
    :navigationevent:navigationevent-compose:publishMingwX64PublicationToMavenLocal
  python3 "$COMPOSE_DIR/gen_root_modules.py"

  echo "=== Compose: batch 3 (compose core) ==="
  ./gradlew --no-configuration-cache $VERSION_PROPS $PLAT \
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

  echo "=== Compose: batch 4 (navigation + material) ==="
  ./gradlew --no-configuration-cache $VERSION_PROPS $PLAT \
    :navigation:navigation-common:publishMingwX64PublicationToMavenLocal \
    :navigation:navigation-runtime:publishMingwX64PublicationToMavenLocal \
    :navigation:navigation-compose:publishMingwX64PublicationToMavenLocal \
    :compose:material:material-ripple:publishMingwX64PublicationToMavenLocal \
    :compose:material3:material3:publishMingwX64PublicationToMavenLocal
  python3 "$COMPOSE_DIR/gen_root_modules.py"

  echo "=== Compose: batch 5 (redirect modules) ==="
  ./gradlew --no-configuration-cache $VERSION_PROPS $PLAT \
    -Pcompose.platforms=mingw :mpp:publishComposeJbToMavenLocal
}

step_icons() {
  echo "=== Third-party libs (compose-icons-mingw) ==="
  cd "$ICONS_DIR"
  ./gradlew publishToMavenLocal
}

step_miuix() {
  echo "=== miuix ==="
  cd "$MIUIX_DIR"
  ./gradlew \
    :miuix-core:publishMingwX64PublicationToMavenLocal \
    :miuix-ui:publishMingwX64PublicationToMavenLocal \
    :miuix-blur:publishMingwX64PublicationToMavenLocal \
    :miuix-preference:publishMingwX64PublicationToMavenLocal \
    :miuix-icons:publishMingwX64PublicationToMavenLocal \
    :miuix-navigation3-ui:publishMingwX64PublicationToMavenLocal \
    :miuix-shapes:publishMingwX64PublicationToMavenLocal \
    :miuix-core:publishKotlinMultiplatformPublicationToMavenLocal \
    :miuix-ui:publishKotlinMultiplatformPublicationToMavenLocal \
    :miuix-blur:publishKotlinMultiplatformPublicationToMavenLocal \
    :miuix-preference:publishKotlinMultiplatformPublicationToMavenLocal \
    :miuix-icons:publishKotlinMultiplatformPublicationToMavenLocal \
    :miuix-navigation3-ui:publishKotlinMultiplatformPublicationToMavenLocal \
    :miuix-shapes:publishKotlinMultiplatformPublicationToMavenLocal
}

step_sync() {
  echo "=== Sync to maven-repository ==="
  rm -rf "$RELEASES_DIR/org/jetbrains"
  mkdir -p "$RELEASES_DIR/org/jetbrains"
  cp -r ~/.m2/repository/org/jetbrains/compose "$RELEASES_DIR/org/jetbrains/"
  cp -r ~/.m2/repository/org/jetbrains/androidx "$RELEASES_DIR/org/jetbrains/"
  cp -r ~/.m2/repository/org/jetbrains/skiko "$RELEASES_DIR/org/jetbrains/"

  mkdir -p "$RELEASES_DIR/com/materialkolor"
  cp -r ~/.m2/repository/com/materialkolor/material-color-utilities-mingwx64 "$RELEASES_DIR/com/materialkolor/"

  mkdir -p "$RELEASES_DIR/top/yukonga"
  cp -r ~/.m2/repository/top/yukonga/miuix "$RELEASES_DIR/top/yukonga/"

  echo "Synced to $RELEASES_DIR"
}

# --- Main ---

if [ $# -eq 0 ]; then
  echo "Usage: ./publish-mingw.sh [step...]"
  echo "  all     = full rebuild"
  echo "  skiko   = Skiko only"
  echo "  compose = Compose Core (5 batches)"
  echo "  icons   = Third-party libs (icons, window-size-class, materialkolor, resources)"
  echo "  miuix   = miuix library"
  echo "  sync    = Copy to maven-repository"
  echo ""
  echo "Examples:"
  echo "  ./publish-mingw.sh skiko compose sync"
  echo "  ./publish-mingw.sh icons miuix sync"
  echo "  ./publish-mingw.sh all"
  exit 0
fi

for step in "$@"; do
  case "$step" in
    all)    step_skiko; step_compose; step_icons; step_miuix; step_sync ;;
    skiko)  step_skiko ;;
    compose) step_compose ;;
    icons)  step_icons ;;
    miuix)  step_miuix ;;
    sync)   step_sync ;;
    *)      echo "Unknown step: $step"; exit 1 ;;
  esac
done

echo "=== Done! ==="
