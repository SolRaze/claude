---
name: pill-widget
disable-model-invocation: true
description: Build SwiftUI "glass pill" widgets — rounded-edge glass bubbles that start as a square and grow into a pill as they widen, laid out in a resizable 4-column grid with a corner drag handle (iOS 18 Control-Center style). Use when asked to add a widget/tile canvas, a resizable glass control, a pill-shaped bubble, or a Control-Center-like grid to a SwiftUI app. Ships a drop-in template.
---

# Pill Widget

A reusable pattern for a **Create/widget canvas**: glass, rounded-edge bubbles the
user adds from a preview palette, resizes by dragging a corner (square → pill),
and that persist. Modelled on iOS 18 Control Center's resizable controls.

## Shape rule (the core idea)

A grid **cell is a square** (`colW × colW`). A tile spans `cols × rows` cells, so:

- `1×1` → a rounded **square**,
- wider than tall → the corner radius grows to `height/2`, i.e. a **pill/capsule**.

```swift
let radius = size.width > size.height * 1.4
    ? size.height / 2                       // wide → pill
    : min(size.width, size.height) * 0.28   // square-ish → rounded square
let shape = RoundedRectangle(cornerRadius: radius, style: .continuous)
```

Glass = `.glassEffect(.regular, in: shape)` (iOS 26) with a `.strokeBorder` edge.
"Edge-only bubble" = glass fill + that 1pt stroke; **no icon**, name text only.
Pre-iOS 26 fallback: `.background(.ultraThinMaterial, in: shape)`.

## Rules

- Cells square (`colW = (width - pad*2 - gap*(N-1)) / N`), `N = 4` by default.
- Persist the layout as `Codable [Tile]` JSON (UserDefaults/AppStorage) — never
  a heavier store for what is a handful of tiles.
- Resize **commits on release** (`DragGesture.onEnded`), snapping the translation
  to whole cell steps: `dCols = round(dx / (colW+gap))`, `dRows = round(dy / (colW+gap))`.
- Add via a **preview palette**: a sheet/inline bar showing each option as the
  same bubble it becomes. A modal `.sheet` cannot be a drop target for the canvas
  beneath it, so tap-to-add is honest; only an *inline* (non-modal) palette can
  do true drag-to-place with `.draggable`/`.dropDestination`.
- Greedy row packing: fill left→right, wrap when a row's `cols` exceed `N`.

## Template

`references/PillWidgetCanvas.swift` is a self-contained, drop-in canvas: the
`WidgetBubble`, the resizable grid, the `ResizeHandle`, and a preview sheet.
Copy it, then:

1. Replace the `Feature` enum cases with your widget kinds.
2. Point each kind's `onTap` at its destination (a cover, a route, an action).
3. Swap the `@AppStorage` key for your app's namespace.

Reference implementation in the wild: `Verse/Sources/App/CreateView.swift`.
