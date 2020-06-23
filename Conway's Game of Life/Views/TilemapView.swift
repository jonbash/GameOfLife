//
//  TilemapView.swift
//  Conway's Game of Life
//
//  Created by Jon Bash on 2020-06-15.
//  Copyright © 2020 Jon Bash. All rights reserved.
//

import SwiftUI


struct TilemapView: View {
   @Binding var tilemap: Tilemap
   let isEditable: Bool
   @Binding var showGrid: Bool

   var body: some View {
      TilemapViewRepresentable(
         tilemap: self.$tilemap,
         isEditable: isEditable,
         showGrid: self.$showGrid)
         .aspectRatio(CGFloat(tilemap.width) / CGFloat(tilemap.height),
                      contentMode: .fit)
   }
}


struct TilemapViewRepresentable: UIViewRepresentable {
   @Binding var tilemap: Tilemap
   let isEditable: Bool
   @Binding var showGrid: Bool

   func makeUIView(context: Context) -> UITilemapView {
      let view = UITilemapView(tilemap: $tilemap)
      view.isEditable = isEditable
      view.showGrid = showGrid
      return view
   }

   func updateUIView(_ uiView: UITilemapView, context: Context) {
      uiView.isEditable = isEditable
      uiView.tilemapSize = CGSize(width: tilemap.width, height: tilemap.height)
      uiView.showGrid = showGrid
      uiView.setNeedsDisplay()
   }
}


// MARK: - UIView

class UITilemapView: UIView {
   @Environment(\.colorScheme) var colorScheme

   @Binding var tilemap: Tilemap

   var isEditable: Bool = true
   var showGrid: Bool = true

   lazy var tilemapSize = CGSize(width: tilemap.width, height: tilemap.height)

   private let gridColor: UIColor = .gray

   init(tilemap: Binding<Tilemap>) {
      self._tilemap = tilemap
      super.init(frame: .zero)
      self.addGestureRecognizer(UITapGestureRecognizer(
         target: self,
         action: #selector(mapWasTapped(_:))))
   }

   required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
   }

   override func draw(_ rect: CGRect) {
      let isLight = (colorScheme == .light)
      let liveColor: UIColor = isLight ? .black : .white
      let deadColor: UIColor = isLight ? .white : .black
      let tileSize = getTileSize(tilemapSize: tilemapSize, rect: rect)

      deadColor.set()
      UIRectFill(rect)
      if showGrid {
         gridColor.setStroke()
      }

      for column in 0..<tilemap.width {
         for row in 0..<tilemap.height {
            let point = Point(x: column, y: row)
            guard let tile = tilemap.tile(at: point) else { continue }
            let origin = getTileOrigin(point: point, tileSize: tileSize)
            let tileColor = tile.isAlive ? liveColor : deadColor

            if showGrid {
               tileColor.setFill()
            } else {
               tileColor.set()
            }
            let tileRect = CGRect(origin: origin, size: tileSize)
            UIRectFill(tileRect)
            UIRectFrame(tileRect)
         }
      }
   }

   @objc
   private func mapWasTapped(_ gesture: UIGestureRecognizer) {
      guard isEditable else { return }
      let touch = gesture.location(in: self)
      let size = getTileSize(tilemapSize: tilemapSize, rect: frame)
      let point = Point(
         x: Int(touch.x / size.width),
         y: Int(touch.y / size.height))
      let touchedRect = CGRect(
         origin: getTileOrigin(point: point, tileSize: size),
         size: size)

      tilemap.toggleTile(at: point)
      setNeedsDisplay(touchedRect)
   }

   private func getTileOrigin(point: Point, tileSize: CGSize) -> CGPoint {
      CGPoint(x: CGFloat(point.x) * tileSize.width,
              y: CGFloat(point.y) * tileSize.height)
   }

   private func getTileSize(tilemapSize: CGSize, rect: CGRect) -> CGSize {
      CGSize(width: rect.width / tilemapSize.width,
             height: rect.height / tilemapSize.height)
   }
}


// MARK: - Previews

struct TilemapView_Previews: PreviewProvider {
   static let gridSize = 25

   static var previews: some View {
      TilemapView(
         tilemap: Binding(
            get: { .random(width: gridSize, height: gridSize) },
            set: { _ in }),
         isEditable: true,
         showGrid: Binding(get: { true }, set: { _ in }))
         .previewDevice("iPhone XS")
   }
}
