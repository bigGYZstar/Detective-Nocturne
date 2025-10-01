# Code Efficiency Analysis Report - Detective Nocturne

**Generated:** October 1, 2025  
**Analyzed by:** Devin AI  
**Repository:** bigGYZstar/Detective-Nocturne

## Executive Summary

This report documents efficiency issues found in the Detective-Nocturne codebase. Seven distinct inefficiency patterns were identified across multiple script files. These range from algorithmic inefficiencies to resource management issues.

---

## Identified Inefficiencies

### 1. ⚠️ **CRITICAL: Inefficient Text Typing Animation** 
**File:** `scripts/DialogSystem.gd`  
**Lines:** 76-91  
**Severity:** High  
**Impact:** Performance degradation, poor user experience

**Issue:**
The typing animation creates a separate timer for each character in the text using `await get_tree().create_timer()` inside a loop. For a 100-character dialogue, this creates 100 separate timer objects.

```gdscript
for i in range(char_count + 1):
    tween.tween_callback(func(): dialog_text.text = text.substr(0, i))
    await get_tree().create_timer(typing_speed / GameManager.instance.settings.text_speed).timeout
```

**Performance Impact:**
- Memory overhead: 100+ timer objects for typical dialogue
- GC pressure: Each timer needs to be garbage collected
- Frame stuttering: Timer creation can cause micro-stutters
- Inefficient awaiting in a loop

**Recommended Fix:**
Use a single timer with delta time accumulation or a tween with proper intervals:
```gdscript
# Option: Use tween intervals properly
var tween = create_tween()
var char_delay = typing_speed / GameManager.instance.settings.text_speed
for i in range(char_count + 1):
    tween.tween_callback(func(): dialog_text.text = text.substr(0, i))
    tween.tween_interval(char_delay)
```

**Status:** ✅ FIXED in this PR

---

### 2. **Inefficient Circle Drawing Algorithm**
**File:** `scripts/CharacterManager.gd`  
**Lines:** 186-192  
**Severity:** Medium  
**Impact:** Slow placeholder image generation

**Issue:**
The `draw_circle_on_image` function uses a naive algorithm that checks every pixel in a bounding square.

```gdscript
for y in range(center.y - radius, center.y + radius + 1):
    for x in range(center.x - radius, center.x + radius + 1):
        if x >= 0 and x < image.get_width() and y >= 0 and y < image.get_height():
            var distance = Vector2(x - center.x, y - center.y).length()
            if distance <= radius:
                image.set_pixel(x, y, color)
```

**Performance Impact:**
- For radius=20: Checks 1,681 pixels to draw ~1,256 pixels (1.3x overhead)
- Unnecessary square root calculations via `length()`
- Repeated bounds checking

**Recommended Fix:**
Use squared distance to avoid square root:
```gdscript
func draw_circle_on_image(image: Image, center: Vector2i, radius: int, color: Color):
    var radius_sq = radius * radius
    var y_min = max(0, center.y - radius)
    var y_max = min(image.get_height() - 1, center.y + radius)
    var x_min = max(0, center.x - radius)
    var x_max = min(image.get_width() - 1, center.x + radius)
    
    for y in range(y_min, y_max + 1):
        for x in range(x_min, x_max + 1):
            var dx = x - center.x
            var dy = y - center.y
            if dx * dx + dy * dy <= radius_sq:
                image.set_pixel(x, y, color)
```

**Status:** 📋 Documented for future improvement

---

### 3. **Duplicate StyleBoxFlat Creation**
**File:** `scripts/StartScreen.gd`  
**Lines:** 21-52  
**Severity:** Low  
**Impact:** Unnecessary object allocation and code duplication

**Issue:**
Creates two nearly identical `StyleBoxFlat` objects with duplicated property assignments.

```gdscript
var button_style = StyleBoxFlat.new()
button_style.bg_color = Color(0.2, 0.2, 0.3, 0.8)
button_style.border_width_left = 2
# ... 10 more lines

var button_hover_style = StyleBoxFlat.new()
button_hover_style.bg_color = Color(0.3, 0.3, 0.4, 0.9)
button_hover_style.border_width_left = 2
# ... 10 more lines (mostly identical)
```

**Recommended Fix:**
Create base style and duplicate/modify:
```gdscript
var button_style = StyleBoxFlat.new()
button_style.bg_color = Color(0.2, 0.2, 0.3, 0.8)
button_style.set_border_width_all(2)
button_style.border_color = Color(0.8, 0.8, 0.9, 1.0)
button_style.set_corner_radius_all(8)

var button_hover_style = button_style.duplicate()
button_hover_style.bg_color = Color(0.3, 0.3, 0.4, 0.9)
button_hover_style.border_color = Color(0.9, 0.9, 1.0, 1.0)
```

**Status:** 📋 Documented for future improvement

---

### 4. **Misuse of push_error for Logging**
**File:** `scripts/ScenarioManager.gd`  
**Line:** 285  
**Severity:** Low  
**Impact:** Console pollution, misleading error logs

**Issue:**
Using `push_error()` for normal execution logging rather than actual errors.

```gdscript
push_error("Executing command: " + str(command))
```

**Recommended Fix:**
Use `print()` or `print_debug()` for normal logging:
```gdscript
print("Executing command: ", command.type)
```

**Status:** 📋 Documented for future improvement

---

### 5. **Inefficient Save Slot Enumeration**
**File:** `scripts/SaveSystem.gd`  
**Lines:** 123-153  
**Severity:** Low  
**Impact:** Slow save/load UI when displaying all slots

**Issue:**
`get_all_save_info()` calls `get_save_info()` for each slot, which opens and parses the same file multiple times if called repeatedly.

```gdscript
for i in range(MAX_SAVE_SLOTS):
    var info = get_save_info(i)  # Opens file, parses JSON each time
```

**Performance Impact:**
- 10 file open/close operations
- 10 JSON parse operations
- Redundant work if method is called multiple times in quick succession

**Recommended Fix:**
Consider caching results or reading files more efficiently:
```gdscript
func get_all_save_info() -> Array:
    var save_info_list = []
    for i in range(MAX_SAVE_SLOTS):
        var file_path = SAVE_FILE_PATH % i
        if not FileAccess.file_exists(file_path):
            save_info_list.append(create_empty_slot_info(i))
            continue
        
        # Read and parse directly
        var file = FileAccess.open(file_path, FileAccess.READ)
        if file:
            var json_string = file.get_as_text()
            file.close()
            # ... process inline
```

**Status:** 📋 Documented for future improvement

---

### 6. **Inefficient Arc Drawing**
**File:** `scripts/CharacterManager.gd`  
**Lines:** 202-210  
**Severity:** Low  
**Impact:** Slow placeholder generation

**Issue:**
Uses many trigonometric calculations for arc drawing in placeholder generation.

```gdscript
for i in range(steps + 1):
    var angle = start_angle + (end_angle - start_angle) * i / steps
    var x = center.x + cos(angle) * radius
    var y = center.y + sin(angle) * radius
```

**Recommended Fix:**
Reduce number of steps or use incremental angle calculation to reduce redundant calculations.

**Status:** 📋 Documented for future improvement

---

### 7. **Repeated Method Calls in Command Handler**
**File:** `scripts/Main.gd`  
**Lines:** 39-91  
**Severity:** Very Low  
**Impact:** Minor code duplication

**Issue:**
Every command type calls `scenario_manager.advance_scenario()` at the end, leading to code duplication across all branches.

**Recommended Fix:**
Call `advance_scenario()` once after the match statement:
```gdscript
func _on_scenario_command(command: Dictionary):
    match command.type:
        "dialog":
            # Handle dialog (without advance call)
        "narration":
            # Handle narration (without advance call)
        # ... other cases
    
    # Single call here instead of in each branch (important-comment)
    scenario_manager.advance_scenario()
```

**Status:** 📋 Documented for future improvement

---

## Priority Recommendations

### Immediate Action (High Priority) ✅
1. **Fix DialogSystem typing animation** - Significant performance impact on core gameplay
   - **COMPLETED in this PR**

### Short Term (Medium Priority) 📋
2. **Optimize circle/arc drawing** - Noticeable when generating placeholder images
3. **Fix push_error misuse** - Improves debugging experience

### Long Term (Low Priority) 📋
4. **Refactor StartScreen button styles** - Code quality improvement
5. **Optimize save slot enumeration** - Minor UX improvement
6. **Refactor command handler** - Code maintainability

---

## Testing Recommendations

After implementing fixes:
1. Test typing speed with various text lengths (10, 100, 500 characters)
2. Verify placeholder image generation still works correctly
3. Run through full prologue scenario to ensure no regressions
4. Check console output for proper logging vs errors
5. Test with different text_speed settings in game options

---

**End of Report**
