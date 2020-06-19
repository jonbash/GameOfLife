//
//  TileView.swift
//  Conway's Game of Life
//
//  Created by Jon Bash on 2020-06-15.
//  Copyright © 2020 Jon Bash. All rights reserved.
//

import SwiftUI


//struct TileView: View {
//   @Binding var tilemap: Tilemap
//   let point: Point
//   let isEditable: Bool
//
//   @Environment(\.colorScheme) var colorScheme
//
//   var body: some View {
//      Button(action: tileTapped) {
//         color(for: colorScheme,
//               isAlive: tilemap.tile(at: point)?.isAlive ?? false)
//      }.disabled(!isEditable)
//   }
//
//   func tileTapped() {
//      tilemap.toggleTile(at: point)
//   }
//
//   private func color(for systemMode: ColorScheme, isAlive: Bool) -> Color {
//      !isAlive ? systemMode.color : systemMode.opposite.color
//   }
//}


struct TileView: UIViewRepresentable {
   @Binding var tile: Tile
   var isEditable: Bool

   init(tile: Binding<Tile>, isEditable: Bool = true) {
      self._tile = tile
      self.isEditable = isEditable
   }

   func makeUIView(context: Context) -> UITileView {
      let uiView = UITileView(tile: $tile, isEditable: self.isEditable)
      return uiView
   }

   func updateUIView(_ uiView: UITileView, context: Context) {
      uiView.isEditable = isEditable
      uiView.setNeedsDisplay()
   }
}


class UITileView: UIView {
   @Environment(\.colorScheme) var colorScheme

   var isEditable: Bool
   @Binding var tile: Tile

   var color: UIColor {
      (tile == .dead) ? colorScheme.uiColor : colorScheme.opposite.uiColor
   }

   lazy var gesture = UITapGestureRecognizer(
      target: self,
      action: #selector(toggleTile(_:)))

   init(tile: Binding<Tile>, isEditable: Bool = true) {
      self._tile = tile
      self.isEditable = isEditable

      super.init(frame: .zero)
      self.addGestureRecognizer(gesture)
   }

   required init?(coder: NSCoder) {
      fatalError("init(coder:) not implemented for UITileView")
   }

   override func draw(_ rect: CGRect) {
      guard let context = UIGraphicsGetCurrentContext() else { return }
      context.setFillColor(color.cgColor)
      context.fill(rect)
   }

   @objc
   private func toggleTile(_ sender: Any?) {
      tile.toggle()
   }
}
