"""Update README.md version numbers from published artifacts."""
import os, re, sys

def get_version(releases_dir, *path_parts):
    """Get the latest version directory name for an artifact."""
    artifact_dir = os.path.join(releases_dir, *path_parts)
    if not os.path.isdir(artifact_dir):
        return None
    versions = [d for d in os.listdir(artifact_dir) if not d.startswith("maven-metadata")]
    return versions[-1] if versions else None

def main():
    releases_dir = sys.argv[1]
    readme_path = sys.argv[2]

    # Detect versions from published artifacts
    versions = {
        "skiko": get_version(releases_dir, "org/jetbrains/skiko/skiko-mingwx64"),
        "compose": get_version(releases_dir, "org/jetbrains/compose/runtime/runtime-mingwx64"),
        "material3": get_version(releases_dir, "org/jetbrains/compose/material3/material3-mingwx64"),
        "icons_core": get_version(releases_dir, "org/jetbrains/compose/material/material-icons-core-mingwx64"),
        "window_size": get_version(releases_dir, "org/jetbrains/compose/material3/material3-window-size-class-mingwx64"),
        "lifecycle": get_version(releases_dir, "org/jetbrains/androidx/lifecycle/lifecycle-common-mingwx64"),
        "navigation": get_version(releases_dir, "org/jetbrains/androidx/navigation/navigation-common-mingwx64"),
        "nav_event": get_version(releases_dir, "org/jetbrains/androidx/navigationevent/navigationevent-compose-mingwx64"),
        "savedstate": get_version(releases_dir, "org/jetbrains/androidx/savedstate/savedstate-mingwx64"),
        "materialkolor": get_version(releases_dir, "com/materialkolor/material-color-utilities-mingwx64"),
        "miuix": get_version(releases_dir, "top/yukonga/miuix/kmp/miuix-core-mingwx64"),
    }

    with open(readme_path, "r", encoding="utf-8") as f:
        content = f.read()

    # Replace version numbers in markdown table rows: "| artifact | version |"
    def replace_table_version(artifact_pattern, new_version):
        nonlocal content
        if not new_version:
            return
        # Match: | ...artifact... | old_version |
        content = re.sub(
            r"(\|\s*" + re.escape(artifact_pattern) + r"\s*\|\s*)\S+(\s*\|)",
            r"\g<1>" + new_version + r"\2",
            content
        )

    # Skiko
    replace_table_version("org.jetbrains.skiko:skiko", versions["skiko"])

    # Compose core modules (all share same version)
    if versions["compose"]:
        for mod in ["runtime", "runtime-saveable", "ui", "ui-geometry", "ui-unit", "ui-util",
                     "ui-graphics", "ui-text", "ui-backhandler", "animation", "animation-core",
                     "foundation", "foundation-layout", "material-ripple",
                     "components-resources", "annotation", "collection"]:
            for prefix in ["org.jetbrains.compose.runtime:",
                           "org.jetbrains.compose.ui:",
                           "org.jetbrains.compose.animation:",
                           "org.jetbrains.compose.foundation:",
                           "org.jetbrains.compose.material:",
                           "org.jetbrains.compose.components:",
                           "org.jetbrains.compose.annotation-internal:",
                           "org.jetbrains.compose.collection-internal:"]:
                replace_table_version(prefix + mod, versions["compose"])

    # Material3
    replace_table_version("org.jetbrains.compose.material3:material3", versions["material3"])
    replace_table_version("org.jetbrains.compose.material3:material3-window-size-class", versions["window_size"])

    # Icons
    replace_table_version("org.jetbrains.compose.material:material-icons-core", versions["icons_core"])
    replace_table_version("org.jetbrains.compose.material:material-icons-extended", versions["icons_core"])

    # Lifecycle
    if versions["lifecycle"]:
        for mod in ["lifecycle-common", "lifecycle-runtime", "lifecycle-runtime-compose",
                     "lifecycle-viewmodel", "lifecycle-viewmodel-compose", "lifecycle-viewmodel-savedstate"]:
            replace_table_version("org.jetbrains.androidx.lifecycle:" + mod, versions["lifecycle"])

    # Navigation
    if versions["navigation"]:
        for mod in ["navigation-common", "navigation-runtime", "navigation-compose"]:
            replace_table_version("org.jetbrains.androidx.navigation:" + mod, versions["navigation"])
    replace_table_version("org.jetbrains.androidx.navigationevent:navigationevent-compose", versions["nav_event"])

    # SavedState
    if versions["savedstate"]:
        for mod in ["savedstate", "savedstate-compose"]:
            replace_table_version("org.jetbrains.androidx.savedstate:" + mod, versions["savedstate"])

    # Third-party
    replace_table_version("com.materialkolor:material-color-utilities-mingwx64", versions["materialkolor"])

    # miuix
    if versions["miuix"]:
        for mod in ["miuix-core", "miuix-ui", "miuix-blur", "miuix-preference",
                     "miuix-icons", "miuix-navigation3-ui", "miuix-shapes"]:
            replace_table_version("top.yukonga.miuix.kmp:" + mod, versions["miuix"])

    with open(readme_path, "w", encoding="utf-8") as f:
        f.write(content)

    print(f"Updated README versions: skiko={versions['skiko']}, compose={versions['compose']}, miuix={versions['miuix']}")

if __name__ == "__main__":
    main()
