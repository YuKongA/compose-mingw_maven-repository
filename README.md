# Compose Multiplatform mingwX64 Maven Repository

Pre-built Compose Multiplatform libraries for the `mingwX64` (Windows Kotlin/Native) target.

## Usage

Add this repository to your `settings.gradle.kts`:

```kotlin
dependencyResolutionManagement {
    repositories {
        maven {
            setUrl("https://raw.githubusercontent.com/YuKongA/compose-mingw_maven-repository/main/repository/releases")
        }
    }
}
```

## Available Libraries

### Skiko

| Artifact | Version |
|----------|---------|
| org.jetbrains.skiko:skiko | 0.144.5 |

### Compose Core

| Artifact | Version |
|----------|---------|
| org.jetbrains.compose.runtime:runtime | 1.11.0-alpha04 |
| org.jetbrains.compose.runtime:runtime-saveable | 1.11.0-alpha04 |
| org.jetbrains.compose.ui:ui | 1.11.0-alpha04 |
| org.jetbrains.compose.ui:ui-geometry | 1.11.0-alpha04 |
| org.jetbrains.compose.ui:ui-unit | 1.11.0-alpha04 |
| org.jetbrains.compose.ui:ui-util | 1.11.0-alpha04 |
| org.jetbrains.compose.ui:ui-graphics | 1.11.0-alpha04 |
| org.jetbrains.compose.ui:ui-text | 1.11.0-alpha04 |
| org.jetbrains.compose.ui:ui-backhandler | 1.11.0-alpha04 |
| org.jetbrains.compose.animation:animation | 1.11.0-alpha04 |
| org.jetbrains.compose.animation:animation-core | 1.11.0-alpha04 |
| org.jetbrains.compose.foundation:foundation | 1.11.0-alpha04 |
| org.jetbrains.compose.foundation:foundation-layout | 1.11.0-alpha04 |
| org.jetbrains.compose.material:material-ripple | 1.11.0-alpha04 |

### Material3

| Artifact | Version |
|----------|---------|
| org.jetbrains.compose.material3:material3 | 1.5.0-alpha13 |
| org.jetbrains.compose.material3:material3-window-size-class | 1.9.0 |

### Material Icons

| Artifact | Version |
|----------|---------|
| org.jetbrains.compose.material:material-icons-core | 1.7.3 |
| org.jetbrains.compose.material:material-icons-extended | 1.7.3 |

### Lifecycle

| Artifact | Version |
|----------|---------|
| org.jetbrains.androidx.lifecycle:lifecycle-common | 2.11.0-alpha01 |
| org.jetbrains.androidx.lifecycle:lifecycle-runtime | 2.11.0-alpha01 |
| org.jetbrains.androidx.lifecycle:lifecycle-runtime-compose | 2.11.0-alpha01 |
| org.jetbrains.androidx.lifecycle:lifecycle-viewmodel | 2.11.0-alpha01 |
| org.jetbrains.androidx.lifecycle:lifecycle-viewmodel-compose | 2.11.0-alpha01 |
| org.jetbrains.androidx.lifecycle:lifecycle-viewmodel-savedstate | 2.11.0-alpha01 |

### Navigation

| Artifact | Version |
|----------|---------|
| org.jetbrains.androidx.navigation:navigation-common | 2.10.0-alpha01 |
| org.jetbrains.androidx.navigation:navigation-runtime | 2.10.0-alpha01 |
| org.jetbrains.androidx.navigation:navigation-compose | 2.10.0-alpha01 |
| org.jetbrains.androidx.navigationevent:navigationevent-compose | 1.1.0-alpha01 |

### SavedState

| Artifact | Version |
|----------|---------|
| org.jetbrains.androidx.savedstate:savedstate | 1.5.0-alpha01 |
| org.jetbrains.androidx.savedstate:savedstate-compose | 1.5.0-alpha01 |

### Resources

| Artifact | Version |
|----------|---------|
| org.jetbrains.compose.components:components-resources | 1.11.0-alpha04 |
| org.jetbrains.compose.annotation-internal:annotation | 1.11.0-alpha04 |
| org.jetbrains.compose.collection-internal:collection | 1.11.0-alpha04 |

### Third-party

| Artifact | Version |
|----------|---------|
| com.materialkolor:material-color-utilities | 4.1.1 |
| top.yukonga.miuix.kmp:miuix-core | 0.9.0-f912a51a-SNAPSHOT |
| top.yukonga.miuix.kmp:miuix-ui | 0.9.0-f912a51a-SNAPSHOT |
| top.yukonga.miuix.kmp:miuix-blur | 0.9.0-f912a51a-SNAPSHOT |
| top.yukonga.miuix.kmp:miuix-preference | 0.9.0-f912a51a-SNAPSHOT |
| top.yukonga.miuix.kmp:miuix-icons | 0.9.0-f912a51a-SNAPSHOT |
| top.yukonga.miuix.kmp:miuix-navigation3-ui | 0.9.0-f912a51a-SNAPSHOT |
| top.yukonga.miuix.kmp:miuix-shapes | 0.9.0-f912a51a-SNAPSHOT |

## Why This Repository

Maven Central and JetBrains repositories don't publish `mingwX64` artifacts for Compose Multiplatform. This repository fills the gap by providing pre-built `.klib` packages for the Windows Kotlin/Native target.

## Related Projects

- [skiko](https://github.com/YuKongA/skiko) - Skia bindings with mingwX64 + ANGLE support
- [miuix-mingw](https://github.com/YuKongA/miuix-mingw) - miuix UI library for mingwX64
