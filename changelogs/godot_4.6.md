# Godot 4.6 Changelog - Applicable Changes

Changes from [Godot 4.6](https://godotengine.org/releases/4.6/) (2026-01-26) relevant to the Godot Universal Mod Manager.

## GDScript

### New Features

- **Directory-level warning rules**: New `debug/gdscript/warnings/directory_rules` project setting to configure warning levels per directory ([GH-93889](https://github.com/godotengine/godot/pull/93889)). Useful for suppressing warnings in addons (GUT, AutoExportVersion) while keeping strict warnings in project code.
- **Step out in script debugger** ([GH-97758](https://github.com/godotengine/godot/pull/97758)). Quality of life improvement for debugging GDScript.
- **Coroutine-without-await warning**: New opt-in warning when calling a coroutine without `await` ([GH-107936](https://github.com/godotengine/godot/pull/107936)). Helps catch missing `await` calls.
- **String placeholder syntax highlighting** ([GH-112575](https://github.com/godotengine/godot/pull/112575)). Improves readability of `%` format strings used throughout the project (e.g., Game.gd line 31, Main.gd line 88).
- **Tracy profiling support for GDScript** ([GH-113279](https://github.com/godotengine/godot/pull/113279)). New profiling capability for GDScript code.

### Improvements

- **`GDScriptInstance::notification` optimization** ([GH-94118](https://github.com/godotengine/godot/pull/94118)). General performance improvement for all GDScript nodes.
- **`reserve()` for Dictionary, applied to GDScript VM constructors** ([GH-110709](https://github.com/godotengine/godot/pull/110709)). Reduces allocations when constructing dictionaries used in Registry.gd's `get_var()` methods.
- **Elide unnecessary copies in typed container opcodes** ([GH-110717](https://github.com/godotengine/godot/pull/110717)). Benefits `Array[GameData]` and `Array[ModData]` in Registry.gd.

### Bug Fixes

- **Fix GDScript translation parser for `FileDialog.add_filter()` two-parameter format** ([GH-111298](https://github.com/godotengine/godot/pull/111298)). PathEdit.gd uses `FileDialog.filters` assignment. Relevant if switching to `add_filter()` calls.
- **Fix GDScript extends path recursion** ([GH-112923](https://github.com/godotengine/godot/pull/112923)). General stability fix.
- **Ensure correct caching of cyclic references** ([GH-113600](https://github.com/godotengine/godot/pull/113600)). Stability improvement for script loading.

## Core

### New Features

- **`change_scene_to_node()`** ([GH-85762](https://github.com/godotengine/godot/pull/85762)). New method to change scenes using a node instance instead of a file path. Project currently uses `change_scene_to_file()` in Main.gd (line 147) and Game.gd (line 272).
- **`String.has_extension()` method** ([GH-109433](https://github.com/godotengine/godot/pull/109433)). Could simplify extension checks like `%CreateScene.text.get_extension() in ["tscn", "scn"]` in Main.gd (line 99) and icon format checks in Game.gd (line 144).
- **`Array.reserve()` and `String.reserve()`** ([GH-105928](https://github.com/godotengine/godot/pull/105928)). Pre-allocate capacity for arrays and strings when size is known.
- **Extended file attributes / alternate data streams** ([GH-102232](https://github.com/godotengine/godot/pull/102232)). New `FileAccess` methods for reading/writing extended file attributes. Useful for file metadata operations.

### Improvements

- **Avoid repeated copy-on-write in `Array::resize()`** ([GH-110535](https://github.com/godotengine/godot/pull/110535)). Benefits `Array[ModData]` and `Array[GameData]` operations in Registry.gd.
- **`Node::get_children` performance** ([GH-110571](https://github.com/godotengine/godot/pull/110571)). Faster iteration over game/mod list children in Main.gd and Game.gd.
- **`Node::iterate_children` fast path** ([GH-107369](https://github.com/godotengine/godot/pull/107369)). Internal optimization for iterating node children.
- **Optimize scene tree groups** ([GH-108507](https://github.com/godotengine/godot/pull/108507)). General scene tree performance improvement.
- **Optimize NodePath** ([GH-113447](https://github.com/godotengine/godot/pull/113447)). Benefits `^"%Remove"` and similar NodePath lookups used throughout the project.
- **Handle NaN and Infinity in JSON stringify** ([GH-111498](https://github.com/godotengine/godot/pull/111498)). Robustness improvement for any JSON operations.
- **Include key in `Dictionary::operator[]` error message** ([GH-112853](https://github.com/godotengine/godot/pull/112853)). Better error messages when accessing missing dictionary keys, helpful for debugging GameData/ModData dictionaries.
- **Allow `override.cfg` to add autoloads to the front of the list** ([GH-113078](https://github.com/godotengine/godot/pull/113078)). Directly relevant to the mod loader: `override.cfg` is the core mechanism for injecting the GUMM mod loader scene. This change enables controlling autoload order via override.cfg.
- **Ensure paths in autoload info** ([GH-113088](https://github.com/godotengine/godot/pull/113088)). Related to autoload handling, relevant to mod loading.

### Breaking Changes

- **Project setting to disable `override.cfg`** ([GH-108818](https://github.com/godotengine/godot/pull/108818)). **CRITICAL**: Adds a project setting and build option to disable `override.cfg` and related CLI arguments. The mod manager's core mechanism relies on `override.cfg` to redirect `run/main_scene` to `GUMM_mod_loader.tscn`. Games built with this setting enabled will be unmoddable via GUMM's current approach.
- **Disable unsafe CLI arguments in template builds by default** ([GH-111909](https://github.com/godotengine/godot/pull/111909)). May affect how template builds handle command-line arguments that the mod loader could rely on.

### Bug Fixes

- **Fix `load_threaded_get` returning null with `CACHE_MODE_IGNORE`** ([GH-111387](https://github.com/godotengine/godot/pull/111387)). Resource loading stability.
- **Fix buffer over-read in `FileAccessMemory::get_buffer`** ([GH-111772](https://github.com/godotengine/godot/pull/111772)). Memory safety fix.
- **Fix `String.rfindn` for single-character strings** ([GH-113044](https://github.com/godotengine/godot/pull/113044)). String operation fix.
- **Fix scene argument parsing** ([GH-112716](https://github.com/godotengine/godot/pull/112716)). Fixes for `--scene` command line argument handling.

## GUI

### New Features

- **Expose FileDialog favorite/recent list methods** ([GH-108146](https://github.com/godotengine/godot/pull/108146)). PathEdit.gd uses FileDialog extensively. These methods allow programmatic access to FileDialog's favorites and recent directories introduced in 4.5.
- **FileDialog custom icon callbacks** ([GH-108147](https://github.com/godotengine/godot/pull/108147)). Allows customizing icons shown in FileDialog.
- **MIME argument for `FileDialog.add_filter()`** ([GH-111439](https://github.com/godotengine/godot/pull/111439)). Extended filter API for file dialogs.
- **Reworked FileDialog shortcuts** ([GH-111460](https://github.com/godotengine/godot/pull/111460)). Improved keyboard navigation in file dialogs used by PathEdit.gd.
- **Add horizontal scrolling to TabBar** ([GH-110151](https://github.com/godotengine/godot/pull/110151)). New scrolling capability for tab bars.
- **Scroll hints for ScrollContainer and Tree** ([GH-112491](https://github.com/godotengine/godot/pull/112491)). Visual hints showing more content is available when scrolling. Could benefit the game and mod list UIs.
- **SplitContainer supports more than two children** ([GH-90411](https://github.com/godotengine/godot/pull/90411)). SplitContainer is no longer limited to two children.
- **`pivot_offset_ratio` property on Control** ([GH-70646](https://github.com/godotengine/godot/pull/70646)). New property for positioning control pivot points relative to size.
- **Add `h`/`v_separation` theme properties to ScrollContainer** ([GH-111975](https://github.com/godotengine/godot/pull/111975)). More layout control for scroll containers.
- **Add custom StyleBox to TreeItem** ([GH-112371](https://github.com/godotengine/godot/pull/112371)). Allows per-item styling in Tree controls.
- **Dynamic scaling of LineEdit right icon** ([GH-95817](https://github.com/godotengine/godot/pull/95817)). LineEdit icons now scale with the control. PathEdit.gd uses LineEdit.
- **Close dialog windows with Cmd+W on macOS** ([GH-107303](https://github.com/godotengine/godot/pull/107303)). Project uses AcceptDialog/ConfirmationDialog in Main.gd and Game.gd. macOS users can now close these with Cmd+W.
- **Visualize MarginContainer margins when selected** ([GH-111095](https://github.com/godotengine/godot/pull/111095)). Editor QoL for UI layout work. Game.tscn uses MarginContainer.

### Bug Fixes

- **Fix `popup_centered_*` rect update** ([GH-112604](https://github.com/godotengine/godot/pull/112604)). Fixes rect calculation after `_pre_popup`. Project uses `popup_centered()` and `popup_centered_ratio()` in Main.gd, Game.gd, and PathEdit.gd.
- **Fix LineEdit Unicode insertion failing to emit `text_changed`** ([GH-111190](https://github.com/godotengine/godot/pull/111190)). Project listens to `text_changed` on LineEdit nodes for validation (Main.gd, Game.gd). This fix ensures the signal fires correctly.
- **Fix LineEdit placeholder text selected on double click** ([GH-110886](https://github.com/godotengine/godot/pull/110886)). QoL fix for LineEdit used in PathEdit.gd and dialog forms.
- **Fix `LineEdit.set_editable` to capture text focus when enabled** ([GH-114847](https://github.com/godotengine/godot/pull/114847)). PathEdit.gd toggles `line_edit.editable` via the `disabled` property. This fix improves focus behavior when re-enabling.
- **Fix FileDialog's `root_subfolder` on Windows** ([GH-110524](https://github.com/godotengine/godot/pull/110524)). File dialog stability on Windows.
- **Fix Windows native FileDialog filters not showing descriptions** ([GH-111529](https://github.com/godotengine/godot/pull/111529)). PathEdit.gd sets FileDialog filters for icon formats.
- **Fix native FileDialogs popping up when `use_native_dialog` is modified** ([GH-113746](https://github.com/godotengine/godot/pull/113746)). FileDialog stability fix.
- **Fix save dialog clearing filename when navigating folders** ([GH-114039](https://github.com/godotengine/godot/pull/114039)). FileDialog usability fix.
- **Fix changing directory in FileDialog** ([GH-114177](https://github.com/godotengine/godot/pull/114177)). FileDialog navigation fix.
- **Fix OptionButton PopupMenu not shrinking after item changes** ([GH-114806](https://github.com/godotengine/godot/pull/114806)). Project uses OptionButton for Godot version selection in Main.tscn.
- **Fix `mouse_entered`/`mouse_exited` signals emitted too early** ([GH-107955](https://github.com/godotengine/godot/pull/107955)). General UI signal timing fix.
- **Fix UI focus being shown when it shouldn't** ([GH-111369](https://github.com/godotengine/godot/pull/111369)). Reduces visual noise from unexpected focus rectangles.
- **Hide Control focus when given via mouse input** ([GH-110250](https://github.com/godotengine/godot/pull/110250)). Focus rectangles are hidden when clicking with mouse, shown only for keyboard navigation.
- **Fix incorrect margins in ScrollContainer with focus border** ([GH-111386](https://github.com/godotengine/godot/pull/111386)). Layout fix for scroll containers.
- **Fix SplitContainer crash on change type** ([GH-113164](https://github.com/godotengine/godot/pull/113164)). Stability fix.
- **Clamp menus at the bottom of the screen** ([GH-109981](https://github.com/godotengine/godot/pull/109981)). Popup menus no longer overflow the screen edge.

### Deprecations

- **Deprecate TextEdit `background_color`** ([GH-110543](https://github.com/godotengine/godot/pull/110543)). Game.gd uses TextEdit for mod description. Verify no custom `background_color` is set in scene files.

## Editor

### New Features

- **Game speed controls in embedded game window** ([GH-107273](https://github.com/godotengine/godot/pull/107273)). Development QoL for testing.
- **Clickable file paths in Output panel** ([GH-108473](https://github.com/godotengine/godot/pull/108473)). Error file paths in the Output panel are now clickable, navigating directly to the source.
- **Condensed Inspector layout for Arrays** ([GH-103257](https://github.com/godotengine/godot/pull/103257)). More compact display of arrays in the Inspector.
- **Reworked editor docks** ([GH-106503](https://github.com/godotengine/godot/pull/106503)). Major dock layout improvements.
- **Bottom panel as available dock slot** ([GH-108647](https://github.com/godotengine/godot/pull/108647)). Bottom panel can now be used as a dock position.
- **Confirmation dialog for filesystem dock file moves/copies** ([GH-109017](https://github.com/godotengine/godot/pull/109017)). Safety net for accidental file operations.
- **FindInFiles: Replace individual results** ([GH-109727](https://github.com/godotengine/godot/pull/109727)). More granular find-and-replace in files.
- **Show symlink target in resource tooltip** ([GH-109525](https://github.com/godotengine/godot/pull/109525)). Useful when mod directories are symlinked.
- **ObjectDB Profiling Tool** ([GH-97210](https://github.com/godotengine/godot/pull/97210)). New tool for tracking object allocations and leaks.

### Improvements

- **Editor optimizations for large scenes** ([GH-109513](https://github.com/godotengine/godot/pull/109513), [GH-109515](https://github.com/godotengine/godot/pull/109515), [GH-109517](https://github.com/godotengine/godot/pull/109517)). Faster selection, signal disconnects, and general editor performance.
- **Automatically open newly created script** ([GH-108342](https://github.com/godotengine/godot/pull/108342)). QoL improvement.
- **Drag and drop export variables** ([GH-106341](https://github.com/godotengine/godot/pull/106341)). Drag resources into `@export` properties.
- **Remove prompt to restart editor after changing custom theme** ([GH-100876](https://github.com/godotengine/godot/pull/100876)). Theme changes now apply without restart.

## Export

### New Features

- **Delta encoding for patch PCKs** ([GH-112011](https://github.com/godotengine/godot/pull/112011)). Supports delta-encoded patch PCK files. Could be relevant for mod distribution if mods use PCK patches.
- **macOS 26 Liquid Glass icons** ([GH-108794](https://github.com/godotengine/godot/pull/108794)). Support for the new macOS 26 icon style on export.

### Bug Fixes

- **Fix Windows application manifest in exported projects with modified resources** ([GH-111316](https://github.com/godotengine/godot/pull/111316)). Stability fix for Windows exports.
- **Update embedded PCK virtual address** ([GH-111674](https://github.com/godotengine/godot/pull/111674)). May affect how the mod manager interacts with exported game PCK files.

## Rendering

### Improvements

- **Massively optimize canvas 2D rendering with vertex buffers** ([GH-112481](https://github.com/godotengine/godot/pull/112481)). Major performance improvement for 2D/UI rendering. Directly benefits this UI-heavy application using the GL Compatibility renderer.
- **Don't redraw invisible CanvasItems** ([GH-90401](https://github.com/godotengine/godot/pull/90401)). Performance improvement: hidden UI elements no longer trigger redraws.
- **Implement SSAO in GLES3** ([GH-109447](https://github.com/godotengine/godot/pull/109447)). Screen-space ambient occlusion is now available in the Compatibility renderer. Not directly needed for this UI app, but expands the renderer's capabilities.
- **Motion vectors in compatibility renderer** ([GH-97151](https://github.com/godotengine/godot/pull/97151)). New feature for the Compatibility renderer.
- **Increase precision of ninepatch source rect** ([GH-115152](https://github.com/godotengine/godot/pull/115152)). Ensures pixel-perfect alignment of NinePatch/StyleBox textures in UI.

### Bug Fixes

- **Fix glow intensity not showing in compatibility renderer** ([GH-110843](https://github.com/godotengine/godot/pull/110843)). Compatibility renderer fix.
- **Fix glow visual compatibility regression** ([GH-112471](https://github.com/godotengine/godot/pull/112471)). Compatibility renderer fix.
- **Clear intermediate buffers when not in use in Compatibility** ([GH-110915](https://github.com/godotengine/godot/pull/110915)). Memory cleanup in Compatibility renderer.
- **Fix GLES3 `buffer_free_data` error** ([GH-113220](https://github.com/godotengine/godot/pull/113220)). GLES3 stability fix.
- **OBS workaround: Use `GL_FRAMEBUFFER` for final blit** ([GH-111834](https://github.com/godotengine/godot/pull/111834)). Fixes visual issues when recording/streaming the app with OBS.
- **Fix warning spam in Compatibility when using depth texture** ([GH-111234](https://github.com/godotengine/godot/pull/111234)). Reduces console noise.

## Platform-Specific

### Windows

- **Fix crash when using ANGLE OpenGL** ([GH-112720](https://github.com/godotengine/godot/pull/112720)). Stability fix for GL Compatibility renderer fallback on Windows.
- **Improve rendering driver fallback** ([GH-112384](https://github.com/godotengine/godot/pull/112384)). Better fallback behavior when primary renderer fails. Relevant since project uses `gl_compatibility`.
- **Direct3D 12 default for new projects** ([GH-113213](https://github.com/godotengine/godot/pull/113213)). New projects default to D3D12. Existing projects using `gl_compatibility` are unaffected.
- **Fix "Unexpected NUL character" errors on Wine** ([GH-112496](https://github.com/godotengine/godot/pull/112496)). Wine compatibility fix.
- **Fix application manifest in exported projects** ([GH-111316](https://github.com/godotengine/godot/pull/111316)). Export stability fix.

### macOS

- **Fix ~500ms hang on transparent OpenGL window creation on macOS 26** ([GH-111657](https://github.com/godotengine/godot/pull/111657)). Performance fix for the upcoming macOS version.
- **Prefer user-specified file extensions over OS preferred** ([GH-113757](https://github.com/godotengine/godot/pull/113757)). Fixes file save dialogs using the OS-preferred extension instead of what the user typed.
- **macOS 26 Liquid Glass icon support** ([GH-108794](https://github.com/godotengine/godot/pull/108794)). New icon style for macOS 26 exports.
- **Fix non-focusable window order** ([GH-114495](https://github.com/godotengine/godot/pull/114495)). Window management fix.

### Linux

- **Wayland improvements**: Compose/dead key support ([GH-113068](https://github.com/godotengine/godot/pull/113068)), game embedding ([GH-107435](https://github.com/godotengine/godot/pull/107435)), fix laggy window resize ([GH-113714](https://github.com/godotengine/godot/pull/113714)), fullscreen exit fix ([GH-111580](https://github.com/godotengine/godot/pull/111580)). Continued Wayland maturation for Linux users.
- **XFCE `exo-open` support in `OS.shell_open`** ([GH-113341](https://github.com/godotengine/godot/pull/113341)). Game.gd uses `OS.shell_open()` for opening game directories (line 182). XFCE desktop users can now use this feature.

### Android

- **Storage Access Framework (SAF) support** ([GH-112215](https://github.com/godotengine/godot/pull/112215)). Major file access improvement for Android, if the mod manager is ever ported to mobile.

## Action Items

### Should Adopt

1. **`String.has_extension()`** ([GH-109433](https://github.com/godotengine/godot/pull/109433)): Could simplify extension checks like `get_extension() in ["tscn", "scn"]` in Main.gd (line 99) and `get_extension() in Registry.ICON_FORMATS` in Game.gd (line 144).
2. **`override.cfg` autoload ordering** ([GH-113078](https://github.com/godotengine/godot/pull/113078)): The mod loader can now add autoloads to the front of the list via `override.cfg`. Consider leveraging this for more sophisticated mod loading.
3. **Directory warning rules** ([GH-93889](https://github.com/godotengine/godot/pull/93889)): Configure per-directory GDScript warning rules to suppress warnings in `addons/` while keeping strict warnings in project code.

### Should Verify

1. **`override.cfg` disable setting** ([GH-108818](https://github.com/godotengine/godot/pull/108818)): **CRITICAL**. A new project setting can disable `override.cfg` entirely. This is GUMM's core mod injection mechanism. Games built with Godot 4.6+ that enable this setting will be unmoddable. Document this limitation and consider detecting it.
2. **Unsafe CLI arguments disabled in template builds** ([GH-111909](https://github.com/godotengine/godot/pull/111909)): Verify that no CLI arguments used by the mod loading system are affected by this change.
3. **TextEdit `background_color` deprecation** ([GH-110543](https://github.com/godotengine/godot/pull/110543)): Check if Game.tscn's TextEdit nodes (mod description) use a custom `background_color` property. If so, migrate to the replacement.
4. **FileDialog changes** ([GH-111116](https://github.com/godotengine/godot/pull/111116), [GH-111159](https://github.com/godotengine/godot/pull/111159), [GH-111460](https://github.com/godotengine/godot/pull/111460)): Unified FileDialog context menus, remaining changes before unification, and reworked shortcuts. Verify PathEdit.gd's FileDialog still functions correctly.
5. **`popup_centered_*` rect fix** ([GH-112604](https://github.com/godotengine/godot/pull/112604)): Project uses `popup_centered()` and `popup_centered_ratio(0.4)` in multiple places. Verify dialogs still appear at expected sizes.

### Good to Know

1. **Canvas 2D rendering massive optimization** ([GH-112481](https://github.com/godotengine/godot/pull/112481)): Major performance boost for 2D/UI rendering via vertex buffers. Directly benefits this UI-heavy application. No code changes needed.
2. **Mouse focus behavior improvements** ([GH-110250](https://github.com/godotengine/godot/pull/110250), [GH-111369](https://github.com/godotengine/godot/pull/111369)): Focus rectangles are now hidden for mouse interactions, only shown for keyboard navigation. Improves visual polish automatically.
3. **`change_scene_to_node()`** ([GH-85762](https://github.com/godotengine/godot/pull/85762)): New alternative to `change_scene_to_file()`. Could allow pre-configuring scene instances before transitioning, e.g., passing game data directly to the Game scene instead of using `set_meta`/`get_meta`.
4. **Scroll hints** ([GH-112491](https://github.com/godotengine/godot/pull/112491)): ScrollContainers now show visual hints when there is more content to scroll. The game and mod lists may benefit from this automatically.
5. **Delta encoding for patch PCKs** ([GH-112011](https://github.com/godotengine/godot/pull/112011)): New PCK patching capability that could enable more efficient mod distribution.
6. **LineEdit improvements** ([GH-95817](https://github.com/godotengine/godot/pull/95817), [GH-110886](https://github.com/godotengine/godot/pull/110886), [GH-111190](https://github.com/godotengine/godot/pull/111190)): Dynamic icon scaling, fixed placeholder selection, and fixed Unicode `text_changed` emission. All benefit PathEdit.gd and dialog form LineEdits.
7. **OBS workaround** ([GH-111834](https://github.com/godotengine/godot/pull/111834)): Fixes visual issues when recording/streaming the mod manager with OBS using the GL Compatibility renderer.
8. **FileDialog quality-of-life fixes** ([GH-110524](https://github.com/godotengine/godot/pull/110524), [GH-111529](https://github.com/godotengine/godot/pull/111529), [GH-113746](https://github.com/godotengine/godot/pull/113746), [GH-114039](https://github.com/godotengine/godot/pull/114039), [GH-114177](https://github.com/godotengine/godot/pull/114177)): Multiple fixes to FileDialog navigation, filter descriptions, and directory changing. All benefit PathEdit.gd's file browsing.
9. **Node performance improvements** ([GH-107369](https://github.com/godotengine/godot/pull/107369), [GH-110571](https://github.com/godotengine/godot/pull/110571), [GH-113447](https://github.com/godotengine/godot/pull/113447)): Faster child iteration, `get_children`, and NodePath operations. Benefits the game/mod list UI which iterates children frequently.
10. **XFCE shell_open support** ([GH-113341](https://github.com/godotengine/godot/pull/113341)): `OS.shell_open()` now works on XFCE Linux desktops. Fixes "Open Game Directory" for XFCE users.
