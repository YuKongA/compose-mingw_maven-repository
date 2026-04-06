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

| Group | Artifact | Version |
|-------|----------|---------|
| org.jetbrains.skiko | skiko-mingwx64 | 0.144.5 |
| org.jetbrains.compose.* | runtime, ui, foundation, animation, material3... | 1.11.0-alpha04 |
| org.jetbrains.androidx.* | lifecycle, navigation, savedstate | See below |
| top.yukonga.miuix.kmp | miuix-*-mingwx64 | 0.9.0-SNAPSHOT |
| com.materialkolor | material-color-utilities-mingwx64 | 4.1.1 |

## Why This Repository

Maven Central and JetBrains repositories don't publish `mingwX64` artifacts for Compose Multiplatform. This repository fills the gap by providing pre-built `.klib` packages for the Windows Kotlin/Native target.

## Related Projects

- [skiko](https://github.com/YuKongA/skiko) - Skia bindings with mingwX64 + ANGLE support
- [miuix-mingw](https://github.com/YuKongA/miuix-mingw) - miuix UI library for mingwX64
