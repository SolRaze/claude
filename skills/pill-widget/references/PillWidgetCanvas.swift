import SwiftUI

// A drop-in "glass pill" widget canvas. Rename `Feature`, wire each kind's tap,
// and swap the storage key. Requires iOS 26 for `.glassEffect`; see the fallback note.

/// One placed widget, sized in a 4-column grid (a cell is square).
struct Tile: Codable, Identifiable, Hashable {
    var id = UUID()
    var feature: String
    var cols: Int = 1   // 1...4 — 1x1 is a square, widen to make a pill
    var rows: Int = 1   // 1...3
}

/// Your widget kinds. Replace these cases.
enum Feature: String, CaseIterable, Identifiable {
    case example = "Example"
    var id: String { rawValue }
}

/// The glass bubble: rounded square that becomes a pill as it widens. Name only, no icon.
struct WidgetBubble: View {
    let title: String
    let size: CGSize

    var body: some View {
        let radius = size.width > size.height * 1.4
            ? size.height / 2
            : min(size.width, size.height) * 0.28
        let shape = RoundedRectangle(cornerRadius: radius, style: .continuous)
        Text(title)
            .font(.subheadline.weight(.semibold))
            .multilineTextAlignment(.center)
            .minimumScaleFactor(0.7)
            .padding(10)
            .frame(width: size.width, height: size.height)
            .glassEffect(.regular, in: shape)                       // iOS 26; else .background(.ultraThinMaterial, in: shape)
            .overlay { shape.strokeBorder(.white.opacity(0.18), lineWidth: 1) }
    }
}

/// Bottom-right corner handle: snaps the drag to whole cell steps, commits on release.
struct ResizeHandle: View {
    let step: CGFloat
    let onCommit: (Int, Int) -> Void
    var body: some View {
        Image(systemName: "arrow.up.left.and.arrow.down.right")
            .font(.caption2).foregroundStyle(.secondary)
            .frame(width: 28, height: 28)
            .background(.ultraThinMaterial, in: Circle())
            .gesture(DragGesture().onEnded { v in
                onCommit(Int((v.translation.width / step).rounded()),
                         Int((v.translation.height / step).rounded()))
            })
    }
}

struct PillWidgetCanvas: View {
    @AppStorage("pillwidget.tiles") private var tilesJSON = ""
    @State private var tiles: [Tile] = []
    @State private var showAdd = false

    private let gap: CGFloat = 12
    private let pad: CGFloat = 16
    private let columns = 4

    var body: some View {
        NavigationStack {
            GeometryReader { geo in
                let colW = (geo.size.width - pad * 2 - gap * CGFloat(columns - 1)) / CGFloat(columns)
                ScrollView {
                    VStack(alignment: .leading, spacing: gap) {
                        ForEach(Array(rows().enumerated()), id: \.offset) { _, row in
                            HStack(spacing: gap) {
                                ForEach(row) { tile in tileView(tile, colW: colW) }
                                Spacer(minLength: 0)
                            }
                        }
                    }
                    .padding(pad)
                }
            }
            .navigationTitle("Create")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showAdd = true } label: { Image(systemName: "plus") }
                }
            }
            .sheet(isPresented: $showAdd) {
                AddSheet { add($0); showAdd = false }.presentationDetents([.medium])
            }
        }
        .onAppear { tiles = decode() }
    }

    private func rows() -> [[Tile]] {
        var out: [[Tile]] = [], row: [Tile] = []; var used = 0
        for t in tiles {
            let c = min(max(t.cols, 1), columns)
            if used + c > columns { out.append(row); row = []; used = 0 }
            row.append(t); used += c
        }
        if !row.isEmpty { out.append(row) }
        return out
    }

    private func size(_ t: Tile, colW: CGFloat) -> CGSize {
        let c = CGFloat(min(max(t.cols, 1), columns)), r = CGFloat(min(max(t.rows, 1), 3))
        return CGSize(width: colW * c + gap * (c - 1), height: colW * r + gap * (r - 1))
    }

    @ViewBuilder private func tileView(_ tile: Tile, colW: CGFloat) -> some View {
        ZStack(alignment: .bottomTrailing) {
            WidgetBubble(title: Feature(rawValue: tile.feature)?.rawValue ?? tile.feature,
                         size: size(tile, colW: colW))
                .onTapGesture { /* route Feature(rawValue: tile.feature) here */ }
                .contextMenu {
                    Button(role: .destructive) { remove(tile) } label: {
                        Label("Remove", systemImage: "trash")
                    }
                }
            ResizeHandle(step: colW + gap) { dc, dr in resize(tile, dc, dr) }.padding(6)
        }
    }

    private func add(_ f: Feature) { tiles.append(Tile(feature: f.rawValue)); persist() }
    private func remove(_ t: Tile) { tiles.removeAll { $0.id == t.id }; persist() }
    private func resize(_ t: Tile, _ dc: Int, _ dr: Int) {
        guard let i = tiles.firstIndex(where: { $0.id == t.id }) else { return }
        tiles[i].cols = min(max(tiles[i].cols + dc, 1), columns)
        tiles[i].rows = min(max(tiles[i].rows + dr, 1), 3)
        persist()
    }

    private func decode() -> [Tile] {
        (try? JSONDecoder().decode([Tile].self, from: Data(tilesJSON.utf8))) ?? []
    }
    private func persist() {
        if let d = try? JSONEncoder().encode(tiles) { tilesJSON = String(decoding: d, as: UTF8.self) }
    }
}

/// Preview palette: each option shown as the square bubble it becomes, tap to add.
struct AddSheet: View {
    let onPick: (Feature) -> Void
    @Environment(\.dismiss) private var dismiss
    private let cols = [GridItem(.adaptive(minimum: 150), spacing: 16)]
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: cols, spacing: 16) {
                    ForEach(Feature.allCases) { f in
                        Button { onPick(f) } label: {
                            WidgetBubble(title: f.rawValue, size: CGSize(width: 150, height: 150))
                        }.buttonStyle(.plain)
                    }
                }.padding()
            }
            .navigationTitle("Add Widget").navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } } }
        }
    }
}
