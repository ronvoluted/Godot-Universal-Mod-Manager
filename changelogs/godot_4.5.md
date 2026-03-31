# Godot 4.5 Changelog - Applicable Changes

Changes from [Godot 4.5](https://godotengine.org/releases/4.5/) (2025-09-15) relevant to the Godot Universal Mod Manager.

## GDScript

### New Features

- **Abstract classes and methods**: New `@abstract` annotation for classes and methods ([GH-67777](https://github.com/godotengine/godot/pull/67777), [GH-106409](https://github.com/godotengine/godot/pull/106409), [GH-107717](https://github.com/godotengine/godot/pull/107717)). Could be used if refactoring GameDescriptor/ModDescriptor into a base descriptor class.
- **Variadic functions**: GDScript now supports variadic function parameters ([GH-82808](https://github.com/godotengine/godot/pull/82808)). New language feature for flexible argument lists.
- **Constant Array and Dictionary constructors**: Allow constructing const-typed containers at compile time ([GH-78837](https://github.com/godotengine/godot/pull/78837)). Could apply to `ICON_FORMATS` in Registry.gd.
- **`@export_file_path` annotation**: Export raw file paths without UID conversion ([GH-105414](https://github.com/godotengine/godot/pull/105414)). Relevant to the path-heavy mod manager if exporting path variables.
- **`@export` Variant variables**: Allow exporting variables of type Variant ([GH-89324](https://github.com/godotengine/godot/pull/89324)).

### Improvements

- **Lambda optimization**: Optimize `GDScriptLambdaCallable` by skipping unnecessary `ObjectDB` lookup ([GH-102930](https://github.com/godotengine/godot/pull/102930)). Project uses lambdas in `.filter()` and `.map()` calls in Registry.gd, Game.gd, and PathEdit.gd.
- **Code region consistency**: Improve consistency of `#region`/`#endregion` code regions ([GH-101319](https://github.com/godotengine/godot/pull/101319)). Relevant if adopting code regions from 4.2 recommendations.
- **Non-constant `for`-`range` optimization**: Optimized range loops ([GH-71564](https://github.com/godotengine/godot/pull/71564)). General performance improvement.

### Bug Fixes

- **Fix `#region`/`#endregion` crash from trailing spaces** ([GH-103825](https://github.com/godotengine/godot/pull/103825)). Important if using code regions.
- **Fix crash with modulo between float and integer** ([GH-101536](https://github.com/godotengine/godot/pull/101536)).
- **Fix `range` helper using 32-bit ints** ([GH-109376](https://github.com/godotengine/godot/pull/109376)). Fixes edge cases with large range values.
- **Fix Variant properties losing value upon script update** ([GH-108558](https://github.com/godotengine/godot/pull/108558)).

## Core

### New Features

- **`Logger` class**: New `Logger` class with ability to print and log script backtraces ([GH-91006](https://github.com/godotengine/godot/pull/91006)). Useful for debugging mod loading issues.
- **`FileAccess.get_size()` and `get_access_time()`**: New methods for file metadata ([GH-83538](https://github.com/godotengine/godot/pull/83538)). Useful for file operations in the mod manager.
- **`DirAccess.is_equivalent()`**: Check if two paths refer to the same directory ([GH-104597](https://github.com/godotengine/godot/pull/104597)). Useful for path comparison in game/mod directory handling.
- **Negative index for `Array.remove_at` and `Array.insert`**: Support negative indices like Python ([GH-83027](https://github.com/godotengine/godot/pull/83027)). Convenience for array operations on game/mod lists.
- **`String.replace_char(s)` and `String.remove_char(s)`**: Performance-optimized character replacement and removal methods ([GH-92475](https://github.com/godotengine/godot/pull/92475), [GH-92476](https://github.com/godotengine/godot/pull/92476)).
- **`SceneTree.scene_changed` signal**: New signal emitted when the current scene changes ([GH-102986](https://github.com/godotengine/godot/pull/102986)). Project uses `change_scene_to_file()` in Main.gd to navigate between Main and Game scenes.
- **`--scene` command line argument**: Run a specific scene from the command line ([GH-105302](https://github.com/godotengine/godot/pull/105302)). Useful for testing individual scenes during development.
- **Compression level support for Zip Module** ([GH-103283](https://github.com/godotengine/godot/pull/103283)). Potentially relevant if mod distribution involves zip files.

### Improvements

- **`ConfigFile.get_sections()` and `get_section_keys()` return `Vector<String>`**: Now returns values directly instead of using out-parameters ([GH-105700](https://github.com/godotengine/godot/pull/105700)). Directly affects GameDescriptor.gd and ModDescriptor.gd which use ConfigFile.
- **`JSON.stringify` performance improvement** ([GH-93783](https://github.com/godotengine/godot/pull/93783)).
- **Array performance improvements**: Reduced copying and copy-on-write calls ([GH-96664](https://github.com/godotengine/godot/pull/96664)). Benefits typed arrays like `Array[GameData]` and `Array[ModData]` in Registry.gd.
- **Faster `Node.get_child_count()`** ([GH-106226](https://github.com/godotengine/godot/pull/106226)). Used indirectly when iterating game/mod lists.
- **Thread safety for Object signals** ([GH-105453](https://github.com/godotengine/godot/pull/105453)). General stability improvement.

### Bug Fixes

- **Fix typed collections using same reference across scene instances** ([GH-108216](https://github.com/godotengine/godot/pull/108216)). Important for `Array[ModData]` in Registry.gd's GameData class.
- **Fix symlink copy in `DirAccess.copy_dir`** ([GH-109276](https://github.com/godotengine/godot/pull/109276)). Relevant to mod file copy operations.
- **Fix file handle leak in ZipArchive and FileAccessZip** ([GH-103219](https://github.com/godotengine/godot/pull/103219)).
- **Fix internal JSON stringify not preserving full precision** ([GH-108831](https://github.com/godotengine/godot/pull/108831)). Relevant to any JSON-based mod metadata.
- **Fix resources wrongly duplicated upon instantiating inherited scenes** ([GH-107219](https://github.com/godotengine/godot/pull/107219)).

### Breaking Changes

- **Remove old path remaps system** ([GH-91594](https://github.com/godotengine/godot/pull/91594)). The mod manager uses `override.cfg` and `Resource.take_over_path()` for mod injection. Verify these mechanisms are unaffected by the removal of the old remap system.
- **Deprecate `PackedDataContainer`** ([GH-105990](https://github.com/godotengine/godot/pull/105990)). Verify project doesn't use this class.
- **Don't duplicate internal nodes** ([GH-89442](https://github.com/godotengine/godot/pull/89442)). May affect node duplication behavior if used anywhere.

## GUI

### New Features

- **`FoldableContainer`**: New collapsible container control ([GH-102346](https://github.com/godotengine/godot/pull/102346)). Could be useful for organizing game/mod details in the UI.
- **FileDialog overhaul**: Major improvements to the built-in FileDialog:
  - Changed from Tree to ItemList layout ([GH-105641](https://github.com/godotengine/godot/pull/105641))
  - Added favorites and recent directories ([GH-105680](https://github.com/godotengine/godot/pull/105680))
  - Added file sorting ([GH-105723](https://github.com/godotengine/godot/pull/105723))
  - Added thumbnail mode ([GH-105863](https://github.com/godotengine/godot/pull/105863))
  - Allow customizing features ([GH-106679](https://github.com/godotengine/godot/pull/106679))
  - Improved options ([GH-105647](https://github.com/godotengine/godot/pull/105647))

  PathEdit.gd uses FileDialog extensively. These changes significantly improve the file browsing UX for selecting game directories and mod files.
- **Recursive focus/mouse filter disable**: Properties that can recursively disable child controls' Focus Mode and Mouse Filter ([GH-97495](https://github.com/godotengine/godot/pull/97495)). Useful for disabling UI sections.
- **SplitContainer touch-friendly drag handle** ([GH-105994](https://github.com/godotengine/godot/pull/105994)).
- **Separate `minimize_disabled` and `maximize_disabled` window flags** ([GH-105107](https://github.com/godotengine/godot/pull/105107)).
- **Screen reader / accessibility support**: Implemented via AccessKit library ([GH-76829](https://github.com/godotengine/godot/pull/76829)). Major new platform feature that enables accessibility for the mod manager's UI.

### Bug Fixes

- **Fix button down signal not emitting on first press after being disabled** ([GH-108921](https://github.com/godotengine/godot/pull/108921)). Relevant to ModEntry.gd which toggles button disabled states.
- **Fix native file dialog crash with invalid filter** ([GH-107197](https://github.com/godotengine/godot/pull/107197)). Relevant to PathEdit.gd which uses native file dialogs.
- **Fix smooth scrolling tied to physics process** ([GH-104349](https://github.com/godotengine/godot/pull/104349)). Improves scroll behavior in game/mod lists.
- **Fix UI navigation breaking on invisible controls** ([GH-101077](https://github.com/godotengine/godot/pull/101077)).
- **Fix memory leak caused by hidden tooltip controls** ([GH-103793](https://github.com/godotengine/godot/pull/103793)).
- **Fix reparenting control does not update recursive mode cache properly** ([GH-104444](https://github.com/godotengine/godot/pull/104444)).

### Breaking Changes

- **AcceptDialog ok button text rework** ([GH-81178](https://github.com/godotengine/godot/pull/81178)). Project uses `get_ok_button()` in Main.gd (lines 49, 115) for `$AddGame` and `$CreateGame` dialogs. Verify dialog button text still displays as expected.
- **Remove `NOTIFICATION_ENTER_TREE` when `NOTIFICATION_THEME_CHANGED` is used** ([GH-89746](https://github.com/godotengine/godot/pull/89746)). If any controls rely on enter-tree for theme setup, they may need updating.
- **Remove `Control.is_top_level_control()`** ([GH-101745](https://github.com/godotengine/godot/pull/101745)). Verify project doesn't use this method.
- **Slider tick changes**: Added bottom/top ticks and tick offset with renamed properties ([GH-103907](https://github.com/godotengine/godot/pull/103907)). Verify any Slider usage if present.

## Editor

### New Features

- **Override editor settings per project** ([GH-69012](https://github.com/godotengine/godot/pull/69012)). Allows customizing editor behavior per-project.
- **Syntax highlighting for ConfigFile/TSCN/TRES/project.godot** ([GH-77972](https://github.com/godotengine/godot/pull/77972)). Useful when editing game.cfg descriptor files and .tscn scene files.
- **Inline color pickers in script editor** ([GH-105724](https://github.com/godotengine/godot/pull/105724)). Quality of life improvement.
- **Fuzzy search in method and script filtering** ([GH-105239](https://github.com/godotengine/godot/pull/105239), [GH-105240](https://github.com/godotengine/godot/pull/105240)). Better code navigation.
- **FindInFiles globally accessible** ([GH-106500](https://github.com/godotengine/godot/pull/106500)). With include/exclude file filtering ([GH-90558](https://github.com/godotengine/godot/pull/90558)).
- **`OS.open_with_program`**: Open files/directories with a specific program on macOS ([GH-107113](https://github.com/godotengine/godot/pull/107113)). Could be useful for opening game directories.
- **Ignore debugger error breaks** ([GH-77015](https://github.com/godotengine/godot/pull/77015)). Quality of life for debugging.

### Improvements

- **Auto Reload Scripts on External Change enabled by default** ([GH-97148](https://github.com/godotengine/godot/pull/97148)). Scripts now auto-reload without manual editor setting.
- **Project manager backup option**: Add option to backup project when it will be changed ([GH-104624](https://github.com/godotengine/godot/pull/104624)). Safety net for project upgrades.
- **Allow toggling UID display in path properties** ([GH-106716](https://github.com/godotengine/godot/pull/106716)). UID management improvement.

## Export

### Improvements

- **PCK directory moved to end of file**: PCK files are now written in-place with the directory at the end ([GH-105757](https://github.com/godotengine/godot/pull/105757)). May affect how the mod manager interacts with exported game PCK files.
- **Shader baker for exports** ([GH-102552](https://github.com/godotengine/godot/pull/102552)). Pre-compiles shaders during export for faster loading.
- **Convert `uid://` names to `res://` when exporting** ([GH-101954](https://github.com/godotengine/godot/pull/101954)). UID paths are resolved to res:// paths in exports.

## Platform-Specific

### All Platforms

- **Screen reader / accessibility support via AccessKit** ([GH-76829](https://github.com/godotengine/godot/pull/76829)). Major accessibility feature across Windows, macOS, and Linux.
- **`FileAccess.get_size()` and `get_access_time()`** ([GH-83538](https://github.com/godotengine/godot/pull/83538)). Cross-platform file metadata methods.

### macOS

- **Fix native file dialog crash with invalid filter** ([GH-107197](https://github.com/godotengine/godot/pull/107197)). Stability fix for file dialogs used by PathEdit.gd.
- **Fix clipboard and TTS not working in embedded game mode** ([GH-107135](https://github.com/godotengine/godot/pull/107135)).

### Windows

- **Fix `get_modified_time` on locked files** ([GH-103622](https://github.com/godotengine/godot/pull/103622)). Relevant when checking mod/game files that may be in use.

### Android

- **Fix save issue when using native file dialog** ([GH-107207](https://github.com/godotengine/godot/pull/107207)).
- **Fix drive selection issue** ([GH-109528](https://github.com/godotengine/godot/pull/109528)). File browsing improvement.

## Action Items

### Should Adopt

1. **`@abstract` annotation** ([GH-107717](https://github.com/godotengine/godot/pull/107717)): Consider using `@abstract` if creating base descriptor or entry classes during refactoring.
2. **`FileAccess.get_size()`** ([GH-83538](https://github.com/godotengine/godot/pull/83538)): Use for file validation when importing game descriptors or mod files instead of only checking existence.
3. **`DirAccess.is_equivalent()`** ([GH-104597](https://github.com/godotengine/godot/pull/104597)): Use for comparing game/mod directory paths to prevent duplicates more robustly than string comparison.
4. **`SceneTree.scene_changed` signal** ([GH-102986](https://github.com/godotengine/godot/pull/102986)): Use instead of relying solely on `_ready()` when transitioning between Main and Game scenes, if cleanup/setup logic is needed.

### Should Verify

1. **Old path remaps removal** ([GH-91594](https://github.com/godotengine/godot/pull/91594)): The mod manager's core mechanism uses `override.cfg` and `Resource.take_over_path()`. Verify these are not affected by the removal of the old path remaps system.
2. **AcceptDialog ok button text rework** ([GH-81178](https://github.com/godotengine/godot/pull/81178)): Project uses `get_ok_button().disabled` in Main.gd for AddGame and CreateGame dialogs. Verify button text and behavior still work as expected.
3. **ConfigFile API changes** ([GH-105700](https://github.com/godotengine/godot/pull/105700)): `get_sections()` and `get_section_keys()` now return `Vector<String>` directly. Verify GameDescriptor.gd and ModDescriptor.gd ConfigFile usage still works.
4. **FileDialog overhaul** ([GH-105641](https://github.com/godotengine/godot/pull/105641)): FileDialog internals changed significantly (Tree → ItemList). Verify PathEdit.gd file dialogs still function correctly, especially folder selection mode.
5. **`NOTIFICATION_ENTER_TREE` removal with `NOTIFICATION_THEME_CHANGED`** ([GH-89746](https://github.com/godotengine/godot/pull/89746)): Check if any custom controls rely on enter-tree notification for theme initialization.
6. **Typed collections reference fix** ([GH-108216](https://github.com/godotengine/godot/pull/108216)): Verify that `Array[ModData]` in GameData class correctly creates independent instances across scene loads.

### Good to Know

1. **Accessibility / screen reader support** ([GH-76829](https://github.com/godotengine/godot/pull/76829)): The mod manager's UI is now potentially accessible to screen readers. No code changes required, but worth testing to ensure a good experience.
2. **FileDialog favorites and recent directories** ([GH-105680](https://github.com/godotengine/godot/pull/105680)): Users can now bookmark frequently used game/mod directories. Built-in, no code changes needed.
3. **`FoldableContainer`** ([GH-102346](https://github.com/godotengine/godot/pull/102346)): New collapsible container that could improve the game detail or mod list UI if a redesign is planned.
4. **`Logger` class** ([GH-91006](https://github.com/godotengine/godot/pull/91006)): New structured logging system that could replace `print()` calls for better debugging of mod loading issues.
5. **Constant Array/Dictionary constructors** ([GH-78837](https://github.com/godotengine/godot/pull/78837)): Can make `ICON_FORMATS` in Registry.gd a true compile-time constant.
6. **Variadic functions** ([GH-82808](https://github.com/godotengine/godot/pull/82808)): New language feature available for flexible function signatures.
7. **`String.replace_char(s)` / `remove_char(s)`** ([GH-92475](https://github.com/godotengine/godot/pull/92475)): Performance-optimized string character operations.
8. **Syntax highlighting for ConfigFile** ([GH-77972](https://github.com/godotengine/godot/pull/77972)): game.cfg files now get syntax highlighting in the editor.
9. **PCK directory at end of file** ([GH-105757](https://github.com/godotengine/godot/pull/105757)): Changed PCK layout may affect how modded game exports are structured.
10. **Shader baker** ([GH-102552](https://github.com/godotengine/godot/pull/102552)): Pre-compiled shaders in exports could affect mod shader loading behavior in the System/4.x/ mod loader.
