# Godot 4.3 Changelog - Applicable Changes

Changes from [Godot 4.3](https://godotengine.org/releases/4.3/) (2024-08-15) relevant to the Godot Universal Mod Manager.

## GDScript

### New Features

- `**is not` operator\*\*: Allows `if my_node is not Node3D` instead of `if not my_node is Node3D` ([GH-87939](https://github.com/godotengine/godot/pull/87939)). More readable negated type checks.
- **Built-in functions as Callable**: Built-in methods and utility functions can now be used as Callables ([release notes](https://godotengine.org/releases/4.3/)). Enables patterns like `print.callv(my_array)`. Useful with `.map()` and `.filter()` which are used in Game.gd and PathEdit.gd.
- `**@export_storage` annotation\*\*: Store hidden values in a scene that don't appear in the inspector. Useful for addon/plugin data storage.
- `**@export_custom` annotation\*\*: Export values with custom hint strings, prefixes, suffixes, and usage flags.
- `**CONFUSABLE_CAPTURE_REASSIGNMENT` warning\*\*: Warns when reassigning a variable that shadows a captured variable in lambdas ([GH-93691](https://github.com/godotengine/godot/pull/93691)). Project uses lambdas in `.filter()` and `.map()` calls.
- **Warn on enum without default**: New `ENUM_VARIABLE_WITHOUT_DEFAULT` warning when an enum-typed variable has no default value ([GH-90756](https://github.com/godotengine/godot/pull/90756)).
- `**Callable.create` static method\*\*: Create Variant callables from any object and method name ([GH-88948](https://github.com/godotengine/godot/pull/88948)).
- `**atr` and `atr_n` in POT generator\*\*: Auto-translation functions now supported in POT generation ([GH-91951](https://github.com/godotengine/godot/pull/91951)).

### Improvements

- **Type inference for string format operator**: The `%` string format operator now infers the result type as String ([GH-90448](https://github.com/godotengine/godot/pull/90448)). Helps with strict typing.
- **Suppress unused constant warning with underscore**: Prefix unused constants with `_` to suppress warnings, matching the convention for variables ([GH-90794](https://github.com/godotengine/godot/pull/90794)).
- **Allow casting enum to int**: Explicit `int` cast on enum values now works without warnings ([GH-90580](https://github.com/godotengine/godot/pull/90580)).
- **Static variable initialization in-editor**: Static variables now correctly initialize with defaults when running in the editor ([GH-91472](https://github.com/godotengine/godot/pull/91472)). Relevant to Registry.gd if static variables are adopted from 4.1 recommendations.
- **"Add Type Hints" editor setting enabled by default**: The editor now suggests type hints by default in autocompletion ([GH-88026](https://github.com/godotengine/godot/pull/88026)).

### Bug Fixes

- Fix multiline array/dictionary in `match` statements ([GH-90373](https://github.com/godotengine/godot/pull/90373)). Project uses `match` in Game.gd for Godot version handling.
- Fix lambdas capturing non-local variables ([GH-92241](https://github.com/godotengine/godot/pull/92241)). Relevant to `.filter()` and `.map()` lambdas in Game.gd.
- Fix implicit cast to typed array when passing parameter ([GH-94025](https://github.com/godotengine/godot/pull/94025)).
- Enhanced handling of cyclic dependencies ([GH-93346](https://github.com/godotengine/godot/pull/93346)). General resilience improvement.
- Fix incorrect setter call for reference types ([GH-94674](https://github.com/godotengine/godot/pull/94674)). Relevant to RefCounted-based GameDescriptor.gd and ModDescriptor.gd.

## Core

### New Features

- `**String.contains()`\*\*: Case-insensitive `contains` method ([GH-91611](https://github.com/godotengine/godot/pull/91611)). Could simplify case-insensitive search if mod/game filtering is added.
- `**OS.get_entropy()**`: Expose cryptographic random bytes ([GH-93177](https://github.com/godotengine/godot/pull/93177)).

### Breaking Changes

- **Binary serialization modified**: Typed array serialization changed ([GH-78219](https://github.com/godotengine/godot/pull/78219)). Breaks compat with script encoding/decoding. Project uses `var_to_str()`/`str_to_var()` in Registry.gd for the game list - verify these still work correctly.
- **PackedByteArray base64 encoding**: New compact storage format ([GH-89186](https://github.com/godotengine/godot/pull/89186)). Older Godot versions may not open resources saved by 4.3. Not directly impactful since project doesn't use PackedByteArray for storage, but good to know for forward compatibility.

### Bug Fixes

- Fix use-after-free in `FileAccess::exists` ([GH-95311](https://github.com/godotengine/godot/pull/95311)). Project uses `FileAccess.file_exists()` extensively in Registry.gd, Main.gd, GameEntry.gd, and ModEntry.gd.
- Fix crash in `Image.save_jpg_to_buffer` ([GH-91590](https://github.com/godotengine/godot/pull/91590)). Project uses `image.save_png()` - related Image stability improvement.

## GUI

### Breaking Changes

- `**AcceptDialog` parameter types tightened\*\*: `register_text_enter` parameter changed from `Control` to `LineEdit`, `remove_button` from `Control` to `Button` ([GH-89419](https://github.com/godotengine/godot/pull/89419)). GDScript compatible. Project uses dialogs in Main.gd and Game.gd.
- `**Popup` "panel" style removed\*\*: Unused theme style removed ([GH-90633](https://github.com/godotengine/godot/pull/90633)). Verify project's Popup/Dialog theming is unaffected.

### Behavior Changes

- `**auto_translate` deprecated\*\*: Replaced by `auto_translate_mode` property on `Node` ([GH-87530](https://github.com/godotengine/godot/pull/87530)). Default is `AUTO_TRANSLATE_INHERIT` (inherits from parent). If any nodes had `auto_translate = false`, child nodes may now unexpectedly stop translating.
- **Default font outline color changed**: From white to black ([GH-54641](https://github.com/godotengine/godot/pull/54641)). Verify if any Label nodes use font outlines.
- **GUI pixel snap rounding changed**: Controls now use `floor(x + 0.5)` instead of previous rounding ([GH-93749](https://github.com/godotengine/godot/pull/93749)). May cause subtle 1px shifts in UI layout.

### Bug Fixes

- Fix native file dialogs being shown on `set_visible(false)` ([GH-92943](https://github.com/godotengine/godot/pull/92943)). Directly relevant to PathEdit.gd which uses FileDialog with native mode.
- Fix duplicate `AcceptDialog` cancel/confirm events ([GH-92460](https://github.com/godotengine/godot/pull/92460)). Project uses confirmation dialogs for delete operations.
- Fix disabled files in `FileDialog` using wrong color ([GH-91281](https://github.com/godotengine/godot/pull/91281)).
- Fix `Control` nodes emitting unnecessary `resized` signals ([GH-93908](https://github.com/godotengine/godot/pull/93908)). General stability improvement for UI-heavy project.
- Fix popup windows content margins ([GH-92647](https://github.com/godotengine/godot/pull/92647)). Project uses `popup_centered()` and `popup_centered_ratio()` in multiple files.
- Fix `Container` minimum size with hidden parent ([GH-94085](https://github.com/godotengine/godot/pull/94085)).
- `LineEdit`: Include `read_only` StyleBox in `get_minimum_size()` ([GH-91326](https://github.com/godotengine/godot/pull/91326)). Project uses LineEdit in PathEdit.gd.
- Fix `FlowContainer` crash with `TextureRect` using `EXPAND_FIT_*` expand modes ([GH-94286](https://github.com/godotengine/godot/pull/94286)). FlowContainer was noted as a potential layout option in 4.1 review.

### Improvements

- `**TabContainer` max icon width per tab\*\*: Allow setting maximum icon width for individual tabs ([GH-91193](https://github.com/godotengine/godot/pull/91193)).
- **Button `align_to_largest_stylebox` theme option**: New theme property to align button text/icon to either largest or current stylebox ([GH-92701](https://github.com/godotengine/godot/pull/92701)).

## Editor

### Improvements

- **Hide GDScript internal functions from method selectors**: Internal functions no longer clutter the signal connection dialog ([GH-92802](https://github.com/godotengine/godot/pull/92802)). Quality of life improvement.
- **Unload addons before quitting**: Addons now get proper cleanup on editor exit ([GH-93238](https://github.com/godotengine/godot/pull/93238)). Relevant since project uses AutoExportVersion and GUT addons.
- **In-editor documentation facelift**: Class reference now has syntax highlighting and a copy button for code blocks.

## Rendering

### Improvements

- **Compatibility renderer feature-complete**: The GL Compatibility renderer (used by this project) now supports MSAA, resolution scaling, glow, reflection probes, lightmap GI, adjustments, and color correction. Project can now use these features without switching renderers.
- **Direct3D 12 support**: New rendering driver for Windows/ARM platforms. Improves compatibility for Windows users.

## Platform-Specific

### Display

- **Wayland support for Linux/BSD**: Experimental built-in Wayland display server support. Linux users on Wayland can now run the mod manager natively without XWayland.

### Export

- **Single-threaded Web exports**: Re-added from Godot 3 for better browser compatibility ([release notes](https://godotengine.org/releases/4.3/)). Removes need for complicated server-side COOP/COEP headers.
- **macOS privacy manifest configuration**: Support for Apple's privacy manifest requirements ([GH-91377](https://github.com/godotengine/godot/pull/91377)). Important for macOS distribution.

## Action Items

### Should Adopt

1. `**is not` operator\*\* ([GH-87939](https://github.com/godotengine/godot/pull/87939)): Replace any `if not x is Type` patterns with `if x is not Type` for readability.
2. **Built-in functions as Callable**: Consider using in `.map()` chains where applicable, e.g., passing built-in conversion functions directly instead of wrapping in lambdas.

### Should Verify

1. `**var_to_str`/`str_to_var` serialization\*\* ([GH-78219](https://github.com/godotengine/godot/pull/78219)): Registry.gd uses these for the game list. Verify existing saved data loads correctly after upgrading to 4.3.
2. `**auto_translate_mode` deprecation\*\* ([GH-87530](https://github.com/godotengine/godot/pull/87530)): Check if any nodes in `.tscn` files had `auto_translate` set. The new inheritance-based system may change behavior.
3. **Popup "panel" style removal** ([GH-90633](https://github.com/godotengine/godot/pull/90633)): Verify dialog theming in Main.tscn and Game.tscn is unaffected.
4. **Native file dialog `set_visible(false)` fix** ([GH-92943](https://github.com/godotengine/godot/pull/92943)): PathEdit.gd uses FileDialog - verify this fix resolves any visibility issues.
5. **GUI pixel snap rounding change** ([GH-93749](https://github.com/godotengine/godot/pull/93749)): Do a visual pass on all UI screens to check for subtle layout shifts.

### Good to Know

1. `**String.containsn()`\*\* ([GH-91611](https://github.com/godotengine/godot/pull/91611)): Case-insensitive string search method available for future use.
2. `**CONFUSABLE_CAPTURE_REASSIGNMENT` warning\*\* ([GH-93691](https://github.com/godotengine/godot/pull/93691)): New warning for lambda variable shadowing - may flag existing `.filter()`/`.map()` lambdas in Game.gd.
3. `**ENUM_VARIABLE_WITHOUT_DEFAULT` warning\*\* ([GH-90756](https://github.com/godotengine/godot/pull/90756)): May produce new warnings on existing enum variables.
4. **Compatibility renderer now feature-complete**: GL Compatibility (used by project) gained MSAA, glow, and other effects. Available if visual enhancements are desired.
5. **Duplicate AcceptDialog events fix** ([GH-92460](https://github.com/godotengine/godot/pull/92460)): If double-fire issues were observed with delete confirmations, this is the fix.
6. `**FileAccess::exists` use-after-free fix\*\* ([GH-95311](https://github.com/godotengine/godot/pull/95311)): General stability improvement for the project's extensive use of `FileAccess.file_exists()`.
