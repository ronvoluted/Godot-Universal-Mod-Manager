# Godot 4.4 Changelog - Applicable Changes

Changes from [Godot 4.4](https://godotengine.org/releases/4.4/) (2025-03-03) relevant to the Godot Universal Mod Manager.

## GDScript

### New Features

- **Typed dictionaries**: Full typed dictionary support with syntax like `var d: Dictionary[String, int]` ([GH-78656](https://github.com/godotengine/godot/pull/78656)). Project uses untyped Dictionaries in Registry.gd (GameData, ModData) and descriptor files. Adopting typed dictionaries would improve type safety.
- **`@export_tool_button` annotation**: Easily create inspector buttons that call a method ([GH-96290](https://github.com/godotengine/godot/pull/96290)). Useful for addon development (AutoExportVersion plugin).
- **`@warning_ignore_start` / `@warning_ignore_restore` annotations**: Block-scoped warning suppression instead of per-line `@warning_ignore` ([GH-76020](https://github.com/godotengine/godot/pull/76020)). Useful if any sections need warning suppression.
- **Warning for non-`@tool` extending `@tool`**: New warning when a non-tool class extends a tool class ([GH-78178](https://github.com/godotengine/godot/pull/78178)). Relevant to AutoExportVersion.gd which uses `@tool`.
- **Deprecate `inst_to_dict()` and `dict_to_inst()`**: These utility functions are deprecated ([GH-99121](https://github.com/godotengine/godot/pull/99121)). Verify project doesn't use these.

### Improvements

- **Lambda capture optimization**: Speed up lambda capture handling ([GH-97087](https://github.com/godotengine/godot/pull/97087)). Project uses lambdas in `.filter()` and `.map()` calls in Game.gd and PathEdit.gd.
- **Callable stringify optimization**: Optimize Callable's stringify text ([GH-100033](https://github.com/godotengine/godot/pull/100033)).
- **`UNUSED_SIGNAL` warning improvement**: No longer produces false warnings for common implicit signal uses ([GH-89675](https://github.com/godotengine/godot/pull/89675)). Project defines signals in GameEntry.gd and ModEntry.gd.
- **`SHADOWED_VARIABLE` warning fix**: Fix false warning for members shadowed in subclass ([GH-98873](https://github.com/godotengine/godot/pull/98873)).
- **Unique name without `@onready` warning**: Display correct warning symbol when unique name `%` is used without `@onready` ([GH-102389](https://github.com/godotengine/godot/pull/102389)). Project uses `@onready` with `$` node paths extensively.

### Bug Fixes

- **Typed dictionary fixes**: Multiple fixes for typed dictionary parsing, static initialization, and operator behavior ([GH-98085](https://github.com/godotengine/godot/pull/98085), [GH-98400](https://github.com/godotengine/godot/pull/98400), [GH-96797](https://github.com/godotengine/godot/pull/96797)).
- **Fix `PackedStringArray.to_byte_array()`**: Now returns UTF-8 encoded data instead of pointers ([GH-102515](https://github.com/godotengine/godot/pull/102515)).
- **Fix Plugin Scripts loading twice on startup**: Relevant to GUT and AutoExportVersion addons ([GH-102535](https://github.com/godotengine/godot/pull/102535)).
- **Array/PackedArray bounds checks**: Added bound checks to variant call `get` and `set` methods ([GH-103362](https://github.com/godotengine/godot/pull/103362)).

### Breaking Changes

- **StringName Dictionary keys**: `Dictionary` now uses `StringName` keys by default when accessed from GDScript ([GH-70096](https://github.com/godotengine/godot/pull/70096)). Project uses Dictionaries in GameData/ModData inner classes and ConfigFile operations in GameDescriptor.gd and ModDescriptor.gd. Verify all dictionary key access still works correctly.

## Core

### New Features

- **`Dictionary.sort()` method**: Dictionaries can now be sorted by key ([GH-77213](https://github.com/godotengine/godot/pull/77213)). Useful if game/mod lists need sorting.
- **`Signal.has_connections()` method**: Check if a signal has any connections ([GH-87344](https://github.com/godotengine/godot/pull/87344)). Alternative to checking `signal.get_connections().size() > 0`.
- **`Object` support for `String.format()`**: Format strings can now accept Object values ([GH-65962](https://github.com/godotengine/godot/pull/65962)).
- **Temp file utilities**: New `OS.get_temp_dir()`, `FileAccess.create_temp()`, and `DirAccess.create_temp()` methods ([GH-98397](https://github.com/godotengine/godot/pull/98397)). Useful for test fixtures in test_game_descriptor.gd and test_mod_descriptor.gd which create temp directories.
- **Array `find`/`rfind` with Callable**: Array `find` and `rfind` methods now accept a Callable predicate ([GH-95449](https://github.com/godotengine/godot/pull/95449)). Useful for searching game/mod lists.
- **Typed dictionary binary serialization**: Support for typed dictionaries in binary serialization ([GH-98120](https://github.com/godotengine/godot/pull/98120)). Related to the 4.3 serialization changes noted for Registry.gd.
- **Universal UID support**: UIDs now supported across all resource types ([GH-97352](https://github.com/godotengine/godot/pull/97352)). Explains the `.uid` files appearing in the project.

### Breaking Changes

- **Float-to-string always includes decimal**: `float` to `String` conversion now always includes a decimal point (e.g., `1` becomes `"1.0"`) ([GH-47502](https://github.com/godotengine/godot/pull/47502)). Project uses `str()` and string interpolation. Verify any float-to-string conversions still produce expected output, particularly in ModDescriptor.gd version field.
- **`FileAccess.store_*` returns error codes**: `store_string()`, `store_line()`, etc. now return `Error` instead of `void` ([GH-78289](https://github.com/godotengine/godot/pull/78289)). Project uses `store_string()` in Registry.gd for saving the game list. Existing code that ignores return values will still work, but can now check for errors.
- **`Callable.get_bound_arguments()` fix**: Returns correct data now ([GH-98713](https://github.com/godotengine/godot/pull/98713)). Not directly impactful unless introspecting callables.

### Bug Fixes

- **RefCounted releasing early fix**: Fix RefCounted releasing early and not clearing reference ([GH-93299](https://github.com/godotengine/godot/pull/93299)). Relevant to GameDescriptor.gd and ModDescriptor.gd which extend RefCounted.
- **`Dictionary.merge()` type validation**: Fix type validation when merging dictionaries ([GH-96864](https://github.com/godotengine/godot/pull/96864)). Project may use this if Dictionary.merge() is adopted from 4.1 recommendations.
- **Dictionary key sorting fix**: Fix sorting of Dictionary keys ([GH-97542](https://github.com/godotengine/godot/pull/97542)).
- **`DirAccessPack` fix for exported projects**: Fix `file_exists` and `dir_exists` in exported projects ([GH-98483](https://github.com/godotengine/godot/pull/98483)). Important for the mod manager when running as an exported application.
- **Signal disconnection crash fix**: Avoid potential crash on signal disconnection ([GH-94666](https://github.com/godotengine/godot/pull/94666)). General stability improvement for signal-heavy project.
- **Fix autoloaded scene losing built-in script on upgrade**: Autoloaded scenes retain their scripts when upgrading to 4.4 ([GH-103439](https://github.com/godotengine/godot/pull/103439)). Directly relevant to Registry.gd autoload.

## GUI

### New Features

- **FileDialog filename filter field**: New search/filter field in FileDialog ([GH-88673](https://github.com/godotengine/godot/pull/88673)). Improves UX when browsing for game/mod files in PathEdit.gd.
- **FileDialog case-insensitive filtering**: File filtering in FileDialog is now case insensitive ([GH-85789](https://github.com/godotengine/godot/pull/85789)). Relevant to icon file selection (`.png`, `.PNG`).
- **SplitContainer drag bar StyleBox**: SplitContainer now supports a background StyleBox for the drag bar ([GH-72680](https://github.com/godotengine/godot/pull/72680)).
- **ScrollContainer `SCROLL_MODE_RESERVE`**: New scroll mode that reserves space for the scrollbar to prevent layout shift ([GH-96871](https://github.com/godotengine/godot/pull/96871)).
- **`LineEdit.keep_editing_on_text_submit`**: New property to prevent LineEdit from losing edit state on submit ([GH-100240](https://github.com/godotengine/godot/pull/100240)).
- **`Viewport.gui_cancel_drag()`**: Exposed to GDScript as counterpart to `Control.force_drag()` ([GH-96614](https://github.com/godotengine/godot/pull/96614)).

### Breaking Changes

- **`PopupMenu`/`PopupPanel` shadows visible again**: Popup shadows now render properly ([GH-91333](https://github.com/godotengine/godot/pull/91333)). May change the visual appearance of dialogs in Main.tscn and Game.tscn.
- **Custom tooltip when text is empty**: `Control` now shows custom tooltip even when `tooltip_text` is empty ([GH-97961](https://github.com/godotengine/godot/pull/97961)). Controls with `_make_custom_tooltip()` override may now show tooltips unexpectedly.
- **Fix Control `offset_*` property types**: Control offset properties now use correct types ([GH-98443](https://github.com/godotengine/godot/pull/98443)). Verify `.tscn` files load without issues.

### Bug Fixes

- **Fix native file dialog showing on project load**: ([GH-96900](https://github.com/godotengine/godot/pull/96900)). PathEdit.gd uses FileDialog with native mode.
- **Fix FileDialog default size**: ([GH-97004](https://github.com/godotengine/godot/pull/97004)). Relevant to all FileDialog usage in the project.
- **Fix `TabContainer` minimum size**: ([GH-97132](https://github.com/godotengine/godot/pull/97132)).
- **Fix `ScrollContainer` min size calculation**: ([GH-96305](https://github.com/godotengine/godot/pull/96305)).
- **Don't emit `text_changed` on clearing empty LineEdit**: ([GH-100275](https://github.com/godotengine/godot/pull/100275)). PathEdit.gd connects to `text_changed` signal.
- **Fix `button_up`/`button_down` signals with focus changes**: ([GH-81532](https://github.com/godotengine/godot/pull/81532)). General button reliability improvement.
- **Fix button minimum size when `disabled` is toggled**: ([GH-97897](https://github.com/godotengine/godot/pull/97897)). Project toggles button states in ModEntry.gd.
- **LineEdit copy/select shortcuts when not editable**: Allow copy/select shortcuts when `editable` is false ([GH-99822](https://github.com/godotengine/godot/pull/99822)).
- **Disable auto translation of FileDialog file list**: ([GH-98720](https://github.com/godotengine/godot/pull/98720)). Prevents file names from being mistranslated.
- **Fix FILE_MODE_OPEN_ANY not selecting folders**: ([GH-102080](https://github.com/godotengine/godot/pull/102080)). Relevant to PathEdit.gd folder selection mode.
- **Windows: Non-blocking native file dialogs**: Native file dialogs now run in a thread on Windows ([GH-95794](https://github.com/godotengine/godot/pull/95794)). Significant UX improvement for Windows users.

### Improvements

- **LineEdit focus loss prevention**: Prevent focus loss when text is submitted/rejected, allow arrow key selection without editing ([GH-87674](https://github.com/godotengine/godot/pull/87674)). Improves PathEdit.gd behavior.
- **Label paragraph handling**: Labels now handle text as multiple independent paragraphs ([GH-98605](https://github.com/godotengine/godot/pull/98605)).
- **Button text autowrap fix**: Fix button text autowrap overflow when inside a container ([GH-97389](https://github.com/godotengine/godot/pull/97389)).

## Editor

### New Features

- **"Game" editor tab**: New editor tab for better runtime debugging ([GH-97257](https://github.com/godotengine/godot/pull/97257)). Useful for debugging the mod manager at runtime.
- **Recovery Mode**: Recover crashing projects during initialization ([GH-92563](https://github.com/godotengine/godot/pull/92563)). Safety net if project encounters issues after upgrading.
- **Simple minor version migration**: Automatic migration for minor version differences ([GH-96861](https://github.com/godotengine/godot/pull/96861)). Eases upgrading from 4.3 to 4.4.
- **"Pack Project as ZIP..." menu item**: New option in Project menu ([GH-99781](https://github.com/godotengine/godot/pull/99781)).

### Improvements

- **Fix addon requires editor restart**: Addons no longer need editor restart to become functional ([GH-92667](https://github.com/godotengine/godot/pull/92667)). Quality of life for GUT and AutoExportVersion addons.
- **Fix autoload not accessible by plugin on startup**: ([GH-94802](https://github.com/godotengine/godot/pull/94802)). Relevant to Registry autoload.
- **Advanced settings toggle in Editor Settings**: ([GH-96467](https://github.com/godotengine/godot/pull/96467)). Reduces settings clutter.
- **Globally remember advanced toggle in project settings**: ([GH-96615](https://github.com/godotengine/godot/pull/96615)).
- **Allow Unicode identifier for Autoload name**: ([GH-97273](https://github.com/godotengine/godot/pull/97273)).
- **`.editorconfig` auto-creation on project creation**: ([GH-96845](https://github.com/godotengine/godot/pull/96845), [GH-97270](https://github.com/godotengine/godot/pull/97270)).

## Rendering

### Improvements

- **PopupMenu/Panel styles fix**: Fixed and cleaned up PopupPanel and PopupMenu styles ([GH-96518](https://github.com/godotengine/godot/pull/96518)). May affect dialog appearance.

## Platform-Specific

### Windows

- **Non-blocking native file dialogs**: Native file dialogs now run in a separate thread ([GH-95794](https://github.com/godotengine/godot/pull/95794)). Major UX improvement - the editor/app no longer freezes when a file dialog is open.

### macOS

- **Popup behind always-on-top parent fix**: Popup windows no longer show behind an always-on-top parent ([GH-100179](https://github.com/godotengine/godot/pull/100179)).

### Export

- **Patch PCK support**: New ability to export patch packs and for patches to remove files ([GH-97118](https://github.com/godotengine/godot/pull/97118), [GH-97356](https://github.com/godotengine/godot/pull/97356)). Potentially useful for mod distribution workflows.

## Action Items

### Should Adopt

1. **Typed dictionaries** ([GH-78656](https://github.com/godotengine/godot/pull/78656)): Add type annotations to Dictionary usage in Registry.gd (GameData, ModData), GameDescriptor.gd, and ModDescriptor.gd for improved type safety.
2. **`FileAccess.create_temp()` / `DirAccess.create_temp()`** ([GH-98397](https://github.com/godotengine/godot/pull/98397)): Simplify temp directory creation in test_game_descriptor.gd and test_mod_descriptor.gd.
3. **Array `find` with Callable** ([GH-95449](https://github.com/godotengine/godot/pull/95449)): Use predicate-based find for searching game/mod lists instead of manual loops.

### Should Verify

1. **StringName Dictionary keys** ([GH-70096](https://github.com/godotengine/godot/pull/70096)): Dictionary keys now default to StringName in GDScript. Verify all dictionary key access in Registry.gd, GameDescriptor.gd, and ModDescriptor.gd still works. String/StringName interop should handle most cases, but explicit testing is recommended.
2. **Float-to-string decimal** ([GH-47502](https://github.com/godotengine/godot/pull/47502)): Float conversion now always includes a decimal. Check if any version strings or numeric displays are affected, particularly in ModDescriptor.gd.
3. **`FileAccess.store_*` return type change** ([GH-78289](https://github.com/godotengine/godot/pull/78289)): Registry.gd calls `store_string()` - existing code still works but verify no type inference issues.
4. **PopupMenu/Panel shadow changes** ([GH-91333](https://github.com/godotengine/godot/pull/91333)): Do a visual pass on dialogs in Main.tscn and Game.tscn to verify popup appearance.
5. **Control offset property types** ([GH-98443](https://github.com/godotengine/godot/pull/98443)): Verify all `.tscn` files load without warnings.
6. **Autoload script retention on upgrade** ([GH-103439](https://github.com/godotengine/godot/pull/103439)): Verify Registry autoload retains its script after upgrading to 4.4.

### Good to Know

1. **`Dictionary.sort()`** ([GH-77213](https://github.com/godotengine/godot/pull/77213)): Available for sorting game/mod lists by key if needed.
2. **`Signal.has_connections()`** ([GH-87344](https://github.com/godotengine/godot/pull/87344)): Cleaner way to check for signal connections.
3. **`@warning_ignore_start`/`@warning_ignore_restore`** ([GH-76020](https://github.com/godotengine/godot/pull/76020)): Block-scoped warning suppression for cleaner code.
4. **FileDialog improvements**: Filename filter field ([GH-88673](https://github.com/godotengine/godot/pull/88673)), case-insensitive filtering ([GH-85789](https://github.com/godotengine/godot/pull/85789)), and non-blocking on Windows ([GH-95794](https://github.com/godotengine/godot/pull/95794)) all improve file browsing UX.
5. **Addon no longer needs restart** ([GH-92667](https://github.com/godotengine/godot/pull/92667)): GUT and AutoExportVersion addons activate immediately.
6. **Universal UID support** ([GH-97352](https://github.com/godotengine/godot/pull/97352)): Explains the new `.uid` files in the project - these should be committed to version control.
7. **Patch PCK support** ([GH-97118](https://github.com/godotengine/godot/pull/97118)): New export feature for creating differential patches, potentially useful for mod distribution.
8. **RefCounted early release fix** ([GH-93299](https://github.com/godotengine/godot/pull/93299)): Stability fix for RefCounted-based GameDescriptor and ModDescriptor.
9. **Plugin Scripts double-load fix** ([GH-102535](https://github.com/godotengine/godot/pull/102535)): Fixes potential startup issues with GUT and AutoExportVersion.
