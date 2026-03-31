# Godot 4.2 Changelog - Applicable Changes

Changes from [Godot 4.2](https://godotengine.org/article/godot-4-2-arrives-in-style/) (2023-11-30) relevant to the Godot Universal Mod Manager.

## GDScript

### New Features
- **Static typing in `for` loops**: Allow type hints in `for` loop variables ([GH-80247](https://github.com/godotengine/godot/pull/80247)). Enables `for game: GameData in games` instead of untyped iteration. Project has many untyped `for` loops in Registry.gd, Main.gd, and Game.gd.
- **Pattern guards in `match`**: Add `when` conditions to `match` cases ([GH-80085](https://github.com/godotengine/godot/pull/80085)). Enables more expressive pattern matching.
- **Raw string literals**: Add r-string syntax `r"raw\nstring"` ([GH-74995](https://github.com/godotengine/godot/pull/74995)). No escape processing - useful for Windows file paths with backslashes.
- **Code regions**: Add `#region`/`#endregion` markers for foldable script sections ([GH-74843](https://github.com/godotengine/godot/pull/74843)). Useful for organizing larger files like Game.gd (273 lines) and Main.gd (170 lines).
- **`@deprecated` and `@experimental` doc tags**: Mark class members in documentation comments ([GH-78941](https://github.com/godotengine/godot/pull/78941)).
- **Untyped code warnings**: New warning reports all untyped declarations ([GH-81355](https://github.com/godotengine/godot/pull/81355)). Helps enforce strict typing across the codebase.
- **Return type covariance**: Overridden methods can return more specific types ([GH-82477](https://github.com/godotengine/godot/pull/82477)).
- **Scoped constants as type hints**: Preloaded scripts and enums inside method blocks can be used as type hints ([GH-80964](https://github.com/godotengine/godot/pull/80964)).

### Improvements
- **Operator call optimization**: Faster operator execution for built-in types ([GH-79990](https://github.com/godotengine/godot/pull/79990)).
- **LSP improvements**: Better hovered symbol resolution, reference lookup, rename support ([GH-80973](https://github.com/godotengine/godot/pull/80973)). New `--lsp-port` for external editor support ([GH-81844](https://github.com/godotengine/godot/pull/81844)).

## Core

### Breaking Changes
- **`change_scene_to_*` behavior change**: Current scene removed from tree immediately instead of at end of frame ([GH-78988](https://github.com/godotengine/godot/pull/78988)). Project uses `change_scene_to_file()` in Main.gd:147 and Game.gd:272. Verify no code depends on `current_scene` being available during the transition frame.
- **Mesh resource format changed**: New vertex/attribute compression format ([GH-81138](https://github.com/godotengine/godot/pull/81138)). Old formats auto-load but 4.2 meshes cannot open in pre-4.2. Not directly relevant since project has no 3D meshes, but good to know.

### Improvements
- **Resource ID stability**: Fix sporadic changing of resource IDs in scenes ([GH-65011](https://github.com/godotengine/godot/pull/65011)). Should reduce VCS noise in `.tscn`/`.tres` files.
- **SVG loading from buffer/string**: SVG files can be loaded from binary buffer or string ([GH-78248](https://github.com/godotengine/godot/pull/78248)). Project uses SVG textures (Textures/*.svg.import).
- **OGG runtime loading**: OGG files can be loaded at runtime from buffer or file path ([GH-78084](https://github.com/godotengine/godot/pull/78084)).
- **Import type changes without restart**: Changing import type no longer requires editor restart ([GH-78890](https://github.com/godotengine/godot/pull/78890)).
- **Memory/performance fix**: Abnormal memory usage for plain Godot objects resolved ([GH-81020](https://github.com/godotengine/godot/pull/81020), [GH-81037](https://github.com/godotengine/godot/pull/81037)).

## GUI

### New Features
- **Native file dialogs**: OS-native file selection dialogs for Linux, macOS, and Windows ([GH-47499](https://github.com/godotengine/godot/pull/47499), [GH-79574](https://github.com/godotengine/godot/pull/79574), [GH-80104](https://github.com/godotengine/godot/pull/80104)). Already adopted in project via PR #2 (`Change FileDialogs to native`). This is the upstream implementation of that feature.
- **TabBar/TabContainer focus**: Individual tabs can receive focus with keyboard navigation and dedicated styling ([GH-79104](https://github.com/godotengine/godot/pull/79104)). Could improve keyboard accessibility if tabs are added.
- **Control focus neighbor**: New method to find next valid focus neighbor in any direction ([GH-76027](https://github.com/godotengine/godot/pull/76027)).

### Improvements
- **RichTextLabel image handling**: Quick refreshes, padding, proportional sizing, tooltips for embedded images ([GH-80410](https://github.com/godotengine/godot/pull/80410)).
- **PopupMenu improvements**: `add_icon_shortcut`/`add_shortcut` gain `allow_echo` parameter ([GH-36493](https://github.com/godotengine/godot/pull/36493)). `clear` gains `free_submenus` parameter ([GH-79965](https://github.com/godotengine/godot/pull/79965)).

## Editor

### New Features
- **`EditorInterface` as singleton**: Accessible directly by name without needing an `EditorPlugin` reference ([GH-75694](https://github.com/godotengine/godot/pull/75694)). Relevant if tool scripts or editor plugins are added.
- **Folder colors**: Filesystem dock supports colored folders ([GH-80440](https://github.com/godotengine/godot/pull/80440)).
- **Make resources unique**: Fine-grained sub-resource control when duplicating resources ([GH-77855](https://github.com/godotengine/godot/pull/77855)).

### Improvements
- **Inspector context menus**: Right-click options for properties ([GH-80411](https://github.com/godotengine/godot/pull/80411)).
- **Property documentation on hover**: Descriptions shown when hovering types/properties in the inspector ([GH-81092](https://github.com/godotengine/godot/pull/81092), [GH-81221](https://github.com/godotengine/godot/pull/81221)).

## Rendering

### New Features
- **2D HDR rendering**: Enables glow and other 3D post-processing effects in 2D for Forward+/Mobile renderers ([GH-80215](https://github.com/godotengine/godot/pull/80215)).
- **Compatibility renderer shadows**: 3D shadow support added to GL Compatibility renderer ([GH-77496](https://github.com/godotengine/godot/pull/77496)). Project uses GL Compatibility.
- **ANGLE-backed OpenGL**: Alternative OpenGL driver for macOS and Windows ([GH-72831](https://github.com/godotengine/godot/pull/72831)).
- **AMD FSR 2.2**: Upscaling support ([GH-81197](https://github.com/godotengine/godot/pull/81197)).

## Platform-Specific

### Input
- **Viewport mouse handling rework**: More predictable behavior across windows ([GH-67791](https://github.com/godotengine/godot/pull/67791)). Project has multiple dialog windows.
- **Multi-input action fix**: Fix bug where simultaneous WASD + gamepad inputs conflicted ([GH-80859](https://github.com/godotengine/godot/pull/80859), [GH-81170](https://github.com/godotengine/godot/pull/81170)).

### 2D
- **`Line2D.closed` property**: Create enclosed lines ([GH-79182](https://github.com/godotengine/godot/pull/79182)).
- **`rotate_toward` and `angle_difference`**: New global math methods ([GH-80225](https://github.com/godotengine/godot/pull/80225)).
- **Forced integer scaling**: Project setting for pixel-perfect rendering ([GH-75784](https://github.com/godotengine/godot/pull/75784)).

### Multiplayer
- **ENet security fix**: Denial of service vulnerability patched.

### Debugging
- **Threaded code debugging**: Full support for debugging threaded code with execution stack and breakpoints ([GH-76582](https://github.com/godotengine/godot/pull/76582)).

## Action Items

### Should Adopt
1. **Static typing in `for` loops** ([GH-80247](https://github.com/godotengine/godot/pull/80247)): Add type hints to all `for` loops. Examples: `for game: Registry.GameData in Registry.games`, `for mod: Registry.GameData.ModData in game_metadata.installed_mods`, `for entry in %GameList.get_children()`.
2. **Untyped code warnings** ([GH-81355](https://github.com/godotengine/godot/pull/81355)): Enable this project-wide warning to enforce strict typing across the codebase and catch missing type annotations.
3. **Code regions** ([GH-74843](https://github.com/godotengine/godot/pull/74843)): Use `#region`/`#endregion` in Game.gd (mod CRUD, override.cfg management, UI validation) and Main.gd (game import, game creation, entry management) for organization.

### Should Verify
4. **`change_scene_to_file` timing** ([GH-78988](https://github.com/godotengine/godot/pull/78988)): Scene is now removed immediately on `change_scene_to_file()`. Main.gd:147 (`open_game`) and Game.gd:272 (`go_back`) use this - verify no code executes after these calls that depends on the previous scene still existing.
5. **Native file dialogs** ([GH-47499](https://github.com/godotengine/godot/pull/47499)): Already adopted via PR #2. Verify the upstream implementation is stable and consistent with the project's existing usage in PathEdit.gd.
6. **Resource ID stability** ([GH-65011](https://github.com/godotengine/godot/pull/65011)): Should reduce spurious diffs in `.tscn` files. Verify with a test commit after upgrading.

### Good to Know
7. **Raw string literals** ([GH-74995](https://github.com/godotengine/godot/pull/74995)): Useful for Windows mod paths containing backslashes, e.g., `r"C:\Users\name\mods"`.
8. **Pattern guards in `match`** ([GH-80085](https://github.com/godotengine/godot/pull/80085)): Could simplify Game.gd:202-203 where `match` on `game_data.godot_version` is combined with size checks.
9. **SVG loading from string** ([GH-78248](https://github.com/godotengine/godot/pull/78248)): Relevant since project uses SVG textures in Textures/ directory.
10. **`EditorInterface` singleton** ([GH-75694](https://github.com/godotengine/godot/pull/75694)): Simplifies tool script access if editor plugins are added.
11. **Viewport mouse handling rework** ([GH-67791](https://github.com/godotengine/godot/pull/67791)): Should improve input behavior across the project's multiple dialog windows.
