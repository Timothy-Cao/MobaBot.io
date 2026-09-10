# Cursor family

Original code-authored SVGs, 9 September 2026. No external art or generated bitmap pack.

- Menu: cream/steel workshop pointer, teal inset, brass tail; hotspot (4,4).
- Combat: open steel/teal precision reticle; hotspot (20,20).
- Aiming/placement: brass diamond and cream cross; hotspot (20,20).

40×40 transparent canvas. Native Godot hardware cursors stay independent of camera zoom. Menu pointer returns over interactive UI; existing button hover states remain. No cursor trails, pulsing or pointer-position smoothing. Native text/edit/resize cursors are not replaced. `tests/cursor_test.gd -- --render` writes an ignored actual-size contrast sheet.

Implementation follows [Godot's hardware cursor guidance](https://docs.godotengine.org/en/stable/tutorials/inputs/custom_mouse_cursor.html).
