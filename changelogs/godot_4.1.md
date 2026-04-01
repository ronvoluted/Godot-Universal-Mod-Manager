# Godot 4.1 Changelog - Applicable Changes

Changes from [Godot 4.1](https://godotengine.org/article/godot-4-1-is-here) (2023-07-06) relevant to the Godot Universal Mod Manager.

## GDScript

### New Features
- **Static variables**: Add support for static variables in GDScript ([GH-76264](https://github.com/godotengine/godot/pull/76264)). Allows shared state across instances without autoloads.
- **Constructor as Callable**: Allow referencing a class constructor as a `Callable` ([GH-73657](https://github.com/godotengine/godot/pull/73657)). Enables passing constructors as callbacks.
- **Boolean operators for all Variants**: Allow boolean operators for all Variant types ([GH-74741](https://github.com/godotengine/godot/pull/74741)).

### Improvements
- **String/StringName matching**: Allow `String`s and `StringName`s to match each other in `match` statements ([GH-78389](https://github.com/godotengine/godot/pull/78389)). Reduces friction when comparing string types.
- **Autocompletion**: Sort code autocompletion with rules ([GH-75746](https://github.com/godotengine/godot/pull/75746)).
- **Documentation generation**: Improve GDScript documentation generation & behavior ([GH-72095](https://github.com/godotengine/godot/pull/72095)).

### Bug Fixes
- Fix typed arrays not working with concatenation operator `+` ([GH-73540](https://github.com/godotengine/godot/pull/73540)). Project uses `Array[GameData]` and other typed arrays.
- Fix missing warning for shadowing of built-in types ([GH-74842](https://github.com/godotengine/godot/pull/74842)).
- Fix access to identifiers that are reserved keywords ([GH-62830](https://github.com/godotengine/godot/pull/62830)).

## Core

### New Features
- **Deep comparison**: Support deep comparison of `Array` and `Dictionary` ([GH-42625](https://github.com/godotengine/godot/pull/42625)). Project uses arrays/dictionaries in Registry.gd extensively.
- **Dictionary.merge()**: Add `Dictionary.merge()` method ([GH-59883](https://github.com/godotengine/godot/pull/59883)). Useful for merging game/mod configurations.
- **Optional default for get_meta()**: Add optional default value to `get_meta()` ([GH-58608](https://github.com/godotengine/godot/pull/58608)). Project uses `get_meta()`/`set_meta()` for SceneTree data.
- **String.join()**: Expose `String.join()` method ([GH-56369](https://github.com/godotengine/godot/pull/56369)).
- **String.get_slice()**: Expose `String.get_slice()` method ([GH-54453](https://github.com/godotengine/godot/pull/54453)).
- **Image.fill_rect()**: Add `Image.fill_rect()` method ([GH-52457](https://github.com/godotengine/godot/pull/52457)). Project uses Image for mod icons.
- **Child tree signals**: Add a signal to notify when children nodes enter or exit tree ([GH-57541](https://github.com/godotengine/godot/pull/57541)). Could simplify dynamic UI entry management.
- **Scene multi-threading**: Refactor Node processing to allow Scene multi-threading ([GH-75901](https://github.com/godotengine/godot/pull/75901)).
- **Thread safety checks**: Let user scripts disable thread safety checks ([GH-78000](https://github.com/godotengine/godot/pull/78000)).

### Bug Fixes
- **Multi-threaded resource loading**: Fix multi-threaded resource loading ([GH-74405](https://github.com/godotengine/godot/pull/74405)). Relevant to `preload()` and resource management.
- **External resource IDs**: Fix external resource ids lost ([GH-77749](https://github.com/godotengine/godot/pull/77749)).
- **StringName comparison**: Fix `StringName` comparison ([GH-77197](https://github.com/godotengine/godot/pull/77197)).
- **ConfigFile keys**: Quote and escape `ConfigFile` keys when necessary ([GH-52180](https://github.com/godotengine/godot/pull/52180)). Project uses ConfigFile for game.cfg, mod.cfg, override.cfg.
- **Packed scene loading**: Fix loading packed scene with editable children at runtime ([GH-49664](https://github.com/godotengine/godot/pull/49664)).
- **Signal CONNECT_REFERENCE_COUNTED**: Fix behavior of `CONNECT_REFERENCE_COUNTED` option for signal connections ([GH-47442](https://github.com/godotengine/godot/pull/47442)).

### Changed
- **RID, Callable, Signal stored as strings**: Ensure `RID`, `Callable`, and `Signal` are stored as strings ([GH-78517](https://github.com/godotengine/godot/pull/78517)).

## GUI

### New Features
- **Dialog parent-and-popup logic**: Expose dialog parent-and-popup logic to the API ([GH-76025](https://github.com/godotengine/godot/pull/76025)). Project uses multiple dialogs (ImportMod, CreateGame, DeleteConfirm).
- **Button icon alignment**: Implement vertical icon alignment for buttons ([GH-74369](https://github.com/godotengine/godot/pull/74369)).
- **ButtonGroup unpressed option**: Add an option for ButtonGroups to be unpressed ([GH-76279](https://github.com/godotengine/godot/pull/76279)).
- **ScrollContainer custom_step**: Expose horizontal/vertical `custom_step` as editor property for `ScrollContainer` ([GH-70868](https://github.com/godotengine/godot/pull/70868)).
- **LineEdit selection getters**: Add selection getter methods to LineEdit ([GH-60176](https://github.com/godotengine/godot/pull/60176)). Project uses LineEdit in PathEdit component.
- **LineEdit drag and drop**: Add drag and drop to TextEdit, LineEdit, RichTextLabel ([GH-55355](https://github.com/godotengine/godot/pull/55355)).
- **Window.get_window_id()**: Expose `Window.get_window_id()` ([GH-77288](https://github.com/godotengine/godot/pull/77288)).
- **CheckBox disabled icons**: Add disabled theme icons for CheckBox ([GH-37755](https://github.com/godotengine/godot/pull/37755)). Project uses CheckBox for mod enable/disable.
- **FlowContainer**: Add FlowContainer ([GH-57960](https://github.com/godotengine/godot/pull/57960)). New layout option for mod lists.
- **Button focus font color**: Add focus font color to `Button` and derivatives ([GH-54264](https://github.com/godotengine/godot/pull/54264)).
- **ButtonGroup pressed signal**: Add a `pressed` signal to ButtonGroup ([GH-48500](https://github.com/godotengine/godot/pull/48500)).

### Improvements
- **TextureButton/Button update on texture change**: Make `TextureButton` and `Button` update on texture change ([GH-77159](https://github.com/godotengine/godot/pull/77159)).
- **Popup/dialog key mapping**: Use defined key mapping for closing popups and dialogs ([GH-77297](https://github.com/godotengine/godot/pull/77297)).
- **Theme access warning**: Add a warning when accessing theme prematurely and fix surfaced issues ([GH-73475](https://github.com/godotengine/godot/pull/73475)).
- **LineEdit double/triple click**: Double click selects words, triple click selects all content ([GH-46527](https://github.com/godotengine/godot/pull/46527)).

### Bug Fixes
- Fix controls not updating all their sizing information when required ([GH-78009](https://github.com/godotengine/godot/pull/78009)).
- Fix input handling for unfocusable embedded windows ([GH-77842](https://github.com/godotengine/godot/pull/77842)).
- LineEdit: Fix clear button for asymmetric stylebox ([GH-61496](https://github.com/godotengine/godot/pull/61496)).
- Popup: Allow changing `exclusive` when already popped ([GH-61483](https://github.com/godotengine/godot/pull/61483)).

## Editor

### New Features
- **Autoload relative paths**: Add relative path support for `EditorPlugin.add_autoload_singleton` ([GH-78109](https://github.com/godotengine/godot/pull/78109)). Project registers Registry as autoload.
- **Typed array export fix**: Fix typed array export ([GH-73256](https://github.com/godotengine/godot/pull/73256)).

### Bug Fixes
- Fix connect signal dialog not allowing Unicode method name ([GH-75814](https://github.com/godotengine/godot/pull/75814)).

## Export

### Changed
- Check if the required texture format is imported in the export dialog ([GH-78456](https://github.com/godotengine/godot/pull/78456)).

## Platform-Specific

### Windows
- Support long path in file access ([GH-76739](https://github.com/godotengine/godot/pull/76739)). Important for mod paths that may be deeply nested.
- Fix minimize button missing in non-resizable projects ([GH-77770](https://github.com/godotengine/godot/pull/77770)).
- Fix platform file access to allow file sharing with external programs ([GH-51430](https://github.com/godotengine/godot/pull/51430)).

## Action Items

### Should Adopt
1. **Static variables** ([GH-76264](https://github.com/godotengine/godot/pull/76264)): Review Registry.gd inner classes - static variables could replace some patterns that currently require instance state.
2. **Dictionary.merge()** ([GH-59883](https://github.com/godotengine/godot/pull/59883)): Use in config merging logic instead of manual key iteration.
3. **get_meta() default value** ([GH-58608](https://github.com/godotengine/godot/pull/58608)): Simplify any `has_meta()`/`get_meta()` guard patterns.
4. **String/StringName matching** ([GH-78389](https://github.com/godotengine/godot/pull/78389)): Remove any explicit conversions between String and StringName in match statements.

### Should Verify
5. **ConfigFile key quoting** ([GH-52180](https://github.com/godotengine/godot/pull/52180)): Verify game.cfg, mod.cfg, and override.cfg keys with special characters still parse correctly.
6. **Typed array concatenation fix** ([GH-73540](https://github.com/godotengine/godot/pull/73540)): Enables cleaner array operations with typed arrays like `Array[GameData]`.
7. **Multi-threaded resource loading fix** ([GH-74405](https://github.com/godotengine/godot/pull/74405)): Relevant if any resource loading happens concurrently.

### Good to Know
8. **Constructor as Callable** ([GH-73657](https://github.com/godotengine/godot/pull/73657)): Enables functional patterns like `array.map(ModData.new)`.
9. **Child tree signals** ([GH-57541](https://github.com/godotengine/godot/pull/57541)): Could simplify GameEntry/ModEntry list management.
10. **FlowContainer** ([GH-57960](https://github.com/godotengine/godot/pull/57960)): Alternative layout for mod grid displays.
11. **CheckBox disabled icons** ([GH-37755](https://github.com/godotengine/godot/pull/37755)): Better visual feedback for disabled mod checkboxes.
